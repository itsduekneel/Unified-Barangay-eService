class ProfileData {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? birthDate;
  final String? gender;
  final String? citizenship;
  final String? email;
  final String? country;
  final String? stateProvince;
  final String? cityMunicipality;
  final String? barangay;
  final String? streetAddress;
  final String? postalCode;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final bool isActive; // Idagdag natin ito para sa status filter

  const ProfileData({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.citizenship,
    this.email,
    this.country,
    this.stateProvince,
    this.cityMunicipality,
    this.barangay,
    this.streetAddress,
    this.postalCode,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      middleName: map['middle_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      birthDate: map['birth_date']?.toString(),
      gender: map['gender']?.toString(),
      citizenship: map['citizenship']?.toString(),
      email: map['email']?.toString(),
      country: map['country']?.toString(),
      stateProvince: map['state_province']?.toString(),
      cityMunicipality: map['city_municipality']?.toString(),
      barangay: map['barangay']?.toString(),
      streetAddress: map['street_address']?.toString(),
      postalCode: map['postal_code']?.toString(),
      role: map['role']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      isActive: map['is_active'] ?? true,
    );
  }

  String get fullName =>
      [firstName, middleName, lastName].where((p) => p.isNotEmpty).join(' ');

  String get initials {
    final parts = [firstName, lastName.isNotEmpty ? lastName : middleName];
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }
}
