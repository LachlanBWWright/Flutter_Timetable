/// Utility functions for date and time formatting
class DateTimeUtils {
  /// Parses UTC time string and converts to local time in 12-hour format
  /// 
  /// Input format: 2022-08-28T19:55:54Z
  /// Output format: 7:55PM (28/8) or 12:30AM (29/8)
  static String parseTime(String time) {
    // String is in UTC time, with format 2022-08-28T19:55:54Z
    DateTime dt = DateTime.parse(time).toLocal();
    
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
}