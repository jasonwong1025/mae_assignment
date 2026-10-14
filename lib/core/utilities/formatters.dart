/// Turns numbers and times into the text shown on screen, so every page
/// formats them the same way.
class Formatters {
  Formatters._();

  /// 2384 will become "RM 2,384".
  static String ringgit(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      // Add a comma before every group of three digits, except at the start.
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return 'RM $buffer';
  }

  /// Price with cents: 86.4 becomes "RM 86.40".
  static String money(double amount) {
    final cents = (amount * 100).round();
    final sen = (cents % 100).toString().padLeft(2, '0');
    return '${ringgit(cents ~/ 100)}.$sen';
  }

  /// Hour on a 24-hour clock to "8am", "12pm", "10pm".
  static String hour(int hour24) {
    final suffix = hour24 % 24 < 12 ? 'am' : 'pm';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12$suffix';
  }

  /// Time of day as "6:48pm".
  static String time(DateTime time) {
    final suffix = time.hour < 12 ? 'am' : 'pm';
    final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour12:$minute$suffix';
  }

  /// Date as "12 Mar 2025".
  static String date(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Metres as "850 m" or "2.1 km".
  static String distance(double metres) {
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  /// 4 becomes "4m", 132 becomes "2h 12m".
  static String minutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }
}
