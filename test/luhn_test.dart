import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/card_scanner/domain/card_parser.dart';

void main() {
  group('Luhn Validation Tests', () {
    test('Valid card', () {
      expect(isValidCard('4111111111111111'), true);
    });
    test('Invalid card number', () {
      expect(isValidCard('4111111111111112'), false);
    });

    test('Card with spaces', () {
      expect(isValidCard('4111 1111 1111 1111'), true);
    });
  });
}
