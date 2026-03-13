class Constants {
  // GPS
  static const double defaultRadiusMeters = 100.0;
  static const double wideRadiusMeters = 300.0;

  // Session expiry (minutes after class end)
  static const int sessionExpiryMinutes = 30;

  // Mood labels and emojis
  static const Map<int, String> moodEmojis = {
    1: '😡',
    2: '🙁',
    3: '😐',
    4: '🙂',
    5: '😄',
  };

  static const Map<int, String> moodLabels = {
    1: 'Very Negative',
    2: 'Negative',
    3: 'Neutral',
    4: 'Positive',
    5: 'Very Positive',
  };

  // Firestore collections
  static const String usersCollection = 'users';
  static const String classesCollection = 'classes';
  static const String sessionsCollection = 'sessions';
  static const String attendanceCollection = 'attendance';
}
