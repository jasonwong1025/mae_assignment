import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final launcherServiceProvider = Provider<LauncherService>((ref) {
  return LauncherService();
});

/// Wrapper around the url_launcher package: opens other apps on the phone.
/// Methods return false instead of throwing when the phone cannot do it
/// (no maps or phone app, e.g. on a tablet or desktop), so screens can
/// show a message.
class LauncherService {
  /// Opens Google Maps (app or website) with driving directions from the
  /// driver's current location to [address].
  Future<bool> openDirections(String address) {
    return _open(
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': address,
        'travelmode': 'driving',
      }),
    );
  }

  /// Opens the phone's dialer with [phone] filled in. Spaces and dashes
  /// are removed, e.g. "012-345 6789" becomes "0123456789".
  Future<bool> call(String phone) {
    final digits = phone.replaceAll(RegExp('[^0-9+]'), '');
    return _open(Uri(scheme: 'tel', path: digits));
  }

  Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object catch (error) {
      // Show the real error in the debug console.
      debugPrint('Opening $uri failed: $error');
      return false;
    }
  }
}
