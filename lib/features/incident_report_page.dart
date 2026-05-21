import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final _sb = Supabase.instance.client;

// ─── Category model (mirrors admin's _IncidentCategory) ──────────────────────
class _Category {
  final String id;
  final String name;
  final String severity;
  final String? description;
  final String? iconKey;
  final String? colorHex;

  const _Category({
    required this.id,
    required this.name,
    required this.severity,
    this.description,
    this.iconKey,
    this.colorHex,
  });

  factory _Category.fromMap(Map<String, dynamic> m) => _Category(
    id: m['id'].toString(),
    name: m['name'] ?? '',
    severity: m['severity'] ?? 'medium',
    description: m['description'],
    iconKey: m['icon_key'],
    colorHex: m['color_hex'],
  );

  IconData get icon {
    const map = {
      'monitor': Icons.monitor_heart_rounded,
      'fire': Icons.local_fire_department_rounded,
      'flood': Icons.water_rounded,
      'lock': Icons.lock_open_rounded,
      'accident': Icons.car_crash_rounded,
      'warning': Icons.warning_amber_rounded,
      'shield': Icons.shield_outlined,
      'phone': Icons.phone_outlined,
      'home': Icons.home_outlined,
      'storm': Icons.thunderstorm_rounded,
      'bio': Icons.biotech_rounded,
      'medical': Icons.add_box_outlined,
      'signal': Icons.wifi_tethering_rounded,
      'sos': Icons.sos_rounded,
      'other': Icons.help_outline_rounded,
    };
    return map[iconKey] ?? Icons.crisis_alert_rounded;
  }

  Color get color {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try {
        return Color(int.parse(colorHex!.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return AppColors.primary;
  }
}

// ─── Dynamic field state (mirrors appointment's _FieldState) ─────────────────
class _FieldState {
  final String label;
  final bool isRequired;
  final TextEditingController ctrl;

  _FieldState({required this.label, required this.isRequired})
    : ctrl = TextEditingController();

  void dispose() => ctrl.dispose();

  Map<String, dynamic> toPersonalInfo() => {
    'label': label,
    'value': ctrl.text.trim(),
    'required': isRequired,
  };
}

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
  // ── controllers ─────────────────────────────────────────────────────────────
  final _pageController = PageController();
  final _personalFormKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();

  // ── state ───────────────────────────────────────────────────────────────────
  int _currentPage = 0;
  int _selectedCategoryIndex = 0;
  bool _saving = false;
  bool _submitted = false;
  bool _loadingCategories = true;
  String _referenceNo = '';

  List<_Category> _categories = [];
  List<_FieldState> _fieldStates = [];

  @override
  void initState() {
    super.initState();
    _referenceNo = 'INC-${Random().nextInt(90000) + 10000}';
    _fetchCategories();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionCtrl.dispose();
    for (final f in _fieldStates) {
      f.dispose();
    }
    super.dispose();
  }

  // ── fetch categories from Supabase ──────────────────────────────────────────
  Future<void> _fetchCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final data = await _sb
          .from('incident_categories')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: true);
      if (mounted) {
        final list = (data as List)
            .map<_Category>(
              (m) => _Category.fromMap(Map<String, dynamic>.from(m as Map)),
            )
            .toList();
        setState(() {
          _categories = list;
          _loadingCategories = false;
        });
        if (list.isNotEmpty) _buildFieldStates(0);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  // ── build dynamic fields from selected category's schema ────────────────────
  void _buildFieldStates(int categoryIndex) {
    for (final f in _fieldStates) {
      f.dispose();
    }
    _fieldStates = [];

    // Default reporter fields — always present
    _fieldStates = [
      _FieldState(label: 'Full Name', isRequired: true),
      _FieldState(label: 'Contact No.', isRequired: true),
      _FieldState(label: 'Address', isRequired: false),
    ];
  }

  // ── navigation ──────────────────────────────────────────────────────────────
  void _nextPage() {
    if (_currentPage == 1) {
      if (!_personalFormKey.currentState!.validate()) return;
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

  // ── submit ──────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);

    final cat = _categories[_selectedCategoryIndex];

    final personalInfo = _fieldStates
        .where((f) => f.ctrl.text.trim().isNotEmpty || f.isRequired)
        .map((f) => f.toPersonalInfo())
        .toList();

    try {
      await _sb.from('incidents').insert({
        'incident_category': cat.name,
        'incident_type': null,
        'severity': cat.severity,
        'status': 'pending',
        'reference_no': _referenceNo,
        'notes': _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        'icon_key': cat.iconKey,
        'color_hex': cat.colorHex,
        'personal_info': personalInfo,
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
    for (final f in _fieldStates) {
      f.dispose();
    }
    setState(() {
      _selectedCategoryIndex = 0;
      _submitted = false;
      _currentPage = 0;
      _referenceNo = 'INC-${Random().nextInt(90000) + 10000}';
    });
    _buildFieldStates(0);
    _pageController.jumpToPage(0);
  }

  // ── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'File Incident Report',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: _loadingCategories
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _categories.isEmpty
          ? _buildNoCategories()
          : _submitted
          ? _buildSuccess()
          : _buildForm(),
    );
  }

  // ── no categories fallback ───────────────────────────────────────────────────
  Widget _buildNoCategories() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.report_off_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No incident categories available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are currently no report categories set up.\nPlease check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── form ────────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      children: [
        // ── Ref chip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE7D9F8), width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B35E2).withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 15,
                  color: Color(0xFF8B35E2),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Reference No.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B6F87),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _referenceNo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8B35E2),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: Color(0xFF9B90A7),
                ),
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
              _Page1Category(
                categories: _categories,
                selectedIndex: _selectedCategoryIndex,
                descriptionCtrl: _descriptionCtrl,
                onCategorySelected: (i) {
                  setState(() => _selectedCategoryIndex = i);
                  _buildFieldStates(i);
                },
              ),
              _Page2Info(formKey: _personalFormKey, fieldStates: _fieldStates),
              _Page3Review(
                category: _categories[_selectedCategoryIndex],
                description: _descriptionCtrl.text,
                fieldStates: _fieldStates,
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

  // ── success ─────────────────────────────────────────────────────────────────
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
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.green,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Report Submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your incident report has been received.\nBarangay staff will respond shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Reference No.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _referenceNo,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _reset,
                  child: const Text(
                    'File Another Report',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
//  PAGE 1 — Select Category (from Supabase, same grid UX as appointment)
// ─────────────────────────────────────────────────────────────────────────────
class _Page1Category extends StatelessWidget {
  final List<_Category> categories;
  final int selectedIndex;
  final TextEditingController descriptionCtrl;
  final ValueChanged<int> onCategorySelected;

  const _Page1Category({
    required this.categories,
    required this.selectedIndex,
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
            message:
                'File an incident report para maaksyunan ng barangay. '
                'Piliin ang kategorya na pinaka-angkop sa sitwasyon.',
          ),
          const SizedBox(height: 14),
          const _SectionLabel(label: 'Incident Category'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final cat = categories[i];
              final active = selectedIndex == i;
              final catColor = cat.color;
              return GestureDetector(
                onTap: () => onCategorySelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? catColor.withValues(alpha: 0.10)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active
                          ? catColor.withValues(alpha: 0.55)
                          : const Color(0xFFE7DDF3),
                      width: active ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: catColor.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat.icon,
                        size: 16,
                        color: active ? catColor : AppColors.textGrey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.textDark
                                    : AppColors.textMedium,
                              ),
                            ),
                            if (cat.description != null &&
                                cat.description!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                cat.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (active)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: catColor,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const _SectionLabel(label: 'Description'),
          const SizedBox(height: 10),
          _DescriptionField(controller: descriptionCtrl),
          const SizedBox(height: 14),
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
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changes cannot be made after submission. Filing a false '
                    'report is subject to barangay sanctions.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.orange,
                      height: 1.5,
                    ),
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
//  PAGE 2 — Reporter Info (dynamic fields, same pattern as appointment)
// ─────────────────────────────────────────────────────────────────────────────
class _Page2Info extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<_FieldState> fieldStates;

  const _Page2Info({required this.formKey, required this.fieldStates});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message:
                'Ang iyong contact information ay tumutulong sa barangay staff '
                'na ma-follow up ang iyong report.',
          ),
          const SizedBox(height: 14),
          const _SectionLabel(label: 'Reporter Information'),
          const SizedBox(height: 12),
          Form(
            key: formKey,
            child: Column(
              children: [
                for (int i = 0; i < fieldStates.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _DynamicFormField(state: fieldStates[i]),
                ],
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
                    'Your personal information is kept confidential and will '
                    'only be used by authorized barangay personnel.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.orange,
                      height: 1.5,
                    ),
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
  final _Category category;
  final String description;
  final List<_FieldState> fieldStates;
  final String referenceNo;

  const _Page3Review({
    required this.category,
    required this.description,
    required this.fieldStates,
    required this.referenceNo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InfoBox(
            message:
                'Suriin ang iyong impormasyon bago i-submit. '
                'Hindi na mababago pagkatapos.',
          ),
          const SizedBox(height: 14),

          // ── Category preview card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: category.color.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (category.description != null &&
                          category.description!.isNotEmpty)
                        Text(
                          category.description!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Report info section
          _ReviewSection(
            title: 'Report Info',
            rows: [
              _ReviewRow(label: 'Reference', value: referenceNo),
              _ReviewRow(label: 'Category', value: category.name),
              if (description.isNotEmpty)
                _ReviewRow(label: 'Description', value: description),
            ],
          ),

          const SizedBox(height: 10),

          // ── Reporter section
          _ReviewSection(
            title: 'Reporter',
            rows: fieldStates
                .where((f) => f.ctrl.text.trim().isNotEmpty)
                .map(
                  (f) => _ReviewRow(label: f.label, value: f.ctrl.text.trim()),
                )
                .toList(),
          ),

          const SizedBox(height: 14),

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
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changes cannot be made after submission. Filing a false '
                    'report is subject to barangay sanctions.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.orange,
                      height: 1.5,
                    ),
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

// ─── Dynamic Form Field (same as appointment's _DynamicFormField) ─────────────
class _DynamicFormField extends StatelessWidget {
  final _FieldState state;
  const _DynamicFormField({required this.state});

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('name') || l.contains('pangalan')) {
      return Icons.person_outline_rounded;
    }
    if (l.contains('contact') || l.contains('phone') || l.contains('numero')) {
      return Icons.phone_outlined;
    }
    if (l.contains('address') || l.contains('tirahan')) {
      return Icons.location_on_outlined;
    }
    if (l.contains('email')) return Icons.email_outlined;
    if (l.contains('age') || l.contains('edad')) return Icons.cake_outlined;
    return Icons.short_text_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              state.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
            if (state.isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.red, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: state.ctrl,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          validator: state.isRequired
              ? (v) => (v == null || v.trim().isEmpty)
                    ? '${state.label} is required'
                    : null
              : null,
          decoration: InputDecoration(
            hintText: 'Enter ${state.label.toLowerCase()}…',
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            prefixIcon: Icon(
              _iconFor(state.label),
              size: 17,
              color: AppColors.textGrey,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
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

// ─── Description Field ────────────────────────────────────────────────────────
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText:
                'Briefly describe the incident, location, and any relevant details…',
            hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(
                Icons.notes_rounded,
                size: 17,
                color: AppColors.textGrey,
              ),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Step Indicator (same as appointment)
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Select Category', 'Your Info', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(_labels.length, (i) {
              final isDone = i < currentStep;
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
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Bottom Bar (same as appointment)
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
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentPage > 0) ...[
            OutlinedButton(
              onPressed: saving ? null : onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
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
                disabledBackgroundColor:
                    (isLast ? AppColors.green : AppColors.primary).withValues(
                      alpha: 0.5,
                    ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLast
                              ? Icons.send_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLast ? 'Submit Report' : 'Continue',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
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
        color: const Color(0xFFF8F3FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEADCF9), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B35E2).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Color(0xFF8B35E2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4B2C63),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final List<_ReviewRow> rows;
  const _ReviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
