import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ube/authentication/app_colors.dart';

// ─── SHARED INPUT DECORATION ─────────────────────────────────────────────────

/// Returns the standard border used across all form fields.
OutlineInputBorder _border(Color color, {double width = 1.2}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );

/// Base [InputDecoration] shared by text fields and dropdowns.
InputDecoration _baseDecoration({
  required String label,
  bool enabled = true,
  Widget? suffixIcon,
  String? hintText,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
    floatingLabelStyle: const TextStyle(
      fontSize: 12,
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    hintText: hintText ?? 'Enter $label',
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border:             _border(const Color(0xFFE5E5E5)),
    enabledBorder:      _border(const Color(0xFFE5E5E5)),
    focusedBorder:      _border(AppColors.primary, width: 1.6),
    disabledBorder:     _border(const Color(0xFFEDEDED)),
    errorBorder:        _border(Colors.red),
    focusedErrorBorder: _border(Colors.red, width: 1.6),
  );
}

// ─── TEXT FIELD ───────────────────────────────────────────────────────────────

/// Builds a consistently styled [TextFormField].
///
/// - Set [isRequired] to automatically apply a "field is required" validator.
/// - Pass a custom [validator] to override or extend validation.
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool enabled = true,
  bool isRequired = false,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    enabled: enabled,
    textInputAction: TextInputAction.next,
    inputFormatters: inputFormatters,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1A1A1A),
    ),
    validator: validator ??
        (isRequired
            ? (value) => (value == null || value.trim().isEmpty)
                ? '$label is required'
                : null
            : null),
    decoration: _baseDecoration(label: label, enabled: enabled),
  );
}

// ─── DATE PICKER FIELD ────────────────────────────────────────────────────────

/// A read-only date field that opens a [DatePicker] on tap.
Widget buildDateField({
  required String displayValue,
  required VoidCallback onTap,
  required String? Function(String?) validator,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AbsorbPointer(
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: displayValue),
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
        decoration: _baseDecoration(
          label: 'Date of Birth',
          hintText: 'MM/DD/YYYY',
          suffixIcon: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    ),
  );
}

// ─── PASSWORD FIELD ───────────────────────────────────────────────────────────

/// A styled password field with a visibility toggle.
Widget buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool obscureText,
  required VoidCallback onToggleVisibility,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    textInputAction: TextInputAction.next,
    validator: validator,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1A1A1A),
    ),
    decoration: _baseDecoration(
      label: label,
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.primary,
          size: 20,
        ),
        onPressed: onToggleVisibility,
      ),
    ),
  );
}

// ─── DROPDOWN DECORATION ──────────────────────────────────────────────────────

/// Decoration applied to all [DropdownButtonFormField] widgets.
InputDecoration dropdownDecoration({String? label}) =>
    _baseDecoration(label: label ?? '', hintText: '');
