import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:patrol/patrol.dart';

/// Scrolls the widget with [key] into view, then taps it.
///
/// Uses Flutter's own `ensureVisible`, which scrolls whichever scrollable
/// holds the widget, so it works for a button at the bottom of a long list
/// without guessing which list to drag.
Future<void> tapByKey(PatrolIntegrationTester $, String key) async {
  final finder = find.byKey(Key(key), skipOffstage: false);
  await $.tester.ensureVisible(finder);
  await $.pumpAndSettle();
  await $(finder).tap();
}
