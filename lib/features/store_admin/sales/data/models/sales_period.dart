/// Preset periods on the Sales tab. "Custom" is a [SalesPeriod] with no
/// preset.
enum SalesPreset {
  today('Today'),
  last7Days('Last 7 days'),
  last30Days('Last 30 days');

  const SalesPreset(this.label);

  final String label;
}

/// How the chart groups sales.
enum SalesGrouping { hour, day, week }

/// The days the Sales tab reports on, from [start] up to (not including)
/// [end]. Both are at midnight.
class SalesPeriod {
  const SalesPeriod({required this.start, required this.end, this.preset});

  /// A preset period ending today.
  factory SalesPeriod.fromPreset(SalesPreset preset, DateTime now) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final days = switch (preset) {
      SalesPreset.today => 1,
      SalesPreset.last7Days => 7,
      SalesPreset.last30Days => 30,
    };
    return SalesPeriod(
      start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day - days),
      end: tomorrow,
      preset: preset,
    );
  }

  /// A custom period from [first] to [last], both days included.
  factory SalesPeriod.custom(DateTime first, DateTime last) {
    return SalesPeriod(
      start: DateTime(first.year, first.month, first.day),
      end: DateTime(last.year, last.month, last.day + 1),
    );
  }

  /// Longest custom period, in days.
  static const int maxDays = 366;

  final DateTime start;
  final DateTime end;

  /// Null for a custom period.
  final SalesPreset? preset;

  int get days => end.difference(start).inHours ~/ 24;

  /// The period of the same length just before this one, for comparing.
  SalesPeriod get previous {
    return SalesPeriod(
      start: DateTime(start.year, start.month, start.day - days),
      end: start,
    );
  }

  /// 1 day: by hour. Up to 31 days: by day. Longer: by week.
  SalesGrouping get grouping {
    if (days <= 1) return SalesGrouping.hour;
    if (days <= 31) return SalesGrouping.day;
    return SalesGrouping.week;
  }

  bool contains(DateTime time) => !time.isBefore(start) && time.isBefore(end);
}
