import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final _sb = Supabase.instance.client;

// ============================================================================
//  RESIDENT APPOINTMENT REQUEST PAGE
// ============================================================================
class ResidentAppointmentRequestPage extends StatefulWidget {
  const ResidentAppointmentRequestPage({super.key});

  @override
  State<ResidentAppointmentRequestPage> createState() =>
      _ResidentAppointmentRequestPageState();
}

class _ResidentAppointmentRequestPageState
    extends State<ResidentAppointmentRequestPage> {
  // ── controllers ────────────────────────────────────────────────────────────
  final _pageController  = PageController();
  final _personalFormKey = GlobalKey<FormState>();
  final _fullNameCtrl    = TextEditingController();
  final _contactCtrl     = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _purposeCtrl     = TextEditingController();

  // ── state ──────────────────────────────────────────────────────────────────
  int        _currentPage          = 0;
  int        _selectedServiceIndex = 0;
  DateTime?  _selectedDate;
  TimeOfDay? _selectedTime;
  bool       _saving               = false;
  bool       _submitted            = false;
  String     _referenceNo          = '';

  final List<_Service> _services = [
    const _Service('Barangay Clearance',    '5–10 mins',  Icons.badge_outlined),
    const _Service('Business Permit',       '15–30 mins', Icons.storefront_outlined),
    const _Service('Indigency Certificate', '5–10 mins',  Icons.assignment_ind_outlined),
    const _Service('Blotter Report',        '20–40 mins', Icons.gavel_rounded),
    const _Service('Residency Certificate', '5 mins',     Icons.home_outlined),
    const _Service('Other / Walk-in',       'Varies',     Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _referenceNo = 'APT-${Random().nextInt(90000) + 10000}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  // ── navigation ─────────────────────────────────────────────────────────────
  void _nextPage() {
    if (_currentPage == 1) {
      if (_selectedDate == null || _selectedTime == null) {
        _snack('Please select date and time.');
        return;
      }
    }
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── pickers ────────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ── submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_personalFormKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);

    final svc     = _services[_selectedServiceIndex];
    final isoDate = '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeStr = _selectedTime!.format(context);

    try {
      await _sb.from('appointments').insert({
        'service_name':     svc.name,
        'service_duration': svc.duration,
        'appointment_date': isoDate,
        'appointment_time': timeStr,
        'full_name':        _fullNameCtrl.text.trim(),
        'contact_no':       _contactCtrl.text.trim(),
        'purpose': _purposeCtrl.text.trim().isEmpty
            ? null
            : _purposeCtrl.text.trim(),
        'status':       'pending',
        'reference_no': _referenceNo,
        'notes':        null,
        'resident_info': [
          {'label': 'Full Name',   'value': _fullNameCtrl.text.trim(), 'required': true},
          {'label': 'Contact No.', 'value': _contactCtrl.text.trim(),  'required': true},
          if (_addressCtrl.text.trim().isNotEmpty)
            {'label': 'Address', 'value': _addressCtrl.text.trim(), 'required': false},
          if (_purposeCtrl.text.trim().isNotEmpty)
            {'label': 'Purpose', 'value': _purposeCtrl.text.trim(), 'required': false},
        ],
      });
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  void _reset() {
    _fullNameCtrl.clear();
    _contactCtrl.clear();
    _addressCtrl.clear();
    _purposeCtrl.clear();
    setState(() {
      _selectedServiceIndex = 0;
      _selectedDate         = null;
      _selectedTime         = null;
      _submitted            = false;
      _currentPage          = 0;
      _referenceNo          = 'APT-${Random().nextInt(90000) + 10000}';
    });
    _pageController.jumpToPage(0);
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Appointment',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  // ── form ───────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      children: [
        // ── Ref chip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.sell_outlined, size: 13, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Reference No.',
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  _referenceNo,
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w900,
                    color: AppColors.primary, letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textGrey),
              ],
            ),
          ),
        ),

        // ── Step indicator
        _StepIndicator(currentStep: _currentPage),

        // ── Pages
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _Page1Service(
                services: _services,
                selectedIndex: _selectedServiceIndex,
                onServiceSelected: (i) => setState(() => _selectedServiceIndex = i),
              ),
              _Page2Schedule(
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                onPickDate: _pickDate,
                onPickTime: _pickTime,
              ),
              _Page3Info(
                formKey: _personalFormKey,
                fullNameCtrl: _fullNameCtrl,
                contactCtrl: _contactCtrl,
                addressCtrl: _addressCtrl,
                purposeCtrl: _purposeCtrl,
              ),
            ],
          ),
        ),

        // ── Bottom bar
        _BottomBar(
          currentPage: _currentPage,
          saving: _saving,
          onBack: _previousPage,
          onNext: _currentPage == 2 ? _submit : _nextPage,
        ),
      ],
    );
  }

  // ── success ────────────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.greenBorder),
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 42),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Submitted!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your appointment request has been received.\nBarangay staff will confirm your schedule.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.6),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Reference No.',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _referenceNo,
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900,
                        color: AppColors.primary, letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Keep this number to track your appointment.',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _reset,
                  child: const Text('Create New Request', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 1 — Select Service
// ─────────────────────────────────────────────────────────────────────────────
class _Page1Service extends StatelessWidget {
  final List<_Service> services;
  final int selectedIndex;
  final ValueChanged<int> onServiceSelected;

  const _Page1Service({
    required this.services,
    required this.selectedIndex,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message: 'Pumili ng serbisyo bago mag-proceed sa schedule. '
                'Office hours: Monday–Friday, 8AM–5PM.',
          ),
          const SizedBox(height: 14),
          const _SectionLabel(label: 'Select Service'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final svc    = services[i];
              final active = selectedIndex == i;
              return GestureDetector(
                onTap: () => onServiceSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryLight : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(svc.icon, size: 16, color: active ? AppColors.primary : AppColors.textGrey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              svc.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active ? AppColors.textDark : AppColors.textMedium,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              svc.duration,
                              style: const TextStyle(fontSize: 9, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      if (active)
                        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 2 — Schedule
// ─────────────────────────────────────────────────────────────────────────────
class _Page2Schedule extends StatelessWidget {
  final DateTime?  selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const _Page2Schedule({
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message: 'Pumili ng preferred date at oras ng iyong appointment. '
                'Available tuwing Lunes–Biyernes lamang.',
          ),
          const SizedBox(height: 14),
          const _SectionLabel(label: 'Preferred Schedule'),
          const SizedBox(height: 10),

          _PickerTile(
            icon: Icons.event_rounded,
            label: 'Appointment Date',
            value: selectedDate == null
                ? null
                : DateFormat('MMMM dd, yyyy').format(selectedDate!),
            hint: 'Select a date',
            onTap: onPickDate,
          ),

          const SizedBox(height: 10),

          _PickerTile(
            icon: Icons.access_time_rounded,
            label: 'Appointment Time',
            value: selectedTime?.format(context),
            hint: 'Select a time',
            onTap: onPickTime,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orangeBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: AppColors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Office hours: Monday–Friday, 8:00 AM – 5:00 PM. '
                        'Appointments outside these hours will not be accommodated.',
                    style: TextStyle(fontSize: 11, color: AppColors.orange, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 3 — Resident Info
// ─────────────────────────────────────────────────────────────────────────────
class _Page3Info extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameCtrl, contactCtrl, addressCtrl, purposeCtrl;

  const _Page3Info({
    required this.formKey,
    required this.fullNameCtrl,
    required this.contactCtrl,
    required this.addressCtrl,
    required this.purposeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message: 'Ilagay ang iyong personal na impormasyon para makontak '
                'ng barangay staff para sa kumpirmasyon.',
          ),
          const SizedBox(height: 14),
          const _SectionLabel(label: 'Resident Information'),
          const SizedBox(height: 12),
          Form(
            key: formKey,
            child: Column(
              children: [
                _FormField(
                  label: 'Full Name',
                  controller: fullNameCtrl,
                  icon: Icons.person_outline_rounded,
                  hint: 'Juan Dela Cruz',
                  required: true,
                ),
                const SizedBox(height: 10),
                _FormField(
                  label: 'Contact Number',
                  controller: contactCtrl,
                  icon: Icons.phone_outlined,
                  hint: '09XX XXX XXXX',
                  required: true,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _FormField(
                  label: 'Address',
                  controller: addressCtrl,
                  icon: Icons.location_on_outlined,
                  hint: 'Block/Lot, Street, Barangay',
                ),
                const SizedBox(height: 10),
                _FormField(
                  label: 'Purpose / Reason',
                  controller: purposeCtrl,
                  icon: Icons.notes_rounded,
                  hint: 'Briefly describe why you need this appointment…',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orangeBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.orangeBorder),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: AppColors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your personal information is kept confidential and will only '
                        'be used by authorized barangay personnel.',
                    style: TextStyle(fontSize: 11, color: AppColors.orange, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Select Service', 'Schedule', 'Your Info'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_labels.length, (i) {
              final isDone   = i < currentStep;
              final isActive = i == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.green
                              : isActive
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    if (i < _labels.length - 1) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${currentStep + 1} of ${_labels.length}  ·  ${_labels[currentStep]}',
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentPage;
  final bool saving;
  final VoidCallback onBack, onNext;

  const _BottomBar({
    required this.currentPage,
    required this.saving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == 2;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (currentPage > 0) ...[
            OutlinedButton(
              onPressed: saving ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 13),
                  SizedBox(width: 4),
                  Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: saving ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLast ? AppColors.green : AppColors.primary,
                disabledBackgroundColor: (isLast ? AppColors.green : AppColors.primary).withValues(alpha: 0.5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isLast ? 'Submit Request' : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared Components
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;
  const _InfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 11, color: AppColors.textMedium, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.border,
            width: filled ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: filled ? AppColors.primary : AppColors.textGrey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    filled ? value! : hint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: filled ? FontWeight.w700 : FontWeight.normal,
                      color: filled ? AppColors.textDark : AppColors.textGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: filled ? AppColors.primary : AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  final int maxLines;
  final TextInputType? keyboard;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
            if (required) const Text(' *', style: TextStyle(color: AppColors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            prefixIcon: Icon(icon, size: 17, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: maxLines > 1 ? 14 : 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.red),
          ),
        ),
      ],
    );
  }
}

class _Service {
  final String name, duration;
  final IconData icon;
  const _Service(this.name, this.duration, this.icon);
}
