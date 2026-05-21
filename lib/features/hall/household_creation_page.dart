// ============================================================================
// lib/features/hall/household_creation_page.dart
// Barangay Hall: Household Creation Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ============================================================================
// Design Tokens
// ============================================================================

const _kPrimary = Color(0xFF7C3AED);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F3FF);
const _kBorder = Color(0xFFEDE9FE);
const _kInk = Color(0xFF1A1033);
const _kInk2 = Color(0xFF6B6480);
const _kInk3 = Color(0xFFA09BB5);
const _kCard = Color(0xFFFFFFFF);
const _kDanger = Color(0xFFDC2626);
const _kSuccess = Color(0xFF16A34A);
const _kSuccessLight = Color(0xFFEDFAF3);

// ============================================================================
// Member Draft Model (for form state — not yet saved to DB)
// ============================================================================

class _MemberDraft {
  final String? userId; // null = manual entry
  final String fullName;
  final String role;
  final String gender;
  final int age;
  final bool isFromSearch;

  _MemberDraft({
    this.userId,
    required this.fullName,
    required this.role,
    required this.gender,
    required this.age,
    this.isFromSearch = false,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

// ============================================================================
// Household List Page
// ============================================================================

class HouseholdCreationPage extends StatefulWidget {
  const HouseholdCreationPage({super.key});

  @override
  State<HouseholdCreationPage> createState() => _HouseholdCreationPageState();
}

class _HouseholdCreationPageState extends State<HouseholdCreationPage> {
  List<HouseholdModel> _households = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await supabase.from('households').select();
      _households = (res as List)
          .map(
            (h) => HouseholdModel(
              id: h['id'] ?? '',
              unitNo: h['unit_no'] ?? '',
              streetAddress: h['street_address'] ?? '',
              purok: h['purok'] ?? '',
              dateCreated: h['date_created'] ?? '',
              members: [],
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('LOAD ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading households')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<HouseholdModel> get _filtered => _households.where((h) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return h.unitNo.toLowerCase().contains(q) ||
        h.streetAddress.toLowerCase().contains(q) ||
        h.purok.toLowerCase().contains(q) ||
        (h.head?.fullName.toLowerCase().contains(q) ?? false);
  }).toList();

  Future<void> _goToCreate() async {
    final created = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HouseholdFormPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
    if (created == true) {
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Household created successfully!'),
              ],
            ),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(14),
          ),
        );
      }
    }
  }

  void _showHouseholdDetails(HouseholdModel h) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HouseholdDetailSheet(household: h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Households',
          style: TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _goToCreate,
              style: TextButton.styleFrom(
                backgroundColor: _kPrimaryLight,
                foregroundColor: _kPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'New',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : RefreshIndicator(
              color: _kPrimary,
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: _StatsBanner(
                        total: _households.length,
                        memberCount: _households.fold<int>(
                          0,
                          (s, h) => s + h.memberCount,
                        ),
                        onAdd: _goToCreate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(fontSize: 13, color: _kInk),
                        decoration: InputDecoration(
                          hintText: 'Search unit, street, or purok...',
                          hintStyle: const TextStyle(
                            color: _kInk3,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _kPrimary,
                            size: 18,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: _kInk3,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: _kCard,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                              color: _kBorder,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                              color: _kBorder,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                              color: _kPrimary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Households',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kPrimaryLight,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '${filtered.length} results',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (filtered.isEmpty)
                      _EmptyState(onAdd: _goToCreate)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final h = filtered[i];
                          return _HouseholdCard(
                            household: h,
                            onTap: () => _showHouseholdDetails(h),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ============================================================================
// Household Form Page
// ============================================================================

class HouseholdFormPage extends StatefulWidget {
  final HouseholdModel? existingHousehold;
  const HouseholdFormPage({super.key, this.existingHousehold});

  @override
  State<HouseholdFormPage> createState() => _HouseholdFormPageState();
}

class _HouseholdFormPageState extends State<HouseholdFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _unitCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _purokCtrl;
  bool _isSaving = false;

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  bool get _isEditing => widget.existingHousehold != null;

  static const _purokOptions = [
    'Purok 1',
    'Purok 2',
    'Purok 3',
    'Purok 4',
    'Purok 5',
    'Purok 6',
    'Purok 7',
    'Purok 8',
  ];
  String? _selectedPurok;

  // ── Members state ──────────────────────────────────────────────────────────
  final List<_MemberDraft> _members = [];

  @override
  void initState() {
    super.initState();
    final h = widget.existingHousehold;
    _unitCtrl = TextEditingController(text: h?.unitNo ?? '');
    _streetCtrl = TextEditingController(text: h?.streetAddress ?? '');
    _purokCtrl = TextEditingController(text: h?.purok ?? '');
    _selectedPurok = (h?.purok != null && _purokOptions.contains(h!.purok))
        ? h.purok
        : null;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _unitCtrl.dispose();
    _streetCtrl.dispose();
    _purokCtrl.dispose();
    super.dispose();
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final newId = 'H_${now.millisecondsSinceEpoch}';

      // 1. Create household
      await supabase.from('households').insert({
        'id': newId,
        'unit_no': _unitCtrl.text.trim(),
        'street_address': _streetCtrl.text.trim(),
        'purok': _purokCtrl.text.trim(),
        'date_created': now.toIso8601String(),
      });

      // 2. Insert members
      for (final m in _members) {
        await supabase.from('members').insert({
          'household_id': newId,
          'full_name': m.fullName,
          'role': m.role,
          'gender': m.gender,
          'age': m.age,
        });

        // 3. If member came from user_profiles search, link their profile
        if (m.userId != null) {
          await supabase
              .from('user_profiles')
              .update({'household_id': newId})
              .eq('id', m.userId!);
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('SAVE ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save household')),
        );
      }
    }

    if (mounted) setState(() => _isSaving = false);
  }

  // ── Show Add Member Sheet ──────────────────────────────────────────────────

  void _showAddMemberSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMemberSheet(
        onAdd: (draft) {
          setState(() => _members.add(draft));
        },
      ),
    );
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: _kPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Household' : 'New Household',
          style: const TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kPrimary,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    style: TextButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 60),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroBanner(isEditing: _isEditing),
                  const SizedBox(height: 16),

                  // ── Address Section ──
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address Information',
                    subtitle: 'Enter the household\'s location details.',
                    child: Column(
                      children: [
                        _FormField(
                          controller: _unitCtrl,
                          label: 'Unit / House No.',
                          hint: 'e.g. Unit 5A, House 12',
                          icon: Icons.home_outlined,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Unit number is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _streetCtrl,
                          label: 'Street Address',
                          hint: 'e.g. 20 Sampaguita Street',
                          icon: Icons.signpost_outlined,
                          maxLines: 2,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Street address is required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Purok Section ──
                  _SectionCard(
                    icon: Icons.map_outlined,
                    title: 'Purok / Zone',
                    subtitle: 'Select the purok this household belongs to.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel(label: 'Purok', required: true),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _purokOptions.map((p) {
                            final selected = _selectedPurok == p;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedPurok = p;
                                _purokCtrl.text = p;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? _kPrimary : _kPrimaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected ? _kPrimary : _kBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : _kPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _purokCtrl,
                          label: 'Or type custom purok name',
                          hint: 'e.g. Sitio Bagong Pag-asa',
                          icon: Icons.edit_outlined,
                          required: false,
                          onChanged: (_) =>
                              setState(() => _selectedPurok = null),
                          validator: (v) {
                            if (_selectedPurok == null &&
                                (v == null || v.trim().isEmpty)) {
                              return 'Please select or enter a purok';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Members Section ──
                  _SectionCard(
                    icon: Icons.people_outline_rounded,
                    title: 'Household Members',
                    subtitle: 'Search existing residents or add manually.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Member list
                        if (_members.isNotEmpty) ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _members.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final m = _members[i];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _kBg,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(color: _kBorder),
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _kPrimaryLight,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: _kBorder),
                                      ),
                                      child: Text(
                                        m.initials,
                                        style: const TextStyle(
                                          color: _kPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.fullName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _kInk,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${m.role} · ${m.gender} · ${m.age} yrs',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: _kInk2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Source badge
                                    if (m.isFromSearch)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _kSuccessLight,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Linked',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: _kSuccess,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 6),
                                    // Remove
                                    GestureDetector(
                                      onTap: () => _removeMember(i),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: _kDanger.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: _kDanger,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Add member button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _showAddMemberSheet,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kPrimary,
                              side: const BorderSide(
                                color: _kBorder,
                                width: 1.5,
                              ),
                              backgroundColor: _kPrimaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            icon: const Icon(
                              Icons.person_add_outlined,
                              size: 16,
                            ),
                            label: Text(
                              _members.isEmpty
                                  ? 'Add Member'
                                  : 'Add Another Member',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        if (_members.isEmpty) ...[
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              'Optional — members can also be added later.',
                              style: TextStyle(fontSize: 11, color: _kInk3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: _kPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _kPrimary,
                          size: 15,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Linked members will have their profile connected to this household automatically.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _kPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        disabledBackgroundColor: _kPrimary.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        elevation: 0,
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.add_home_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : _isEditing
                            ? 'Update Household'
                            : 'Create Household',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Add Member Sheet
// ============================================================================

class _AddMemberSheet extends StatefulWidget {
  final void Function(_MemberDraft) onAdd;
  const _AddMemberSheet({required this.onAdd});

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  // Tabs: 0 = Search, 1 = Manual
  int _tab = 0;

  // Search state
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // Manual form
  final _manualFormKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  String _selectedRole = 'Head';
  String _selectedGender = 'Male';

  static const _roles = [
    'Head',
    'Spouse',
    'Son',
    'Daughter',
    'Parent',
    'Sibling',
    'Relative',
    'Other',
  ];
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final res = await supabase
          .from('user_profiles')
          .select('id, first_name, last_name, gender, date_of_birth')
          .or(
            'first_name.ilike.%${query.trim()}%,last_name.ilike.%${query.trim()}%',
          )
          .limit(10);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(res as List);
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchError = 'Search failed. Try again.';
      });
    }
  }

  int _calcAge(String? dob) {
    if (dob == null || dob.isEmpty) return 0;
    try {
      final dt = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  void _pickFromSearch(Map<String, dynamic> user) {
    final fullName = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'
        .trim();
    final age = _calcAge(user['date_of_birth']);

    // Show role picker before adding
    _showRolePickerForSearch(
      fullName: fullName,
      userId: user['id'].toString(),
      gender: user['gender'] ?? 'Male',
      age: age,
    );
  }

  void _showRolePickerForSearch({
    required String fullName,
    required String userId,
    required String gender,
    required int age,
  }) {
    String role = 'Head';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: _kCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Role for $fullName',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _kInk,
            ),
          ),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roles.map((r) {
              final sel = role == r;
              return GestureDetector(
                onTap: () => setLocal(() => role = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : _kPrimaryLight,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: sel ? _kPrimary : _kBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _kPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _kInk2)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onAdd(
                  _MemberDraft(
                    userId: userId,
                    fullName: fullName,
                    role: role,
                    gender: gender,
                    age: age,
                    isFromSearch: true,
                  ),
                );
                Navigator.pop(context); // close sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Add Member',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitManual() {
    if (!_manualFormKey.currentState!.validate()) return;
    widget.onAdd(
      _MemberDraft(
        fullName: _nameCtrl.text.trim(),
        role: _selectedRole,
        gender: _selectedGender,
        age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
        isFromSearch: false,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Member',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Search resident or enter manually',
                        style: TextStyle(fontSize: 12, color: _kInk3),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _kInk2,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: _kPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tab switcher
              Container(
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _kBorder),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _tab_(0, Icons.search_rounded, 'Search Resident'),
                    _tab_(1, Icons.edit_outlined, 'Enter Manually'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab content
              if (_tab == 0) _buildSearchTab() else _buildManualTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab_(int index, IconData icon, String label) {
    final sel = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: sel ? _kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: sel ? Colors.white : _kInk3),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : _kInk3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search Tab ─────────────────────────────────────────────────────────────

  Widget _buildSearchTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => _search(v),
          style: const TextStyle(fontSize: 13, color: _kInk),
          decoration: InputDecoration(
            hintText: 'Search by first or last name...',
            hintStyle: const TextStyle(color: _kInk3, fontSize: 13),
            prefixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.search_rounded, color: _kPrimary, size: 18),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _kInk3,
                    ),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchResults = []);
                    },
                  )
                : null,
            filled: true,
            fillColor: _kBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Error
        if (_searchError != null)
          Text(
            _searchError!,
            style: const TextStyle(fontSize: 12, color: _kDanger),
          ),

        // Results
        if (_searchResults.isEmpty &&
            _searchCtrl.text.isNotEmpty &&
            !_isSearching)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  color: _kInk3,
                  size: 28,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No residents found.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kInk2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _tab = 1),
                  child: const Text(
                    'Enter manually instead →',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = _searchResults[i];
              final fullName =
                  '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
              final age = _calcAge(u['date_of_birth']);
              final initials = fullName.isNotEmpty
                  ? fullName
                        .split(' ')
                        .where((p) => p.isNotEmpty)
                        .take(2)
                        .map((p) => p[0])
                        .join()
                        .toUpperCase()
                  : '?';

              return GestureDetector(
                onTap: () => _pickFromSearch(u),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: _kBorder),
                        ),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: _kPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kInk,
                              ),
                            ),
                            Text(
                              '${u['gender'] ?? ''} · ${age > 0 ? '$age yrs' : 'Age unknown'}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kInk2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Select',
                          style: TextStyle(
                            fontSize: 11,
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        if (_searchResults.isEmpty && _searchCtrl.text.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: const Column(
              children: [
                Icon(Icons.manage_search_rounded, color: _kInk3, size: 28),
                SizedBox(height: 6),
                Text(
                  'Type a name to search registered residents.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _kInk3),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Manual Tab ─────────────────────────────────────────────────────────────

  Widget _buildManualTab() {
    return Form(
      key: _manualFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            controller: _nameCtrl,
            label: 'Full Name',
            hint: 'e.g. Juan dela Cruz',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),

          // Role chips
          const _FieldLabel(label: 'Role / Relationship'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roles.map((r) {
              final sel = _selectedRole == r;
              return GestureDetector(
                onTap: () => setState(() => _selectedRole = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? _kPrimary : _kPrimaryLight,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: sel ? _kPrimary : _kBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : _kPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Gender chips
          const _FieldLabel(label: 'Gender'),
          const SizedBox(height: 8),
          Row(
            children: _genders.map((g) {
              final sel = _selectedGender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? _kPrimary : _kPrimaryLight,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: sel ? _kPrimary : _kBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      g,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _kPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          _FormField(
            controller: _ageCtrl,
            label: 'Age',
            hint: 'e.g. 32',
            icon: Icons.cake_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Age is required';
              if (int.tryParse(v.trim()) == null) return 'Enter a valid age';
              return null;
            },
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _submitManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              icon: const Icon(Icons.person_add_rounded, size: 16),
              label: const Text(
                'Add Member',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Reusable Widgets
// ============================================================================

class _HeroBanner extends StatelessWidget {
  final bool isEditing;
  const _HeroBanner({required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.add_home_work_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Household' : 'Register New Household',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details and add household members.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.5,
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

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: _kPrimary, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: _kInk2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool required;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = true,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13,
            color: _kInk,
            fontWeight: FontWeight.w500,
          ),
          validator:
              validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                        ? '$label is required'
                        : null
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kInk3, fontSize: 13),
            prefixIcon: Icon(icon, size: 17, color: _kInk3),
            filled: true,
            fillColor: _kBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kDanger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kDanger, width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: _kDanger),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _kInk,
          ),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: _kDanger, fontSize: 12)),
      ],
    );
  }
}

// ============================================================================
// Stats Banner
// ============================================================================

class _StatsBanner extends StatelessWidget {
  final int total;
  final int memberCount;
  final VoidCallback onAdd;
  const _StatsBanner({
    required this.total,
    required this.memberCount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.home_work_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total Registered Households',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$memberCount Total Members',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

// ============================================================================
// Household Card
// ============================================================================

class _HouseholdCard extends StatelessWidget {
  final HouseholdModel household;
  final VoidCallback onTap;
  const _HouseholdCard({required this.household, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: _kPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    household.unitNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _kInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    household.streetAddress,
                    style: const TextStyle(fontSize: 11, color: _kInk2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _kPrimaryLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          household.purok,
                          style: const TextStyle(
                            fontSize: 10,
                            color: _kPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${household.memberCount} members',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _kInk3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _kInk3,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  'Since ${household.dateCreated.length >= 4 ? household.dateCreated.substring(0, 4) : household.dateCreated}',
                  style: const TextStyle(fontSize: 10, color: _kInk3),
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
// Empty State
// ============================================================================

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: _kPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No households found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _kInk,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try adjusting your search or add a new household.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _kInk2, height: 1.5),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text(
                  'Add Household',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Household Detail Sheet
// ============================================================================

class _HouseholdDetailSheet extends StatelessWidget {
  final HouseholdModel household;
  const _HouseholdDetailSheet({required this.household});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: _kPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      household.unitNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _kInk,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      household.streetAddress,
                      style: const TextStyle(fontSize: 12, color: _kInk2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  household.purok,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _kBorder, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Household Members',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _kInk,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${household.memberCount} members',
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (household.members.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person_outline_rounded, color: _kInk3, size: 28),
                  SizedBox(height: 6),
                  Text(
                    'No members registered yet.',
                    style: TextStyle(fontSize: 12, color: _kInk2),
                  ),
                ],
              ),
            )
          else
            ...household.members.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: _kPrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: _kPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        m.fullName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kInk,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: m.role == 'Head'
                            ? _kPrimaryLight
                            : _kSuccessLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        m.role,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: m.role == 'Head' ? _kPrimary : _kSuccess,
                        ),
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
