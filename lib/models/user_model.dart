enum UserRole { admin, staff, resident }

class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? barangayId;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.barangayId,
    this.isActive = true,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'resident'),
        orElse: () => UserRole.resident,
      ),
      barangayId: map['barangay_id'],
      isActive: map['is_active'] ?? true,
    );
  }

  String get fullName => '$firstName $lastName';
}
