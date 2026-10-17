import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firebase_emulators.dart';

void main() {
  test('connect() refuses to touch the real project during tests', () {
    // Tests run with the flag off, so connect() must hard-stop rather than
    // silently reach the shared project.
    expect(FirebaseEmulators.enabled, isFalse);
    expect(FirebaseEmulators.connect, throwsStateError);
  });
}
