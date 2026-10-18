import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show TestFailure, find;
import 'package:patrol/patrol.dart';

/// `waitUntilExists`, but a timeout reports what the screen
/// showed instead (e.g. an error message or a spinner with no text), so a
/// failure on CI explains itself without a screenshot.
Future<void> waitForWidget(
  PatrolIntegrationTester $,
  PatrolFinder finder, {
  Duration? timeout,
}) async {
  try {
    await $.waitUntilExists(finder, timeout: timeout);
  } on Object catch (error) {
    throw TestFailure(
      'Timed out waiting for ${finder.description}.\n'
      'Screen text: ${_screenText()}\n'
      '($error)',
    );
  }
}

/// Every distinct piece of text currently in the widget tree.
String _screenText() {
  final texts = <String>{
    for (final element in find.byType(Text).evaluate())
      if (element.widget case final Text text)
        if ((text.data ?? text.textSpan?.toPlainText())?.trim()
            case final value? when value.isNotEmpty)
          value,
  };
  return texts.isEmpty ? '(none, maybe still loading)' : texts.join(' | ');
}
