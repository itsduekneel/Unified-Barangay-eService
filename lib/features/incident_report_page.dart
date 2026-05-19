import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final _sb = Supabase.instance.client;

// ─── Incident Categories ───────────────────────────────────────────────────────
class _Category {
  final String key, label;
  final IconData icon;
  final Color color;
  const _Category(this.key, this.label, this.icon, this.color);
}

const _kCategories = [
  _Category('fire',          'Fire',               Icons.local_fire_department_rounded, AppColors.red),
  _Category('flood',         'Flood',              Icons.water_rounded,                 AppColors.blue),
  _Category('crime',         'Crime / Security',   Icons.security_rounded,              AppColors.primary),
  _Category('medical',       'Medical Emergency',  Icons.medical_services_rounded,      AppColors.red),
  _Category('disaster',      'Natural Disaster',   Icons.storm_rounded,                 Color(0xFF0891B2)),
  _Category('accident',      'Road Accident',      Icons.car_crash_rounded,             AppColors.orange),
  _Category('property',      'Property Damage',    Icons.home_work_outlined,            Color(0xFF92400E)),
  _Category('noise',         'Noise Complaint',    Icons.volume_up_rounded,             Color(0xFF6D28D9)),
  _Category('utility',       'Utility Issue',      Icons.bolt_rounded,                  Color(0xFFCA8A04)),
  _Category('animal',        'Animal Incident',    Icons.pets_rounded,                  AppColors.green),
  _Category('missing',       'Missing Person',     Icons.person_search_rounded,         Color(0xFF0F766E)),
  _Category('environmental', 'Environmental',      Icons.eco_rounded,                   AppColors.green),
  _Category('dispute',       'Dispute / Conflict', Icons.people_alt_rounded,            Color(0xFFB45309)),
  _Category('other',         'Other',              Icons.more_horiz_rounded,            AppColors.textGrey),
];

// ============================================================================
//  RESIDENT INCIDENT REPORT PAGE
// ============================================================================
class ResidentIncidentReportPage extends StatefulWidget {
  const ResidentIncidentReportPage({super.key});

  @override
  State<ResidentIncidentReportPage> createState() =>
      _ResidentIncidentReportPageState();
}

class _ResidentIncidentReportPageState
    extends State<ResidentIncidentReportPage> {
  // ── controllers ────────────────────────────────────────────────────────────
  final _pageController  = PageController();
  final _personalFormKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _fullNameCtrl    = TextEditingController();
  final _contactCtrl     = TextEditingController();
  final _addressCtrl     = TextEditingController();

  // ── state ──────────────────────────────────────────────────────────────────
  int     _currentPage      = 0;
  String? _selectedCategory;
  bool    _saving           = false;
  bool    _submitted        = false;
  String  _referenceNo      = '';

  @override
  void initState() {
    super.initState();
    _referenceNo = 'INC-${Random().nextInt(90000) + 10000}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionCtrl.dispose();
    _fullNameCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── navigation ─────────────────────────────────────────────────────────────
  void _nextPage() {
    if (_currentPage == 0) {
      if (_selectedCategory == null) {
        _snack('Please select an incident category.');
        return;
      }
    }
    if (_currentPage == 1 && !_personalFormKey.currentState!.validate()) return;
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

  // ── submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await _sb.from('incidents').insert({
        'incident_category': _selectedCategory,
        'incident_type': null,
        'severity': 'low',
        'status': 'pending',
        'reference_no': _referenceNo,
        'notes': _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        'personal_info': [
          {
            'label': 'Full Name',
            'value': _fullNameCtrl.text.trim(),
            'required': true,
          },
          {
            'label': 'Contact No.',
            'value': _contactCtrl.text.trim(),
            'required': true,
          },
          if (_addressCtrl.text.trim().isNotEmpty)
            {
              'label': 'Address',
              'value': _addressCtrl.text.trim(),
              'required': false,
            },
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
    _descriptionCtrl.clear();
    _fullNameCtrl.clear();
    _contactCtrl.clear();
    _addressCtrl.clear();
    setState(() {
      _currentPage      = 0;
      _selectedCategory = null;
      _submitted        = false;
      _referenceNo      = 'INC-${Random().nextInt(90000) + 10000}';
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
          'File Incident Report',
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
              _Page1Incident(
                selectedCategory: _selectedCategory,
                descriptionCtrl: _descriptionCtrl,
                onCategorySelected: (key) => setState(() => _selectedCategory = key),
              ),
              _Page2Personal(
                formKey: _personalFormKey,
                fullNameCtrl: _fullNameCtrl,
                contactCtrl: _contactCtrl,
                addressCtrl: _addressCtrl,
              ),
              _Page3Review(
                selectedCategory: _selectedCategory,
                description: _descriptionCtrl.text,
                fullName: _fullNameCtrl.text,
                contact: _contactCtrl.text,
                address: _addressCtrl.text,
                referenceNo: _referenceNo,
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
                'Report Submitted!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your incident report has been received.\nBarangay staff will respond shortly.',
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
                'Keep this number to track your report.',
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
                  child: const Text('File Another Report', style: TextStyle(fontWeight: FontWeight.bold)),
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
//  PAGE 1 — Incident Category & Description
// ─────────────────────────────────────────────────────────────────────────────
class _Page1Incident extends StatelessWidget {
  final String? selectedCategory;
  final TextEditingController descriptionCtrl;
  final ValueChanged<String> onCategorySelected;

  const _Page1Incident({
    required this.selectedCategory,
    required this.descriptionCtrl,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message: 'File an incident report for barangay to act on. '
                'Select the category that best describes the situation.',
          ),
          const SizedBox(height: 14),

          // ── Category grid
          const _SectionLabel(label: 'Incident Category'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: _kCategories.map((cat) {
              final active = selectedCategory == cat.key;
              return GestureDetector(
                onTap: () => onCategorySelected(cat.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: active ? cat.color.withValues(alpha: 0.12) : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? cat.color.withValues(alpha: 0.5) : AppColors.border,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, size: 15, color: active ? cat.color : AppColors.textGrey),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            color: active ? cat.color : AppColors.textGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (active) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.check_circle_rounded, size: 11, color: cat.color),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Description
          const _SectionLabel(label: 'Description'),
          const SizedBox(height: 10),
          _FormField(
            label: 'What happened?',
            controller: descriptionCtrl,
            icon: Icons.notes_rounded,
            hint: 'Briefly describe the incident, location, and any relevant details…',
            required: false,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PAGE 2 — Personal Info
// ─────────────────────────────────────────────────────────────────────────────
class _Page2Personal extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameCtrl, contactCtrl, addressCtrl;

  const _Page2Personal({
    required this.formKey,
    required this.fullNameCtrl,
    required this.contactCtrl,
    required this.addressCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message: 'Your contact information helps barangay staff follow up on your report.',
          ),
          const SizedBox(height: 16),
          const _SectionLabel(label: 'Reporter Information'),
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
                  required: false,
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
                    'Your personal information is kept confidential and will only be used by authorized barangay personnel.',
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
//  PAGE 3 — Review & Confirm
// ─────────────────────────────────────────────────────────────────────────────
class _Page3Review extends StatelessWidget {
  final String? selectedCategory;
  final String description, fullName, contact, address, referenceNo;

  const _Page3Review({
    required this.selectedCategory,
    required this.description,
    required this.fullName,
    required this.contact,
    required this.address,
    required this.referenceNo,
  });

  @override
  Widget build(BuildContext context) {
    final cat = selectedCategory != null
        ? _kCategories.firstWhere((c) => c.key == selectedCategory,
        orElse: () => _kCategories.last)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Incident card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (cat != null)
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.color.withValues(alpha: 0.28)),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cat?.label ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Review sections
          _ReviewSection(
            title: 'Report Info',
            rows: [
              _ReviewRow(label: 'Reference', value: referenceNo),
              _ReviewRow(label: 'Category',  value: cat?.label ?? '—'),
              if (description.isNotEmpty)
                _ReviewRow(label: 'Description', value: description),
            ],
          ),

          const SizedBox(height: 10),

          _ReviewSection(
            title: 'Reporter',
            rows: [
              _ReviewRow(label: 'Full Name', value: fullName),
              _ReviewRow(label: 'Contact',   value: contact),
              if (address.isNotEmpty) _ReviewRow(label: 'Address', value: address),
            ],
          ),

          const SizedBox(height: 14),

          // ── Warning banner
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
                Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changes cannot be made after submission. Filing a false report is subject to barangay sanctions.',
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

  static const _labels = ['Incident', 'Details', 'Review'];

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
                    isLast ? 'Submit Report' : 'Continue',
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
  final bool isRequired;
  const _SectionLabel({required this.label, this.isRequired = false});

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
        if (isRequired) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.redBorder),
            ),
            child: const Text(
              'Required',
              style: TextStyle(fontSize: 9, color: AppColors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
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

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewRow> rows;
  const _ReviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
