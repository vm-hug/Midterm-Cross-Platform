import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/core/utils/validators.dart';
import 'package:midterm_cross_platform/core/config/app_config.dart';

void main() {
  test('Admin email validation remains separate from products', () {
    expect(Validators.email('  admin@example.com  '), isNull);
    for (final v in [
      '',
      'a@',
      'a b@e.com',
      'a@example',
      '${'a' * 255}@e.com',
    ]) {
      expect(Validators.email(v), isNotNull);
    }
  });
  test('Product names have bounds', () {
    expect(Validators.productName('Bút bi'), isNull);
    expect(Validators.productName('   '), isNotNull);
    expect(Validators.productName('a' * 101), isNotNull);
  });
  test(
    'Price accepts zero, decimals and decimal comma; rejects nonfinite/negative/invalid',
    () {
      for (final v in ['0', '12.5', '12,5', ' 20000 ']) {
        expect(Validators.price(v), isNull);
      }
      expect(Validators.parsePrice('12,5'), 12.5);
      for (final v in [
        '',
        '-1',
        'NaN',
        'Infinity',
        'abc',
        '1,2,3',
        '1e9',
        '9007199254740992',
      ]) {
        expect(Validators.price(v), isNotNull);
      }
    },
  );
  test('Quantity accepts zero and integers only', () {
    for (final v in ['0', '10', ' 3 ']) {
      expect(Validators.quantity(v), isNull);
    }
    for (final v in [
      '',
      '-1',
      '1.5',
      '1,5',
      'Infinity',
      'abc',
      '9007199254740992',
    ]) {
      expect(Validators.quantity(v), isNotNull);
    }
  });
  test('Image extension, size and URL validation', () {
    expect(Validators.image('A.JPG', AppConfig.maxImageBytes), isNull);
    expect(Validators.image('a.png', 1), isNull);
    expect(Validators.image('a.webp', 1), isNull);
    expect(Validators.image('a.heic', 10), isNotNull);
    expect(Validators.image('a.png', 0), isNotNull);
    expect(Validators.image('a.png', AppConfig.maxImageBytes + 1), isNotNull);
    expect(
      Validators.cloudinaryUrl(
        'https://res.cloudinary.com/dqv9sna9b/image/upload/v1/a.png',
      ),
      isTrue,
    );
    for (final v in [
      'http://res.cloudinary.com/dqv9sna9b/image/upload/a.png',
      'https://res.cloudinary.com.evil.test/dqv9sna9b/image/upload/a.png',
      'https://res.cloudinary.com/other/image/upload/a.png',
      'https://res.cloudinary.com/dqv9sna9b/image/upload/',
    ]) {
      expect(Validators.cloudinaryUrl(v), isFalse);
    }
  });
}
