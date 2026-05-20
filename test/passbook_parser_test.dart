import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/passbook_scanner/domain/passbook_parser.dart';

void main() {
  group('Account Holder Name', () {
    test('extracts name from noisy OCR — Custoner Nane format', () {
      const rawText = '''
        Nosinee Reg No
        Noainee (Y/N)
        Node of 0peration
        IFSC Code
        :SBINORRVCGB
        Joint Account Holder: Mr. REETA DEVI
        Custoner Nane: Mr. VIRENDRA KUMAR
        ACcount No
        22008225311
      ''';

      final result = PassbookParser().parsePassbook(rawText);
      expect(result.accountHolderName, 'Virendra Kumar');
    });
  });

  group('Account Number', () {
    test('extracts account number from next line after keyword', () {
      const rawText = '''
        ACcount No
        22008225311
        CIF No
        18010796110
      ''';

      final result = PassbookParser().parsePassbook(rawText);
      expect(result.accountNumber, '22008225311');
    });
  });
  group('IFSC Code', () {
    test('extracts clean IFSC code', () {
      const rawText = '''
        IFSC Code: SBIN0001234
        Account No: 22008225311
      ''';

      final result = PassbookParser().parsePassbook(rawText);
      expect(result.ifscCode, 'SBIN0001234');
    });
  });
  group('IFSC Code with 5th character as zero', () {
    test('extracts clean IFSC code', () {
      const rawText = '''
        IFSC Code: SBINo001234
        Account No: 22008225311
      ''';

      final result = PassbookParser().parsePassbook(rawText);
      expect(result.ifscCode, 'SBIN0001234');
    });
  });

  group('Full Parse', () {
    test('parses real world SBI passbook OCR output', () {
      const rawText = '''
        Nosinee Reg No
        Noainee (Y/N)
        Node of 0peration
        IFSC Code
        :SBINORRVCGB
        Branch Manager
        SINGLE
        SERAIKELA
        KHARSHWAN
        NEAR SHIV
        MANDIR 831013
        ADITYAPUR
        Address
        Date of
        Issuing
        father/Spouse Nane:BALI
        NDRA PRASAD
        11/09/2019
        37 /10 STYPE NEAR
        Joint Account Holder: Mr. REETA DEVI
        Custoner Nane: Mr. VIRENDRA KUMAR
        ACcount No
        22008225311
        8r. Address: NEAR S TYPE CHOWK
        CIF No
        A/C TyDe
        18010796110
        S8-NCHQ-PM-JAN DHAN-YOJANA
        Br. Code: 482
        8r. Name : ADITYAPUR SME
      ''';

      final result = PassbookParser().parsePassbook(rawText);

      expect(result.accountHolderName, 'Virendra Kumar');
      expect(result.accountNumber, '22008225311');
      expect(result.ifscCode, 'SBIN0RRVCGB');
    });
  });
}
