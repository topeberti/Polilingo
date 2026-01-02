import 'package:flutter_test/flutter_test.dart';
import 'package:polilingo/core/utils/validation_utils.dart';

void main() {
  group('ValidationUtils - isValidEmail', () {
    test('should return true for valid email addresses', () {
      expect(ValidationUtils.isValidEmail('test@example.com'), isTrue);
      expect(ValidationUtils.isValidEmail('user.name@domain.co'), isTrue);
      expect(ValidationUtils.isValidEmail('user+alias@domain.com'), isTrue);
      expect(ValidationUtils.isValidEmail('123@domain.org'), isTrue);
    });

    test('should return false for invalid email addresses', () {
      expect(ValidationUtils.isValidEmail('test'), isFalse);
      expect(ValidationUtils.isValidEmail('test@'), isFalse);
      expect(ValidationUtils.isValidEmail('@example.com'), isFalse);
      expect(ValidationUtils.isValidEmail('test@example'), isFalse);
      expect(ValidationUtils.isValidEmail('test @example.com'), isFalse);
      expect(ValidationUtils.isValidEmail(''), isFalse);
    });
  });
}
