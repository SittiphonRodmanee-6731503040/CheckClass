import 'package:flutter_test/flutter_test.dart';
import 'package:classcheck/utils/constants.dart';

void main() {
  group('Constants', () {
    test('moodEmojis has 5 entries', () {
      expect(Constants.moodEmojis.length, 5);
    });

    test('moodLabels has 5 entries', () {
      expect(Constants.moodLabels.length, 5);
    });

    test('mood keys are 1-5', () {
      for (var i = 1; i <= 5; i++) {
        expect(Constants.moodEmojis.containsKey(i), true);
        expect(Constants.moodLabels.containsKey(i), true);
      }
    });

    test('default radius is 100m', () {
      expect(Constants.defaultRadiusMeters, 100.0);
    });

    test('session expiry is 30 minutes', () {
      expect(Constants.sessionExpiryMinutes, 30);
    });
  });
}
