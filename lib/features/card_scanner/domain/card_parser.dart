import 'dart:developer';

import './card_details.dart';

class CardParser {
  CardDetails parseCard(String rawText) {
    final cardNumber = _extractedCardNumber(rawText);
    log('Card Number: $cardNumber');
    final expiryDate = _extractExpiryDate(rawText);
    final cardHolderName = _extractCardHolderName(rawText);
    return CardDetails(
      cardNumber: cardNumber,
      maskedCardNumber: cardNumber != null ? _maskCardNumber(cardNumber) : null,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
    );
  }
}

String? _extractedCardNumber(String rawText) {
  final patterns = [
    RegExp(r'\b(?:[0-9OIlSBZ]{4}[\s\-]?){3}[0-9OIlSBZ]{4}\b'),

    RegExp(r'\b[0-9OIlSBZ]{15,16}\b'),
  ];

  for (final pattern in patterns) {
    // allMatches finds ALL numbers matching this pattern
    // not just the first one
    final matches = pattern.allMatches(rawText);

    for (final match in matches) {
      String candidate = match.group(0)!.replaceAll(RegExp(r'[\s\-]'), '');
      if (isValidCard(candidate)) {
        String cleaned = _fixOcrMistakes(candidate);
        return cleaned;
      }
      // if Luhn fails → loop continues to next match automatically
      // instead of giving up like firstMatch did
    }
  }
  return null;
}

String? _extractExpiryDate(String rawText) {
  // String cleaned = _fixOcrMistakes(rawText);

  // handles formats:
  // 12/25  12-25  12 25  1225
  final patterns = [
    RegExp(r'\b(0[1-9]|1[0-2])[\/\-\s](2[4-9]|[3-9]\d)\b'), // MM/YY
    RegExp(r'\b(0[1-9]|1[0-2])(2[4-9]|[3-9]\d)\b'), // MMYY
    RegExp(r'\b(0[1-9]|1[0-2])[\/\-](20[2-9]\d)\b'), // MM/YYYY
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(rawText);
    if (match != null) {
      String raw = match.group(0)!;
      return _normalizeExpiry(raw);
    }
  }
  return null;
}

String? _extractCardHolderName(String rawText) {
  final lines = rawText.toUpperCase().split('\n');

  // words we know are NOT names on a card
  final blacklist = [
    'VALID',
    'THRU',
    'EXPIRES',
    'EXPIRY',
    'DEBIT',
    'CREDIT',
    'CARD',
    'BANK',
    'VISA',
    'MASTERCARD',
    'RUPAY',
    'MEMBER',
    'SINCE',
    'GOOD',
  ];

  for (final line in lines) {
    final trimmed = line.trim();

    // a name line usually:
    // - has only letters and spaces
    // - is between 5 and 30 characters
    // - has at least 2 words
    if (RegExp(r'^[A-Z\s]{5,30}$').hasMatch(trimmed)) {
      final words = trimmed.split(' ').where((w) => w.isNotEmpty).toList();

      if (words.length >= 2) {
        // make sure none of the words are in our blacklist
        bool hasBlacklistedWord = words.any((w) => blacklist.contains(w));
        if (!hasBlacklistedWord) {
          return trimmed;
        }
      }
    }
  }
  return null;
}

bool isValidCard(String cardNumber) {
  String cleaned = _fixOcrMistakes(cardNumber).replaceAll(RegExp(r'\D'), '');

  if (cleaned.length < 13 || cleaned.length > 19) return false;

  int sum = 0;
  bool shouldDouble = false;

  for (int i = cleaned.length - 1; i >= 0; i--) {
    int digit = int.parse(cleaned[i]);

    if (shouldDouble) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    shouldDouble = !shouldDouble;
  }
  return sum % 10 == 0;
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

// Converting card number intp XXXX XXXX XXXX 1234
String _maskCardNumber(String cardNumber) {
  String cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
  String last4 = cleaned.substring(cleaned.length - 4);
  String masked = 'XXXX XXXX XXXX $last4';
  return masked;
}

// expiry date format to MM/YY
String _normalizeExpiry(String raw) {
  String digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
  if (digitsOnly.length == 4) {
    return '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
  } else if (digitsOnly.length == 6) {
    return '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(4)}';
  }
  return raw;
}


// String _cardType(String rawText){
//   rawText =
// }