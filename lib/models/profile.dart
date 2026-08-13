/// Mirrors the `profiles` table. `role` and `firmId` drive RLS-aligned
/// access control on the Flutter side (UI gating) — the real enforcement
/// always happens in Postgres via RLS, this is just for UI decisions.
enum UserRole { superAdmin, ca, staff, client }

UserRole userRoleFromString(String value) {
  switch (value) {
    case 'super_admin':
      return UserRole.superAdmin;
    case 'ca':
      return UserRole.ca;
    case 'staff':
      return UserRole.staff;
    case 'client':
      return UserRole.client;
    default:
      throw ArgumentError('Unknown role: $value');
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.superAdmin:
      return 'super_admin';
    case UserRole.ca:
      return 'ca';
    case UserRole.staff:
      return 'staff';
    case UserRole.client:
      return 'client';
  }
}

class Profile {
  const Profile({
    required this.id,
    required this.authUserId,
    required this.role,
    this.fullName,
    this.email,
    this.phone,
    this.profileImage,
    this.firmId,
    this.isActive = true,
  });

  final String id;
  final String authUserId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileImage;
  final UserRole role;
  final String? firmId;
  final bool isActive;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      authUserId: map['auth_user_id'] as String,
      fullName: map['full_name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      profileImage: map['profile_image'] as String?,
      role: userRoleFromString(map['role'] as String),
      firmId: map['firm_id'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'auth_user_id': authUserId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': userRoleToString(role),
      'firm_id': firmId,
    };
  }
}
