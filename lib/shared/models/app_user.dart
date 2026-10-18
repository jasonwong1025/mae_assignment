import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'app_user.freezed.dart';

/// The three kinds of user in Grocerly.
/// Saved in Firestore by name, e.g. "storeAdmin".
enum UserRole {
  customer('Customer'),
  storeAdmin('Store Admin'),
  storeWorker('Store Worker');

  const UserRole(this.label);

  /// Name shown to the user, e.g. "Store Admin".
  final String label;
}

/// A user's profile, stored in Firestore at users/{uid}.
/// The password is not here; Firebase Authentication keeps that.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    /// Same id as the Firebase Authentication account.
    required String uid,
    required String name,
    required String email,
    required String phone,
    required UserRole role,

    /// False if HQ deactivated this Store Worker. They cannot sign in.
    @Default(true) bool isActive,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _AppUser;

  const AppUser._();

  /// Reads users/{uid}. An unknown or missing role counts as customer, the
  /// role with the fewest permissions.
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data.string(UserFields.name),
      email: data.string(UserFields.email),
      phone: data.string(UserFields.phone),
      role: data.enumValue(
        UserFields.role,
        UserRole.values,
        fallback: UserRole.customer,
      ),
      isActive: data.boolean(UserFields.isActive, fallback: true),
      createdAt: data.dateTime(UserFields.createdAt),
    );
  }

  /// The fields of a new profile. The uid is the document id, so it is not a
  /// field. `isActive` and `createdAt` are set by HQ and the server, so
  /// `firestore.rules` does not accept them from a sign-up.
  Map<String, dynamic> toFirestore() {
    return {
      UserFields.name: name,
      UserFields.email: email,
      UserFields.phone: phone,
      UserFields.role: role.name,
    };
  }
}
