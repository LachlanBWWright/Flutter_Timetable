/// Application constants
class AppConstants {
  // App Information
  static const String appTitle = 'NSW Trains Timetable';
  
  // Database
  static const String databaseName = 'trip_database.db';
  static const String journeysTable = 'journeys';
  
  // API
  static const String apiBaseUrl = 'api.transport.nsw.gov.au';
  static const String apiVersion = '10.2.1.42';
  
  // Shared Preferences Keys
  static const String apiKeyPref = 'apiKey';
  
  // UI Constants
  static const double defaultPadding = 8.0;
  static const double defaultMargin = 1.0;
  
  // Transport Mode Colors (ARGB)
  static const int trainColor = 0xFFFF6123;      // Orange
  static const int lightRailColor = 0xFFFF5252;  // Red
  static const int busColor = 0xFF52BAFF;        // Blue  
  static const int coachColor = 0xFFA1542F;      // Brown
  static const int ferryColor = 0xFF44F05B;      // Green
  static const int defaultColor = 0xFFFFFFFF;    // White
  
  // Error Messages
  static const String apiKeyNotSet = 'API key not set';
  static const String noApiKeyMessage = 'Your API key has not been set';
  static const String apiKeyInstructions = 
      'How to set API key: Go to Transport for NSW\'s OpenData page, create an account, '
      'hover over \'My Account\', select \'Applications\', and create an application.';
  static const String apiPermissionsMessage =
      'You\'ll need to give the application access to the following APIs: '
      '\'Trip Planner APIs\', \'Public Transport - Timetables - For Realtime\'.';
}