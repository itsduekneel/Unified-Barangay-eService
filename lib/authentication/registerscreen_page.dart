import 'package:flutter/material.dart';

import 'package:ube/authentication/app_colors.dart';
import 'package:ube/authentication/registeraddress_page.dart';
import 'package:ube/authentication/route_utils.dart';
import 'package:ube/authentication/user_info.dart';
import 'package:ube/authentication/widgets/step_indicator.dart';
import 'package:ube/authentication/widgets/form_field_builder.dart';

// ─── REGISTER SCREEN (Step 1 — Personal Details) ─────────────────────────────

class RegisterScreen extends StatefulWidget {
  /// When provided, the screen pre-fills all fields and returns the updated
  /// [UserInfo] via [Navigator.pop] instead of pushing to the address screen.
  final UserInfo? initialData;

  const RegisterScreen({super.key, this.initialData});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedSuffix;
  String? _selectedGender;
  DateTime? _selectedDob;

  bool _hasNoMiddleName = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool get _isEditing => widget.initialData != null;

  static const _suffixes = ['N/A', 'Jr.', 'Sr.', 'II', 'III', 'IV', 'V'];
  static const _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _prefillIfEditing();
  }

  void _prefillIfEditing() {
    final d = widget.initialData;
    if (d == null) return;

    _firstNameController.text = d.firstName;
    _middleNameController.text = d.middleName;
    _lastNameController.text = d.lastName;
    _emailController.text = d.emailAddress;
    _selectedSuffix = d.suffix;
    _selectedGender = d.gender;
    _hasNoMiddleName = d.middleName.isEmpty;

    if (d.dateOfBirth.isNotEmpty) {
      _selectedDob = DateTime.tryParse(d.dateOfBirth);
    }
    // Password is intentionally left blank in edit mode.
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Date of birth ──────────────────────────────────────────────────────────

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  String get _dobDisplay {
    if (_selectedDob == null) return '';
    final d = _selectedDob!;
    return '${d.month.toString().padLeft(2, '0')}/'
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String get _dobIso {
    if (_selectedDob == null) return '';
    final d = _selectedDob!;
    return '${d.year}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    final middleName = _hasNoMiddleName
        ? ''
        : _middleNameController.text.trim();

    if (_isEditing) {
      final updated = widget.initialData!.copyWith(
        firstName: _firstNameController.text.trim(),
        middleName: middleName,
        lastName: _lastNameController.text.trim(),
        suffix: _selectedSuffix ?? 'N/A',
        emailAddress: _emailController.text.trim(),
        dateOfBirth: _dobIso,
        gender: _selectedGender ?? '',
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : widget.initialData!.password,
      );
      Navigator.pop(context, updated);
      return;
    }

    Navigator.push(
      context,
      instantRoute(
        AddressScreen(
          firstName: _firstNameController.text.trim(),
          middleName: middleName,
          lastName: _lastNameController.text.trim(),
          suffix: _selectedSuffix ?? 'N/A',
          emailAddress: _emailController.text.trim(),
          dateOfBirth: _dobIso,
          gender: _selectedGender ?? '',
          password: _passwordController.text,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StepIndicator(totalSteps: 3, currentStep: 0),
                const SizedBox(height: 20),

                Text(
                  _isEditing ? 'Edit Personal Details' : "Let's Get Started!",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 28),

                // First Name + Suffix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _buildDropdown(
                        label: 'Suffix',
                        value: _selectedSuffix,
                        items: _suffixes,
                        onChanged: (val) =>
                            setState(() => _selectedSuffix = val),
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Middle Name
                buildTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                  enabled: !_hasNoMiddleName,
                  isRequired: !_hasNoMiddleName,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _hasNoMiddleName,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() {
                            _hasNoMiddleName = val ?? false;
                            if (_hasNoMiddleName) _middleNameController.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'I have no middle name',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),

                const SizedBox(height: 12),

                buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email Address is required';
                    }
                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                buildDateField(
                  displayValue: _dobDisplay,
                  onTap: _pickDob,
                  validator: (_) =>
                      _selectedDob == null ? 'Date of Birth is required' : null,
                ),

                const SizedBox(height: 12),

                _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) => val == null ? 'Gender is required' : null,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Create Password',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF444444),
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 10),

                buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  validator: (value) {
                    if (_isEditing && (value == null || value.isEmpty))
                      return null;
                    if (value == null || value.isEmpty)
                      return 'Password is required';
                    if (value.length < 8)
                      return 'Password must be at least 8 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: _obscureConfirm,
                  onToggleVisibility: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (value) {
                    if (_isEditing && _passwordController.text.isEmpty)
                      return null;
                    if (value != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),

                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Leave password blank to keep your current password.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                _PrimaryButton(
                  label: _isEditing ? 'Save Changes' : 'Create new account',
                  onPressed: _handleSubmit,
                ),

                if (!_isEditing) ...[
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  const Center(child: Text('Already have an UBE account?')),
                  const SizedBox(height: 12),
                  _OutlineButton(
                    label: 'Login here',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Personal Details',
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
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text('Select $label'),
      validator: validator,
      decoration: dropdownDecoration(label: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─── SMALL SHARED WIDGETS ─────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
