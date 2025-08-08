/// Utility functions for date and time formatting
class DateTimeUtils {
  /// Parses UTC time string and converts to local time in 12-hour format
  ///
  /// Input format: 2022-08-28T19:55:54Z
  /// Output format: 7:55PM (28/8) or 12:30AM (29/8)
  static String parseTime(String time) {
    // String is in UTC time, with format 2022-08-28T19:55:54Z
    final DateTime dt = DateTime.parse(time).toLocal();

    // 24-Hour time to 12-hour
    if (dt.hour == 0) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM (${dt.day}/${dt.month})";
    }
    if (dt.hour == 12) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM (${dt.day}/${dt.month})";
    } else if (dt.hour < 12) {
      return "${dt.hour}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM (${dt.day}/${dt.month})";
    } else {
      return "${dt.hour - 12}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM (${dt.day}/${dt.month})";
    }
  }

  /// Parses UTC time string and returns DateTime object for comparison
  static DateTime? parseTimeToDateTime(String time) {
    try {
      return DateTime.parse(time).toLocal();
    } catch (e) {
      return null;
    }
  }

  /// Parses UTC time string and converts to local time in 12-hour format without date
  ///
  /// Input format: 2022-08-28T19:55:54Z
  /// Output format: 7:55PM or 12:30AM
  static String parseTimeOnly(String time) {
    // String is in UTC time, with format 2022-08-28T19:55:54Z
    final DateTime dt = DateTime.parse(time).toLocal();

    // 24-Hour time to 12-hour
    if (dt.hour == 0) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM";
    }
    if (dt.hour == 12) {
      return "12:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM";
    } else if (dt.hour < 12) {
      return "${dt.hour}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}AM";
    } else {
      return "${dt.hour - 12}:${dt.minute < 10 ? "0${dt.minute}" : dt.minute}PM";
    }
  }
}
