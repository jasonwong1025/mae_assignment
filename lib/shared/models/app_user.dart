import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

/// The three kinds of user in Grocerly.
/// Saved in Firestore by name, e.g. "storeAdmin".
enum UserRole {
  customer('Customer'),
  storeAdmin('Store Admin'),
  storeWorker('Store Worker');

  const UserRole(this.label);

  /// Name shown to the user, e.g. "Store Admin".
  final String label;

  /// Turns the saved text back into a role. Unknown text counts as customer,
  /// the role with the fewest permissions.
  static UserRole fromName(String? name) {
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return UserRole.customer;
  }
}

/// A user's profile, stored in Firestore at users/{uid}.
/// The password is not here; Firebase Authentication keeps that.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    final createdAt = map[UserFields.createdAt];

    return AppUser(
      uid: uid,
      name: map[UserFields.name] as String? ?? '',
      email: map[UserFields.email] as String? ?? '',
      phone: map[UserFields.phone] as String? ?? '',
      role: UserRole.fromName(map[UserFields.role] as String?),
      isActive: map[UserFields.isActive] as bool? ?? true,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  /// Same id as the Firebase Authentication account.
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  /// False if HQ deactivated this Store Worker. They cannot sign in.
  final bool isActive;

  /// Null until Firestore has saved the server time.
  final DateTime? createdAt;

  /// Data for a new users/{uid} document. The uid is the document id,
  /// so it is not saved as a field.
  Map<String, dynamic> toMap() {
    return {
      UserFields.name: name,
      UserFields.email: email,
      UserFields.phone: phone,
      UserFields.role: role.name,
      UserFields.createdAt: FieldValue.serverTimestamp(),
    };
  }
}
