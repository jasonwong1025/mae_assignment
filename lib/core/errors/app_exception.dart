import 'package:flutter/foundation.dart';

/// Base class for every error the app shows to a person.
///
/// [message] is always safe to put on screen: it never contains a stack
/// trace, a Firestore error code or a raw exception. Each feature declares
/// its own subtype (for example `AddressException`) so callers can catch one
/// feature's errors without catching another's, but they all share this
/// shape and the single [guard] below.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The message used when the backend cannot be reached.
const String kNetworkErrorMessage =
    'Could not reach the server. Please check your connection and try again.';

/// Runs [call] and turns any failure into a friendly exception.
///
/// - An [AppException] thrown by [call] passes through untouched, so
///   validation errors keep their own message.
/// - Anything else (Firestore, network, parsing) is logged with [label] and
///   replaced by [onError], so raw errors never reach the screen.
///
/// Every repository uses this one helper instead of its own try/catch, so
/// error handling and logging behave the same everywhere.
Future<T> guard<T>(
  Future<T> Function() call, {
  required AppException Function() onError,
  String label = 'request',
}) async {
  try {
    return await call();
  } on AppException {
    rethrow;
  } on Object catch (error) {
    debugPrint('[$label] failed: $error');
    throw onError();
  }
}
