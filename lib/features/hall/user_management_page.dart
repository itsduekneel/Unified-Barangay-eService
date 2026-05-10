// ============================================================================
// lib/features/hall/user_management_page.dart
// Barangay Hall: User Management Module (Supabase)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

// ============================================================================
// MODEL
// ============================================================================

class ProfileModel {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final DateTime birthDate;
  final String gender;
  final String citizenship;
  final String email;
  final String country;
  final String stateProvince;
  final String cityMunicipality;
  final String barangay;
  final String streetAddress;
  final String? postalCode;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    required this.birthDate,
    required this.gender,
    required this.citizenship,
    required this.email,
    required this.country,
    required this.stateProvince,
    required this.cityMunicipality,
    required this.barangay,
    required this.streetAddress,
    this.postalCode,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    final parts = [
      firstName,
      if (middleName != null && middleName!.isNotEmpty) middleName,
      lastName,
      if (suffix != null && suffix!.isNotEmpty) suffix,
    ];
    return parts.join(' ');
  }

  bool get isStaff => role != 'resident' && role != 'unknown';

  /// Returns a copy with updated fields
  ProfileModel copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    DateTime? birthDate,
    String? gender,
    String? citizenship,
    String? email,
    String? country,
    String? stateProvince,
    String? cityMunicipality,
    String? barangay,
    String? streetAddress,
    String? postalCode,
    String? role,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      citizenship: citizenship ?? this.citizenship,
      email: email ?? this.email,
      country: country ?? this.country,
      stateProvince: stateProvince ?? this.stateProvince,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      barangay: barangay ?? this.barangay,
      streetAddress: streetAddress ?? this.streetAddress,
      postalCode: postalCode ?? this.postalCode,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    firstName: json['first_name'] as String,
    middleName: json['middle_name'] as String?,
    lastName: json['last_name'] as String,
    suffix: json['suffix'] as String?,
    birthDate: DateTime.parse(json['birth_date'] as String),
    gender: json['gender'] as String,
    citizenship: json['citizenship'] as String,
    email: json['email'] as String,
    country: json['country'] as String,
    stateProvince: json['state_province'] as String,
    cityMunicipality: json['city_municipality'] as String,
    barangay: json['barangay'] as String,
    streetAddress: json['street_address'] as String,
    postalCode: json['postal_code'] as String?,
    role: json['role'] as String? ?? 'unknown',
    isActive: json['is_active'] as bool? ?? true,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

// ============================================================================
// SERVICE
// ============================================================================

class ProfileService {
  static final _db = Supabase.instance.client;

  /// Fetch all staff (role is NOT 'resident' or 'unknown')
  static Future<List<ProfileModel>> getStaff() async {
    final data = await _db
        .from('profiles')
        .select()
        .not('role', 'eq', 'resident')
        .not('role', 'eq', 'unknown')
        .order('last_name', ascending: true);
    return (data as List<dynamic>)
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch all residents
  static Future<List<ProfileModel>> getResidents() async {
    final data = await _db
        .from('profiles')
        .select()
        .eq('role', 'resident')
        .order('last_name', ascending: true);
    return (data as List<dynamic>)
        .map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new staff profile
  static Future<void> createStaff(Map<String, dynamic> payload) async {
    await _db.from('profiles').insert(payload);
  }

  /// Toggle is_active status
  static Future<void> updateStatus(String id, bool isActive) async {
    await _db.from('profiles').update({'is_active': isActive}).eq('id', id);
  }

  /// Update profile fields
  static Future<void> updateProfile(
    String id,
    Map<String, dynamic> payload,
  ) async {
    await _db
        .from('profiles')
        .update({...payload, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  /// Delete a profile by id
  static Future<void> deleteProfile(String id) async {
    await _db.from('profiles').delete().eq('id', id);
  }
}

// ============================================================================
// HELPERS
// ============================================================================

String _fmtDate(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';


const _kGenderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
const _kStaffRoles = [
  'Barangay Captain',
  'Barangay Secretary',
  'Barangay Treasurer',
  'Barangay Tanod',
  'Social Worker',
  'Health Worker',
  'Clerk',
  'IT Officer',
  'Other',
];

// ============================================================================
// PAGE
// ============================================================================

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<ProfileModel> _staff = [];
  List<ProfileModel> _residents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        ProfileService.getStaff(),
        ProfileService.getResidents(),
      ]);
      if (mounted) {
        setState(() {
          _staff = results[0];
          _residents = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load users: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<ProfileModel> get _filteredStaff => _staff.where((s) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return s.fullName.toLowerCase().contains(q) ||
        s.role.toLowerCase().contains(q) ||
        s.email.toLowerCase().contains(q) ||
        s.barangay.toLowerCase().contains(q) ||
        s.cityMunicipality.toLowerCase().contains(q);
  }).toList();

  List<ProfileModel> get _filteredResidents => _residents.where((r) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return r.fullName.toLowerCase().contains(q) ||
        r.email.toLowerCase().contains(q) ||
        r.barangay.toLowerCase().contains(q) ||
        r.cityMunicipality.toLowerCase().contains(q);
  }).toList();

  // --------------------------------------------------------------------------
  // ADD STAFF — Full form dialog
  // --------------------------------------------------------------------------

  void _showAddStaffDialog() {
    final firstCtrl = TextEditingController();
    final middleCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final suffixCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final barangayCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: 'Philippines');
    final streetCtrl = TextEditingController();
    final postalCtrl = TextEditingController();
    final citizenshipCtrl = TextEditingController(text: 'Filipino');
    String selectedGender = 'Male';
    String selectedRole = _kStaffRoles.first;
    DateTime selectedBirthDate = DateTime(1990, 1, 1);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: _kPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Add Staff Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Personal Information'),
                    _ValidatedField(
                      ctrl: firstCtrl,
                      label: 'First Name *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: middleCtrl, label: 'Middle Name (optional)'),
                    const SizedBox(height: 8),
                    _ValidatedField(
                      ctrl: lastCtrl,
                      label: 'Last Name *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: suffixCtrl, label: 'Suffix (Jr., Sr., etc.)'),
                    const SizedBox(height: 8),
                    // Birth Date picker
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedBirthDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: _kPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedBirthDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _kBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              size: 16,
                              color: _kPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Birth Date: ${_fmtDate(selectedBirthDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Gender dropdown
                    _DropdownField<String>(
                      label: 'Gender',
                      value: selectedGender,
                      items: _kGenderOptions,
                      onChanged: (v) =>
                          setDialogState(() => selectedGender = v!),
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: citizenshipCtrl, label: 'Citizenship'),
                    const SizedBox(height: 12),
                    _sectionLabel('Account'),
                    _ValidatedField(
                      ctrl: emailCtrl,
                      label: 'Email *',
                      validator: _requiredEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    // Role dropdown
                    _DropdownField<String>(
                      label: 'Role',
                      value: selectedRole,
                      items: _kStaffRoles,
                      onChanged: (v) => setDialogState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Address'),
                    _Field(ctrl: streetCtrl, label: 'Street Address'),
                    const SizedBox(height: 8),
                    _ValidatedField(
                      ctrl: barangayCtrl,
                      label: 'Barangay *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: cityCtrl, label: 'City / Municipality'),
                    const SizedBox(height: 8),
                    _Field(ctrl: stateCtrl, label: 'State / Province'),
                    const SizedBox(height: 8),
                    _Field(ctrl: countryCtrl, label: 'Country'),
                    const SizedBox(height: 8),
                    _Field(ctrl: postalCtrl, label: 'Postal Code'),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                try {
                  // NOTE: 'id' must come from auth.users (Supabase Auth).
                  // In a real flow, create user via Admin API or invite,
                  // then insert into profiles using the returned user id.
                  await ProfileService.createStaff({
                    // 'id': <uuid from auth.users>,  // required FK
                    'first_name': firstCtrl.text.trim(),
                    'middle_name': middleCtrl.text.trim().isEmpty
                        ? null
                        : middleCtrl.text.trim(),
                    'last_name': lastCtrl.text.trim(),
                    'suffix': suffixCtrl.text.trim().isEmpty
                        ? null
                        : suffixCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'role': selectedRole,
                    'gender': selectedGender,
                    'birth_date': _fmtDate(selectedBirthDate),
                    'citizenship': citizenshipCtrl.text.trim().isEmpty
                        ? 'Filipino'
                        : citizenshipCtrl.text.trim(),
                    'barangay': barangayCtrl.text.trim(),
                    'city_municipality': cityCtrl.text.trim(),
                    'state_province': stateCtrl.text.trim(),
                    'country': countryCtrl.text.trim().isEmpty
                        ? 'Philippines'
                        : countryCtrl.text.trim(),
                    'street_address': streetCtrl.text.trim(),
                    'postal_code': postalCtrl.text.trim().isEmpty
                        ? null
                        : postalCtrl.text.trim(),
                    'is_active': true,
                  });
                  _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Staff account created!'),
                        backgroundColor: _kPrimary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // TOGGLE STATUS
  // --------------------------------------------------------------------------

  void _showToggleStatusDialog(ProfileModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          p.isActive ? 'Deactivate Account' : 'Activate Account',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${p.isActive ? 'Deactivate' : 'Activate'} account for ${p.fullName}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProfileService.updateStatus(p.id, !p.isActive);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              p.isActive ? 'Deactivate' : 'Activate',
              style: TextStyle(
                color: p.isActive
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // DELETE
  // --------------------------------------------------------------------------

  void _showDeleteDialog(ProfileModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Profile',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Permanently delete "${p.fullName}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProfileService.deleteProfile(p.id);
                _load();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${p.fullName} deleted.'),
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // EDIT PROFILE — Full form bottom sheet
  // --------------------------------------------------------------------------

  void _showEditDialog(ProfileModel p) {
    final firstCtrl = TextEditingController(text: p.firstName);
    final middleCtrl = TextEditingController(text: p.middleName ?? '');
    final lastCtrl = TextEditingController(text: p.lastName);
    final suffixCtrl = TextEditingController(text: p.suffix ?? '');
    final emailCtrl = TextEditingController(text: p.email);
    final barangayCtrl = TextEditingController(text: p.barangay);
    final cityCtrl = TextEditingController(text: p.cityMunicipality);
    final stateCtrl = TextEditingController(text: p.stateProvince);
    final countryCtrl = TextEditingController(text: p.country);
    final streetCtrl = TextEditingController(text: p.streetAddress);
    final postalCtrl = TextEditingController(text: p.postalCode ?? '');
    final citizenshipCtrl = TextEditingController(text: p.citizenship);

    String selectedGender = _kGenderOptions.contains(p.gender)
        ? p.gender
        : _kGenderOptions.first;
    String selectedRole = _kStaffRoles.contains(p.role)
        ? p.role
        : _kStaffRoles.last;
    DateTime selectedBirthDate = p.birthDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: _kPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Personal Information'),
                    _ValidatedField(
                      ctrl: firstCtrl,
                      label: 'First Name *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: middleCtrl, label: 'Middle Name (optional)'),
                    const SizedBox(height: 8),
                    _ValidatedField(
                      ctrl: lastCtrl,
                      label: 'Last Name *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: suffixCtrl, label: 'Suffix (Jr., Sr., etc.)'),
                    const SizedBox(height: 8),
                    // Birth Date picker
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedBirthDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: _kPrimary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedBirthDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _kBorder),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake_outlined,
                              size: 16,
                              color: _kPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Birth Date: ${_fmtDate(selectedBirthDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DropdownField<String>(
                      label: 'Gender',
                      value: selectedGender,
                      items: _kGenderOptions,
                      onChanged: (v) =>
                          setDialogState(() => selectedGender = v!),
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: citizenshipCtrl, label: 'Citizenship'),
                    const SizedBox(height: 12),
                    _sectionLabel('Account'),
                    _ValidatedField(
                      ctrl: emailCtrl,
                      label: 'Email *',
                      validator: _requiredEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    _DropdownField<String>(
                      label: 'Role',
                      value: selectedRole,
                      items: _kStaffRoles,
                      onChanged: (v) => setDialogState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 12),
                    _sectionLabel('Address'),
                    _Field(ctrl: streetCtrl, label: 'Street Address'),
                    const SizedBox(height: 8),
                    _ValidatedField(
                      ctrl: barangayCtrl,
                      label: 'Barangay *',
                      validator: _required,
                    ),
                    const SizedBox(height: 8),
                    _Field(ctrl: cityCtrl, label: 'City / Municipality'),
                    const SizedBox(height: 8),
                    _Field(ctrl: stateCtrl, label: 'State / Province'),
                    const SizedBox(height: 8),
                    _Field(ctrl: countryCtrl, label: 'Country'),
                    const SizedBox(height: 8),
                    _Field(ctrl: postalCtrl, label: 'Postal Code'),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                try {
                  await ProfileService.updateProfile(p.id, {
                    'first_name': firstCtrl.text.trim(),
                    'middle_name': middleCtrl.text.trim().isEmpty
                        ? null
                        : middleCtrl.text.trim(),
                    'last_name': lastCtrl.text.trim(),
                    'suffix': suffixCtrl.text.trim().isEmpty
                        ? null
                        : suffixCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'role': selectedRole,
                    'gender': selectedGender,
                    'birth_date': _fmtDate(selectedBirthDate),
                    'citizenship': citizenshipCtrl.text.trim(),
                    'barangay': barangayCtrl.text.trim(),
                    'city_municipality': cityCtrl.text.trim(),
                    'state_province': stateCtrl.text.trim(),
                    'country': countryCtrl.text.trim(),
                    'street_address': streetCtrl.text.trim(),
                    'postal_code': postalCtrl.text.trim().isEmpty
                        ? null
                        : postalCtrl.text.trim(),
                  });
                  _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated!'),
                        backgroundColor: _kPrimary,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // PROFILE DETAIL — Full info bottom sheet
  // --------------------------------------------------------------------------

  void _showProfileSheet(ProfileModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProfileDetailSheet(
        profile: p,
        onEdit: () {
          Navigator.pop(context);
          _showEditDialog(p);
        },
        onToggle: () {
          Navigator.pop(context);
          _showToggleStatusDialog(p);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteDialog(p);
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _kPrimary, size: 22),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(
              Icons.person_add_outlined,
              color: _kPrimary,
              size: 22,
            ),
            onPressed: _showAddStaffDialog,
            tooltip: 'Add Staff',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _kPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kPrimary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Staff'),
            Tab(text: 'Residents'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : _errorMessage != null
          ? _buildError()
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, role, email, location...',
                      hintStyle: const TextStyle(
                        color: _kPrimary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: _kPrimary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: _kPrimary,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _kPrimaryLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [_buildStaffTab(), _buildResidentTab()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 13, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STAFF TAB
  // --------------------------------------------------------------------------

  Widget _buildStaffTab() {
    final staff = _filteredStaff;
    final activeCount = _staff.where((s) => s.isActive).length;

    if (staff.isEmpty) return _buildEmpty('No staff found');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${staff.length} staff  ·  ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$activeCount active',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: staff.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _StaffCard(
              profile: staff[i],
              onTap: () => _showProfileSheet(staff[i]),
              onToggle: () => _showToggleStatusDialog(staff[i]),
              onEdit: () => _showEditDialog(staff[i]),
              onDelete: () => _showDeleteDialog(staff[i]),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // RESIDENT TAB
  // --------------------------------------------------------------------------

  Widget _buildResidentTab() {
    final residents = _filteredResidents;
    final activeCount = _residents.where((r) => r.isActive).length;

    if (residents.isEmpty) return _buildEmpty('No residents found');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${residents.length} residents  ·  ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$activeCount active',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: residents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _ResidentCard(
              profile: residents[i],
              onTap: () => _showProfileSheet(residents[i]),
              onEdit: () => _showEditDialog(residents[i]),
              onDelete: () => _showDeleteDialog(residents[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PROFILE DETAIL BOTTOM SHEET
// ============================================================================

class _ProfileDetailSheet extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProfileDetailSheet({
    required this.profile,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'User Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          _infoTile('Full Name', p.fullName),
          _infoTile('Role', p.role),
          _infoTile('Email', p.email),
          _infoTile('Barangay', p.barangay),
          _infoTile('Address', '${p.streetAddress}, ${p.cityMunicipality}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.isActive ? Colors.orange : Colors.green,
                  ),
                  onPressed: onToggle,
                  child: Text(
                    p.isActive ? 'Deactivate' : 'Activate',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: onDelete,
                  child: const Text(
                    'Delete User',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}


// ============================================================================
// REUSABLE CARD WIDGETS
// ============================================================================

class _StaffCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StaffCard({
    required this.profile,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: _kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    profile.role,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    profile.email,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    profile.barangay,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(isActive: profile.isActive),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Toggle button
                    GestureDetector(
                      onTap: onToggle,
                      child: Text(
                        profile.isActive ? 'Deactivate' : 'Activate',
                        style: TextStyle(
                          fontSize: 10,
                          color: profile.isActive
                              ? const Color(0xFFDC2626)
                              : _kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Delete button
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ResidentCard({
    required this.profile,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = profile.gender.toLowerCase() == 'female';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isFemale ? const Color(0xFFFFF0F5) : _kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: isFemale ? const Color(0xFFDB2777) : _kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${profile.barangay} · ${profile.cityMunicipality}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    profile.email,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    profile.gender,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(isActive: profile.isActive),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEDFAF3) : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}


// ============================================================================
// FORM FIELD WIDGETS
// ============================================================================

/// Simple optional text field
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType keyboardType;

  const _Field({
    required this.ctrl,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
    );
  }
}

/// Validated required text field
class _ValidatedField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? Function(String?) validator;
  final TextInputType keyboardType;

  const _ValidatedField({
    required this.ctrl,
    required this.label,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
    );
  }
}

/// Dropdown field
class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString(), style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
    );
  }
}

// ============================================================================
// VALIDATORS
// ============================================================================

String? _required(String? v) {
  if (v == null || v.trim().isEmpty) return 'This field is required';
  return null;
}

String? _requiredEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Email is required';
  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
  return null;
}

// ============================================================================
// MISC
// ============================================================================

Widget _sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kPrimary,
          ),
        ),
      ],
    ),
  );
}
