import 'package:flutter_test/flutter_test.dart';
import 'package:classcheck/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns error for empty email', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), 'Enter a valid email');
      expect(Validators.email('missing@'), 'Enter a valid email');
      expect(Validators.email('@no-user.com'), 'Enter a valid email');
    });

    test('returns null for valid email', () {
      expect(Validators.email('test@example.com'), null);
      expect(Validators.email('user.name@domain.co.th'), null);
    });
  });

  group('Validators.password', () {
    test('returns error for empty password', () {
      expect(Validators.password(''), 'Password is required');
      expect(Validators.password(null), 'Password is required');
    });

    test('returns error for short password', () {
      expect(
        Validators.password('12345'),
        'Password must be at least 6 characters',
      );
    });

    test('returns null for valid password', () {
      expect(Validators.password('123456'), null);
      expect(Validators.password('strongPassword!'), null);
    });
  });

  group('Validators.name', () {
    test('returns error for empty name', () {
      expect(Validators.name(''), 'Name is required');
    });

    test('returns error for single character', () {
      expect(Validators.name('A'), 'Name must be at least 2 characters');
    });

    test('returns null for valid name', () {
      expect(Validators.name('John'), null);
    });
  });

  group('Validators.required', () {
    test('returns error for empty value', () {
      expect(Validators.required('', 'Field'), 'Field is required');
      expect(Validators.required('   ', 'Topic'), 'Topic is required');
    });

    test('returns null for non-empty value', () {
      expect(Validators.required('hello'), null);
    });
  });
}
