import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';

void main() {
  test('ringgit adds commas', () {
    expect(Formatters.ringgit(0), 'RM 0');
    expect(Formatters.ringgit(640), 'RM 640');
    expect(Formatters.ringgit(2384), 'RM 2,384');
    expect(Formatters.ringgit(1234567), 'RM 1,234,567');
  });

  test('money always shows two decimals', () {
    expect(Formatters.money(86.4), 'RM 86.40');
    expect(Formatters.money(5), 'RM 5.00');
    expect(Formatters.money(1234.5), 'RM 1,234.50');
    expect(Formatters.money(15.8), 'RM 15.80');
  });

  test('hour uses a 12-hour clock', () {
    expect(Formatters.hour(0), '12am');
    expect(Formatters.hour(8), '8am');
    expect(Formatters.hour(12), '12pm');
    expect(Formatters.hour(22), '10pm');
  });

  test('time shows minutes with two digits', () {
    expect(Formatters.time(DateTime(2026, 1, 1, 18, 48)), '6:48pm');
    expect(Formatters.time(DateTime(2026, 1, 1, 9, 5)), '9:05am');
  });

  test('date is day, short month, year', () {
    expect(Formatters.date(DateTime(2025, 3, 12)), '12 Mar 2025');
    expect(Formatters.date(DateTime(2026, 12)), '1 Dec 2026');
  });

  test('minutes switches to hours after 59', () {
    expect(Formatters.minutes(4), '4m');
    expect(Formatters.minutes(132), '2h 12m');
  });
}
