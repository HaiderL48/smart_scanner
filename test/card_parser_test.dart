import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/card_scanner/domain/card_parser.dart';

void main() {
  group('Card Parser Tests', () {
    final parser = CardParser();

    test('Extract valid card details', () {
      final result = parser.parseCard('''
      JOHN DOE
      4111 1111 1111 1111
      12/29
      ''');

      expect(result.cardNumber, '4111111111111111');
      expect(result.expiryDate, '12/29');
      expect(result.cardHolderName, 'JOHN DOE');
    });

    test('Handles OCR mistakes', () {
      final result = parser.parseCard('''
    JOHN DOE
    4111 1111 1111 111I
    12/29
    ''');

      expect(result.cardNumber, '4111111111111111');
    });
    test('Ignores invalid numbers', () {
      final result = parser.parseCard('''
    1234 5678 9012 3456
    ''');

      expect(result.cardNumber, null);
    });
  });
}
