import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;

import 'app_colors.dart';
import 'user_info.dart';
import 'congratulationsscreen_page.dart';
import 'route_utils.dart';
import 'registerscreen_page.dart';
import 'registeraddress_page.dart';
import 'widgets/step_indicator.dart';
import 'auth_service.dart';

class ConfirmInfoScreen extends StatefulWidget {
  final UserInfo userInfo;

  const ConfirmInfoScreen({super.key, required this.userInfo});

  @override
  State<ConfirmInfoScreen> createState() => _ConfirmInfoScreenState();
}

class _ConfirmInfoScreenState extends State<ConfirmInfoScreen> {
  bool _isLoading = false;

  // ─── Confirm & register ────────────────────────────────────────────────────

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.register(widget.userInfo);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        instantRoute(
          CongratulationsScreen(firstName: widget.userInfo.firstName),
        ),
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } on PostgrestException catch (e) {
      _showError('Database error: ${e.message}');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Edit personal ─────────────────────────────────────────────────────────

  Future<void> _editPersonal() async {
    final result = await Navigator.push<UserInfo>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(initialData: widget.userInfo),
      ),
    );

    if (result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AddressScreen(
            firstName:    result.firstName,
            middleName:   result.middleName,
            lastName:     result.lastName,
            suffix:       result.suffix,
            emailAddress: result.emailAddress,
            dateOfBirth:  result.dateOfBirth,
            gender:       result.gender,
            password:     result.password,
            initialData:  result,
          ),
        ),
      );
    }
  }

  // ─── Edit address ──────────────────────────────────────────────────────────

  Future<void> _editAddress() async {
    final result = await Navigator.push<UserInfo>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen.fromUserInfo(widget.userInfo),
      ),
    );

    if (result != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmInfoScreen(userInfo: result),
        ),
      );
    }
  }

  // ─── DOB display ───────────────────────────────────────────────────────────

  String get _dobDisplay {
    if (widget.userInfo.dateOfBirth.isEmpty) return '—';
    final dt = DateTime.tryParse(widget.userInfo.dateOfBirth);
    if (dt == null) return widget.userInfo.dateOfBirth;
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Confirm Information',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepIndicator(totalSteps: 3, currentStep: 2),

                  const SizedBox(height: 20),

                  const Text(
                    'Confirm Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  _section(
                    title: 'Personal Details',
                    onEdit: _editPersonal,
                    children: [
                      _row('First Name',    widget.userInfo.firstName),
                      _row('Middle Name',   widget.userInfo.middleName.isEmpty ? 'N/A' : widget.userInfo.middleName),
                      _row('Last Name',     widget.userInfo.lastName),
                      _row('Suffix',        widget.userInfo.suffix),
                      _row('Email',         widget.userInfo.emailAddress),
                      _row('Date of Birth', _dobDisplay),
                      _row('Gender',        widget.userInfo.gender),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _section(
                    title: 'Address',
                    onEdit: _editAddress,
                    children: [
                      _row('Country',  widget.userInfo.country),
                      _row('Province', widget.userInfo.stateProvince),
                      _row('City',     widget.userInfo.cityMunicipality),
                      _row('Barangay', widget.userInfo.barangay),
                      _row('Street',   widget.userInfo.houseStreet),
                      if (widget.userInfo.addressLine2.isNotEmpty)
                        _row('Line 2', widget.userInfo.addressLine2),
                      if (widget.userInfo.postalCode.isNotEmpty)
                        _row('Postal', widget.userInfo.postalCode),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Confirm button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Confirm & Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: onEdit,
                child: const Text('Edit',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child:
                Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
