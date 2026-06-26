/// Application constants
class AppConstants {
  // App Information
  static const String appTitle = 'NSW Trains Timetable';

  // Database
  static const String databaseName = 'trip_database.db';
  static const String journeysTable = 'journeys';

  // Shared Preferences Keys
  static const String apiKeyPref = 'apiKey';

  // UI Constants
  static const double defaultPadding = 8.0;
  static const double defaultMargin = 1.0;

  // Transport Mode Colors (ARGB)
  static const int trainColor = 0xFFFF6123; // Orange
  static const int lightRailColor = 0xFFFF5252; // Red
  static const int busColor = 0xFF52BAFF; // Blue
  static const int coachColor = 0xFFA1542F; // Brown
  static const int ferryColor = 0xFF44F05B; // Green
  static const int defaultColor = 0xFFFFFFFF; // White

}
