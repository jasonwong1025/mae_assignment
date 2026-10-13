import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';

void main() {
  test('ringgit adds commas', () {
    expect(Formatters.ringgit(0), 'RM 0');
    expect(Formatters.ringgit(640), 'RM 640');
    expect(Formatters.ringgit(2384), 'RM 2,384');
    expect(Formatters.ringgit(1234567), 'RM 1,234,567');
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

  test('minutes switches to hours after 59', () {
    expect(Formatters.minutes(4), '4m');
    expect(Formatters.minutes(132), '2h 12m');
  });
}
