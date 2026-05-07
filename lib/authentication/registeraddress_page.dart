import 'package:flutter/material.dart';

import 'package:ube/authentication/app_colors.dart';
import 'package:ube/authentication/confirm_registration.dart';
import 'package:ube/authentication/user_info.dart';
import 'package:ube/authentication/route_utils.dart';
import 'package:ube/authentication/widgets/step_indicator.dart';
import 'package:ube/authentication/widgets/form_field_builder.dart';

// ─── ADDRESS SCREEN (Step 2 — Current Address) ───────────────────────────────

class AddressScreen extends StatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String emailAddress;
  final String dateOfBirth;
  final String gender;
  final String password;

  /// When provided, the screen pre-fills all address fields and returns the
  /// updated [UserInfo] via [Navigator.pop] instead of pushing to the
  /// confirmation screen.
  final UserInfo? initialData;

  const AddressScreen({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.suffix,
    required this.emailAddress,
    required this.dateOfBirth,
    required this.gender,
    required this.password,
    this.initialData,
  });

  /// Named constructor for edit mode — pulls all values from an existing [UserInfo].
  AddressScreen.fromUserInfo(UserInfo info, {super.key})
    : firstName = info.firstName,
      middleName = info.middleName,
      lastName = info.lastName,
      suffix = info.suffix,
      emailAddress = info.emailAddress,
      dateOfBirth = info.dateOfBirth,
      gender = info.gender,
      password = info.password,
      initialData = info;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _streetController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _postalController = TextEditingController();

  String? _selectedCountry;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  bool get _isEditing => widget.initialData != null;

  // TODO: Replace with actual data from an API or local JSON file.
  static const _countries = ['Philippines'];
  static const _provinces = ['Laguna', 'Metro Manila', 'Cebu'];
  static const _cities = ['Santa Cruz', 'San Pedro', 'Biñan'];
  static const _barangays = ['Bagumbayan', 'Poblacion', 'San Jose'];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    final d = widget.initialData;
    if (d == null) return;

    _selectedCountry = d.country.isNotEmpty ? d.country : null;
    _selectedProvince = d.stateProvince.isNotEmpty ? d.stateProvince : null;
    _selectedCity = d.cityMunicipality.isNotEmpty ? d.cityMunicipality : null;
    _selectedBarangay = d.barangay.isNotEmpty ? d.barangay : null;
    _streetController.text = d.houseStreet;
    _address2Controller.text = d.addressLine2;
    _postalController.text = d.postalCode;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _streetController.dispose();
    _address2Controller.dispose();
    _postalController.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final userInfo = UserInfo(
      firstName: widget.firstName,
      middleName: widget.middleName,
      lastName: widget.lastName,
      suffix: widget.suffix,
      emailAddress: widget.emailAddress,
      dateOfBirth: widget.dateOfBirth,
      gender: widget.gender,
      password: widget.password,
      country: _selectedCountry!,
      stateProvince: _selectedProvince!,
      cityMunicipality: _selectedCity!,
      barangay: _selectedBarangay!,
      houseStreet: _streetController.text.trim(),
      addressLine2: _address2Controller.text.trim(),
      postalCode: _postalController.text.trim(),
    );

    if (_isEditing) {
      Navigator.pop(context, userInfo);
    } else {
      Navigator.push(
        context,
        instantRoute(ConfirmInfoScreen(userInfo: userInfo)),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          'Current Address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StepIndicator(totalSteps: 3, currentStep: 1),
                const SizedBox(height: 20),

                Text(
                  _isEditing ? 'Edit Address' : 'Current Address',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Please input the correct address below',
                  style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                ),

                const SizedBox(height: 28),

                _buildDropdown(
                  label: 'Country',
                  value: _selectedCountry,
                  items: _countries,
                  onChanged: (val) => setState(() => _selectedCountry = val),
                ),

                const SizedBox(height: 12),

                _buildDropdown(
                  label: 'State/Province',
                  value: _selectedProvince,
                  items: _provinces,
                  onChanged: (val) => setState(() => _selectedProvince = val),
                ),

                const SizedBox(height: 12),

                _buildDropdown(
                  label: 'City/Municipality',
                  value: _selectedCity,
                  items: _cities,
                  onChanged: (val) => setState(() => _selectedCity = val),
                ),

                const SizedBox(height: 12),

                _buildDropdown(
                  label: 'Barangay',
                  value: _selectedBarangay,
                  items: _barangays,
                  onChanged: (val) => setState(() => _selectedBarangay = val),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  controller: _streetController,
                  label: 'House No./Bldg./Street Name',
                  isRequired: true,
                ),

                const SizedBox(height: 12),

                buildTextField(
                  controller: _address2Controller,
                  label: 'Address Line 2 (optional)',
                ),

                const SizedBox(height: 12),

                buildTextField(
                  controller: _postalController,
                  label: 'Postal Code (optional)',
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Save Changes' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: (val) => val == null ? '$label is required' : null,
      decoration: dropdownDecoration(label: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
