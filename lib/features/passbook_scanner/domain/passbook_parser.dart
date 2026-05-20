import 'dart:developer';

import 'package:smart_scanner/features/passbook_scanner/domain/passbook_details.dart';

class PassbookParser {
  BankDetails parsePassbook(String rawText) {
    final accountHolderName = _extractAccountHolderName(rawText);
    final accountNumber = _extractAccountNumber(rawText);
    final ifscCode = _extractIfscCode(rawText);

    // log('Name: $accountHolderName');
    // log('Account: $accountNumber');
    // log('IFSC: $ifscCode');

    return BankDetails(
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
  }

  String? _extractIfscCode(String rawText) {
    // log('Raw Text :: $rawText');
    final regex = RegExp(r'\b[A-Z]{4}[0O][A-Z0-9]{6}\b');
    final match = regex.firstMatch(rawText.toUpperCase());

    if (match != null) {
      String ifsc = match.group(0)!;

      // normalize 5th character to zero
      ifsc = ifsc.substring(0, 4) + '0' + ifsc.substring(5);

      String last6 = ifsc.substring(5).replaceAll('O', '0');
      ifsc = ifsc.substring(0, 5) + last6;
      log('IFS Code :: $ifsc');
      return ifsc;
    }

    return null;
  }

  String? _extractAccountHolderName(String rawText) {
    final lines = rawText.split('\n');
    final upperLines = lines.map((l) => l.toUpperCase().trim()).toList();

    // these are the MAIN account holder keywords
    // ordered by priority — most specific first
    final priorityKeywords = [
      'CUSTOMER NAME',
      'CUSTONER NAME', // m→n on first word
      'CUSTOMER NANE', // m→n on second word
      'CUSTONER NANE', // m→n on both words — exactly what real OCR returned
      'ACCOUNT HOLDER NAME',
      'ACCOUNT HOLDER',
      'A/C HOLDER',
      'AC HOLDER',
    ];

    // lines containing these keywords should be SKIPPED entirely
    final ignoreKeywords = [
      'JOINT',
      'FATHER',
      'SPOUSE',
      'NOMINEE',
      'NOSINEE', // OCR misread of nominee
      'NOAINEE', // OCR misread of nominee
      'BRANCH',
      'MANAGER',
    ];

    for (int i = 0; i < upperLines.length; i++) {
      final line = upperLines[i];

      // skip lines with ignore keywords
      bool shouldIgnore = ignoreKeywords.any((k) => line.contains(k));
      if (shouldIgnore) continue;

      // check if this line has a priority keyword
      bool hasPriorityKeyword = priorityKeywords.any((k) => line.contains(k));

      if (hasPriorityKeyword) {
        // try same line after colon
        // e.g. "Custoner Nane: Mr. VIRENDRA KUMAR"
        if (line.contains(':')) {
          String afterColon = lines[i].split(':').last.trim();
          String cleaned = _stripTitle(afterColon);
          if (_isValidName(cleaned)) {
            log('Name found after colon: $cleaned');
            return _cleanName(cleaned);
          }
        }

        // try next line
        // e.g. "CUSTOMER NAME\nVIRENDRA KUMAR"
        if (i + 1 < lines.length) {
          String nextLine = lines[i + 1].trim();
          String cleaned = _stripTitle(nextLine);

          // check if name is split across two lines
          // e.g. "VIRENDRA\nKUMAR" → join them
          if (_isPartialName(cleaned) && i + 2 < lines.length) {
            String nextNextLine = lines[i + 2].trim();
            if (RegExp(r'^[A-Za-z\s]+$').hasMatch(nextNextLine)) {
              cleaned = cleaned + ' ' + nextNextLine.trim();
            }
          }

          if (_isValidName(cleaned)) {
            log('Name found on next line: $cleaned');
            return _cleanName(cleaned);
          }
        }
      }
    }

    // "Mr. VIRENDRA KUMAR" is a strong signal
    // but skip lines with ignore keywords
    final titlePattern = RegExp(
      r'\b(MR\.?|MRS\.?|MS\.?|DR\.?|SHRI\.?|SMT\.?)\s+([A-Z][A-Z\s]{2,30})',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final upper = upperLines[i];

      // skip ignored lines
      bool shouldIgnore = ignoreKeywords.any((k) => upper.contains(k));
      if (shouldIgnore) continue;

      final match = titlePattern.firstMatch(lines[i]);
      if (match != null) {
        String name = match.group(2)!.trim();
        if (_isValidName(name)) {
          log('Name found via title prefix: $name');
          return _cleanName(name);
        }
      }
    }
    // scan first 15 lines only
    // name is usually near the top of passbook
    final blacklist = [
      'BANK',
      'BRANCH',
      'IFSC',
      'ACCOUNT',
      'BALANCE',
      'DEPOSIT',
      'WITHDRAWAL',
      'DATE',
      'DEBIT',
      'CREDIT',
      'TRANSACTION',
      'PASSBOOK',
      'STATEMENT',
      'ADDRESS',
      'PHONE',
      'EMAIL',
      'NOMINEE',
      'SAVINGS',
      'CURRENT',
      'SINGLE',
      'JOINT',
      'OPERATION',
      'MANAGER',
      'CODE',
    ];

    for (int i = 0; i < upperLines.length; i++) {
      // ← scan ALL lines
      final line = upperLines[i];

      bool shouldIgnore = ignoreKeywords.any((k) => line.contains(k));
      if (shouldIgnore) continue;

      String stripped = _stripTitle(lines[i]).trim().toUpperCase();
      if (_isValidName(stripped, blacklist: blacklist)) {
        log('Name found via all caps fallback: $stripped');
        return _cleanName(stripped);
      }
    }

    return null;
  }

  // removes Mr. Mrs. Ms. Dr. Shri. Smt. from beginning of name
  String _stripTitle(String text) {
    return text
        .replaceAll(
          RegExp(
            r'\b(MR\.?|MRS\.?|MS\.?|DR\.?|SHRI\.?|SMT\.?)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  // checks if extracted text is a valid name
  bool _isValidName(String text, {List<String>? blacklist}) {
    if (text.isEmpty) return false;

    // only letters and spaces
    if (!RegExp(r'^[A-Za-z\s]{5,40}$').hasMatch(text)) return false;

    final words = text.trim().split(' ').where((w) => w.isNotEmpty).toList();

    // must have at least 2 words
    if (words.length < 2) return false;

    // each word must be at least 2 characters
    if (words.any((w) => w.length < 2)) return false;

    // check blacklist if provided
    if (blacklist != null) {
      bool hasBlacklistedWord = words.any(
        (w) => blacklist.contains(w.toUpperCase()),
      );
      if (hasBlacklistedWord) return false;
    }

    return true;
  }

  // checks if name seems incomplete — only 1 word
  bool _isPartialName(String text) {
    final words = text.trim().split(' ').where((w) => w.isNotEmpty).toList();
    return words.length == 1 && text.length > 2;
  }

  // converts "VIRENDRA KUMAR" → "Virendra Kumar"
  String _cleanName(String name) {
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String? _extractAccountNumber(String rawText) {
    final lines = rawText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase().trim();

      bool isAccountKeyword =
          (upper.contains('ACCO') &&
              (upper.contains('NO') || upper.contains('NUM'))) ||
          upper.contains('A/C NO') ||
          upper.contains('AC NO');

      // making sure this line does not include CIF

      bool isCIFLine = upper.contains('CIF');

      if (isCIFLine) continue;

      if (isAccountKeyword) {
        final sameLineMatch = RegExp(r'\b\d{9,18}\b').firstMatch(lines[i]);

        if (sameLineMatch != null) {
          String candidate = sameLineMatch.group(0)!;
          if (_isValidAccountNumber(candidate)) {
            // log('Account number found on same line: $candidate');
            return candidate;
          }
        }
        if (i + 1 < lines.length) {
          final nextLineMatch = RegExp(
            r'\b\d{9,18}\b',
          ).firstMatch(lines[i + 1]);

          if (nextLineMatch != null) {
            String candidate = nextLineMatch.group(0)!;
            if (_isValidAccountNumber(candidate)) {
              // log('Account number found on next line: $candidate');
              return candidate;
            }
          }
        }
      }
    }
    // log('Keyword strategy failed, trying filter strategy');

    final cifLineIndices = <int>[];

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toUpperCase().contains('CIF')) {
        cifLineIndices.add(i);
      }
    }
    List<String> candidates = [];

    for (int i = 0; i < lines.length; i++) {
      if (cifLineIndices.contains(i)) continue;

      final matches = RegExp(r'\b\d{9,18}\b').allMatches(lines[i]);
      for (final match in matches) {
        String number = match.group(0)!;
        if (_isValidAccountNumber(number)) {
          candidates.add(number);
          // log('Candidate account number: $number');
        }
      }
    }
    if (candidates.isEmpty) return null;

    if (candidates.length == 1) return candidates.first;
    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (upper.contains('ACCO') && i + 1 < lines.length) {
        for (final c in candidates) {
          if (lines[i + 1].contains(c)) return c;
        }
      }
    }

    // last option => return longest number
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  bool _isValidAccountNumber(String number) {
    // must be only digits
    if (!RegExp(r'^\d+$').hasMatch(number)) return false;

    // Indian bank account numbers are 9 to 18 digits
    if (number.length < 9 || number.length > 18) return false;

    // must not look like a phone number
    if (_looksLikePhone(number)) return false;

    // must not look like a date
    if (_looksLikeDate(number)) return false;

    // must not look like a PIN code (6 digits starting with known ranges)
    if (number.length == 6) return false;

    return true;
  }

  bool _looksLikeDate(String number) {
    if (number.length < 6 || number.length > 8) return false;

    int? day = int.tryParse(number.substring(0, 2));
    int? month = int.tryParse(number.substring(2, 4));

    if (day != null && month != null) {
      if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
        return true;
      }
    }
    return false;
  }

  bool _looksLikePhone(String number) {
    if (number.length == 10) {
      int? firstDigit = int.tryParse(number[0]);
      if (firstDigit != null && firstDigit >= 6) {
        return true;
      }
    }
    return false;
  }

  String _fixOcrMistakes(String text) {
    return text
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('I', '1')
        .replaceAll('l', '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8')
        .replaceAll('Z', '2');
  }

  String _fixOcrMistakesForCharaters(String text) {
    return text
        .replaceAll('0', 'O')
        .replaceAll('0', 'o')
        .replaceAll('1', 'I')
        .replaceAll('1', 'l')
        .replaceAll('5', 'S')
        .replaceAll('8', 'B')
        .replaceAll('2', 'Z');
  }
}
