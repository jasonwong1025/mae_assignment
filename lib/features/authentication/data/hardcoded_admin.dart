import 'package:mae_assignment/shared/models/app_user.dart';

/// Temporary admin login while the admin screens are built UI-first.
/// It skips Firebase completely, so it works without a real account.
// TODO(team): delete this file once admin accounts come from the backend.
class HardcodedAdmin {
  HardcodedAdmin._();

  static const String email = 'grocerlyadmin@gmail.com';
  static const String password = 'grocerlyadmin123';

  /// The profile the app uses while this admin is signed in.
  static const AppUser user = AppUser(
    uid: 'hardcoded-admin',
    name: 'Grocerly Admin',
    email: email,
    phone: '',
    role: UserRole.storeAdmin,
  );

  /// True if the typed email and password are the admin's.
  /// The email check ignores capital letters and spaces around it.
  static bool matches(String typedEmail, String typedPassword) {
    return typedEmail.trim().toLowerCase() == email &&
        typedPassword == password;
  }
}
