class UserInfo {
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String emailAddress;
  final String dateOfBirth;
  final String gender;
  final String password;

  // Address
  final String country;
  final String stateProvince;
  final String cityMunicipality;
  final String barangay;
  final String houseStreet;
  final String addressLine2;
  final String postalCode;

  const UserInfo({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.emailAddress,
    required this.dateOfBirth,
    required this.gender,
    required this.password,
    required this.country,
    required this.stateProvince,
    required this.cityMunicipality,
    required this.barangay,
    required this.houseStreet,
    this.addressLine2 = '',
    this.postalCode = '',
  });

  UserInfo copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    String? emailAddress,
    String? dateOfBirth,
    String? gender,
    String? password,
    String? country,
    String? stateProvince,
    String? cityMunicipality,
    String? barangay,
    String? houseStreet,
    String? addressLine2,
    String? postalCode,
  }) {
    return UserInfo(
      firstName:        firstName        ?? this.firstName,
      middleName:       middleName       ?? this.middleName,
      lastName:         lastName         ?? this.lastName,
      suffix:           suffix           ?? this.suffix,
      emailAddress:     emailAddress     ?? this.emailAddress,
      dateOfBirth:      dateOfBirth      ?? this.dateOfBirth,
      gender:           gender           ?? this.gender,
      password:         password         ?? this.password,
      country:          country          ?? this.country,
      stateProvince:    stateProvince    ?? this.stateProvince,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      barangay:         barangay         ?? this.barangay,
      houseStreet:      houseStreet      ?? this.houseStreet,
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
      'email':             emailAddress,
      'date_of_birth':     dateOfBirth,
      'gender':            gender,
      'country':           country,
      'state_province':    stateProvince,
      'city_municipality': cityMunicipality,
      'barangay':          barangay,
      'house_street':      houseStreet,
      'address_line2':     addressLine2,
      'postal_code':       postalCode,
    };
  }
}
