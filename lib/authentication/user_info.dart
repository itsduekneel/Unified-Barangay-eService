class UserInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String email;
  final String birthDate;
  final String gender;
  final String password;

  // Address
  final String country;
  final String stateProvince;
  final String cityMunicipality;
  final String barangay;
  final String streetAddress;
  final String addressLine2;
  final String postalCode;

  const UserInfo({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.password,
    required this.country,
    required this.stateProvince,
    required this.cityMunicipality,
    required this.barangay,
    required this.streetAddress,
    this.addressLine2 = '',
    this.postalCode = '',
  });

  UserInfo copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? email,
    String? birthDate,
    String? gender,
    String? password,
    String? country,
    String? stateProvince,
    String? cityMunicipality,
    String? barangay,
    String? streetAddress,
    String? addressLine2,
    String? postalCode,
  }) {
    return UserInfo(
      firstName:        firstName        ?? this.firstName,
      middleName:       middleName       ?? this.middleName,
      lastName:         lastName         ?? this.lastName,
      suffix:           suffix           ?? this.suffix,
      email:            email            ?? this.email,
      birthDate:        birthDate        ?? this.birthDate,
      gender:           gender           ?? this.gender,
      password:         password         ?? this.password,
      country:          country          ?? this.country,
      stateProvince:    stateProvince    ?? this.stateProvince,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      barangay:         barangay         ?? this.barangay,
      streetAddress:    streetAddress    ?? this.streetAddress,
      addressLine2:     addressLine2     ?? this.addressLine2,
      postalCode:       postalCode       ?? this.postalCode,
    );
  }

  /// Converts profile data to a map for Supabase insert (excludes password).
  Map<String, dynamic> toSupabaseMap(String userId) {
    return {
      'id':                userId,
      'first_name':        firstName,
      'middle_name':       middleName,
      'last_name':         lastName,
      'suffix':            suffix,
      'email':             email,
      'birth_date':        birthDate,
      'gender':            gender,
      'country':           country,
      'state_province':    stateProvince,
      'city_municipality': cityMunicipality,
      'barangay':          barangay,
      'street_address':    streetAddress,
      'address_line2':     addressLine2,
      'postal_code':       postalCode,
      'is_active':         true,
      'role':              'Resident',
    };
  }
}
