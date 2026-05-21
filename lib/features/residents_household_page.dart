import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ============================================================================
// Design Tokens — shared with household_creation_page.dart
// ============================================================================

class AppColors {
  // Brand
  static const Color primary = Color(0xFF7C3AED); // violet-600
  static const Color primaryHov = Color(0xFF6D28D9); // violet-700
  static const Color p50 = Color(0xFFF5F3FF);
  static const Color p100 = Color(0xFFEDE9FE);
  static const Color p200 = Color(0xFFDDD6FE);
  static const Color p300 = Color(0xFFC4B5FD);
  static const Color p400 = Color(0xFFA78BFA);
  static const Color p500 = Color(0xFF8B5CF6);
  static const Color p600 = Color(0xFF7C3AED);
  static const Color p700 = Color(0xFF6D28D9);
  static const Color p800 = Color(0xFF1E1040);

  // Neutrals
  static const Color bg = Color(0xFFF5F4FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDE9FE);
  static const Color ink = Color(0xFF1A1033);
  static const Color ink2 = Color(0xFF6B6480);
  static const Color ink3 = Color(0xFFA09BB5);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFEDFAF3);
  static const Color danger = Color(0xFFDC2626);

  // Legacy aliases kept for widget reuse
  static const Color p0 = card;
}

// ============================================================================
// Data Model
// ============================================================================

class HouseholdMember {
  final int id;
  final String name;
  final String initials;
  final String rel;
  final int age;
  final String gender;
  final String civil;
  final String edu;
  final String work;
  final String philhealth;
  final bool pwd;

  const HouseholdMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.rel,
    required this.age,
    required this.gender,
    required this.civil,
    required this.edu,
    required this.work,
    required this.philhealth,
    required this.pwd,
  });
}

// ============================================================================
// Household Screen
// ============================================================================

class HouseholdScreen extends StatefulWidget {
  const HouseholdScreen({super.key});

  @override
  State<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends State<HouseholdScreen> {
  final List<HouseholdMember> members = const [
    HouseholdMember(
      id: 1,
      name: 'Juan Reyes',
      initials: 'JR',
      rel: 'Household Head',
      age: 40,
      gender: 'Male',
      civil: 'Married',
      edu: 'College Graduate',
      work: 'Construction Worker',
      philhealth: 'Yes',
      pwd: false,
    ),
    HouseholdMember(
      id: 2,
      name: 'Maria Reyes',
      initials: 'MR',
      rel: 'Spouse',
      age: 38,
      gender: 'Female',
      civil: 'Married',
      edu: 'High School Graduate',
      work: 'Homemaker',
      philhealth: 'Yes',
      pwd: false,
    ),
    HouseholdMember(
      id: 3,
      name: 'Carlo Reyes',
      initials: 'CR',
      rel: 'Son',
      age: 15,
      gender: 'Male',
      civil: 'Single',
      edu: 'Junior High School',
      work: 'Student',
      philhealth: 'No',
      pwd: false,
    ),
    HouseholdMember(
      id: 4,
      name: 'Lea Reyes',
      initials: 'LR',
      rel: 'Daughter',
      age: 11,
      gender: 'Female',
      civil: 'Single',
      edu: 'Elementary',
      work: 'Student',
      philhealth: 'No',
      pwd: false,
    ),
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(14),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'My Household',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 14),
            _buildStatsRow(),
            const SizedBox(height: 14),
            _buildNoticeBar(),
            const SizedBox(height: 14),
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildMembersHeader(),
            const SizedBox(height: 10),
            _buildMembersList(),
            const SizedBox(height: 20),
            _buildRequestButton(),
          ],
        ),
      ),
    );
  }

  // ── Hero Card ──────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.maps_home_work_outlined,
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
                  'YOUR HOUSEHOLD',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Reyes Family',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Unit 4B · Blk 2, Mabini St. · Brgy. San Miguel',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Active · Registered since Jan 2021',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = [
      _StatItem(value: '4', label: 'Total', icon: Icons.people_outline_rounded),
      _StatItem(
        value: '2',
        label: 'Adults',
        icon: Icons.person_outline_rounded,
      ),
      _StatItem(value: '2', label: 'Children', icon: Icons.child_care_rounded),
      _StatItem(value: '1', label: 'Head', icon: Icons.star_outline_rounded),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(s.icon, color: AppColors.primary, size: 18),
                const SizedBox(height: 5),
                Text(
                  s.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  s.label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.ink3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Notice Bar ─────────────────────────────────────────────────────────────

  Widget _buildNoticeBar() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.p50,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 15,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'This information was recorded by the Barangay Hall. To request changes, tap a member or use the update button below.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.p600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Section ───────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(Icons.home_outlined, 'Household Details'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Column(
              children: [
                _infoRow('Household type', 'Nuclear'),
                _divider(),
                _infoRow('Ownership', 'Renter'),
                _divider(),
                _infoRow('Monthly income', '₱20,000 – ₱30,000'),
                _divider(),
                _infoRow('Contact number', '09171234567'),
                _divider(),
                _infoRow('Last updated', 'Apr 3, 2026'),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.p50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: AppColors.border, height: 1, thickness: 1);

  // ── Members Header ─────────────────────────────────────────────────────────

  Widget _buildMembersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Household Members',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.p50,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '${members.length} members',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ── Members List ───────────────────────────────────────────────────────────

  Widget _buildMembersList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = members[i];
        final isHead = m.rel.toLowerCase().contains('head');
        return InkWell(
          onTap: () => _showMemberSheet(m),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.p100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.p200),
                  ),
                  child: Text(
                    m.initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${m.rel} · ${m.gender}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isHead ? AppColors.p50 : AppColors.successBg,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isHead
                          ? AppColors.p200
                          : AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${m.age} yrs',
                    style: TextStyle(
                      fontSize: 11,
                      color: isHead ? AppColors.primary : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.ink3,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Request Button ─────────────────────────────────────────────────────────

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () => _showRequestUpdateSheet(null),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.edit_note_rounded, size: 18),
        label: const Text(
          'Request Household Update',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ── Member Detail Sheet ────────────────────────────────────────────────────

  void _showMemberSheet(HouseholdMember m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberDetailSheet(
        member: m,
        onRequestCorrection: () {
          Navigator.pop(context);
          _showRequestUpdateSheet(m.name);
        },
      ),
    );
  }

  void _showRequestUpdateSheet(String? prefillName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequestUpdateSheet(),
    ).then((submitted) {
      if (submitted == true) {
        _showToast('Update request submitted — Barangay Hall will review it');
      }
    });
  }
}

// ============================================================================
// Stat Item Data Class
// ============================================================================

class _StatItem {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });
}

// ============================================================================
// Member Detail Sheet
// ============================================================================

class _MemberDetailSheet extends StatelessWidget {
  final HouseholdMember member;
  final VoidCallback onRequestCorrection;

  const _MemberDetailSheet({
    required this.member,
    required this.onRequestCorrection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Member Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'View-only · Managed by Barangay',
                      style: TextStyle(fontSize: 12, color: AppColors.ink3),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.ink2,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(backgroundColor: AppColors.p50),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 18),

            // Avatar
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.p100,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.p300, width: 2),
              ),
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              member.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.p50,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.p200),
              ),
              child: Text(
                member.rel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info grid
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  _row('Age', '${member.age} years old'),
                  _div(),
                  _row('Gender', member.gender),
                  _div(),
                  _row('Civil status', member.civil),
                  _div(),
                  _row('Education', member.edu),
                  _div(),
                  _row('Occupation', member.work),
                  _div(),
                  _row('PhilHealth', member.philhealth),
                  _div(),
                  _row('PWD', member.pwd ? 'Yes' : 'No'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Correction banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.p50,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'IS THIS INFO INCORRECT?',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.ink3,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'If any details are wrong or outdated, you can request a correction from the Barangay Hall.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.ink2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onRequestCorrection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'Request correction for ${member.name.split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: AppColors.ink3)),
        Text(
          v,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    ),
  );

  Widget _div() =>
      const Divider(color: AppColors.border, height: 1, thickness: 1);
}

// ============================================================================
// Request Update Sheet
// ============================================================================

class RequestUpdateSheet extends StatefulWidget {
  const RequestUpdateSheet({super.key});

  @override
  State<RequestUpdateSheet> createState() => _RequestUpdateSheetState();
}

class _RequestUpdateSheetState extends State<RequestUpdateSheet> {
  String _selectedType = 'Correction';
  String _selectedMember = 'Entire household';

  static const _types = [
    'Correction',
    'Add member',
    'Remove member',
    'Update contact',
    'Other',
  ];
  static const _members = [
    'Entire household',
    'Juan Reyes (Head)',
    'Maria Reyes (Spouse)',
    'Carlo Reyes (Son)',
    'Lea Reyes (Daughter)',
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Request Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Sent to Barangay Hall for review',
                        style: TextStyle(fontSize: 12, color: AppColors.ink3),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.ink2,
                      size: 18,
                    ),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(backgroundColor: AppColors.p50),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Request type chips
              _label('REQUEST TYPE'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final sel = _selectedType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.p50,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Member dropdown
              _label('WHICH MEMBER?'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedMember,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                items: _members
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedMember = v);
                },
              ),
              const SizedBox(height: 18),

              // Details field
              _label('DETAILS'),
              const SizedBox(height: 8),
              _textField(
                hint: 'Describe what needs to be updated...',
                maxLines: 3,
              ),
              const SizedBox(height: 18),

              // Supporting note
              _label('SUPPORTING NOTE (OPTIONAL)'),
              const SizedBox(height: 8),
              _textField(hint: 'e.g. New birth certificate available'),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Submit to Barangay Hall',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      color: AppColors.ink3,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
  );

  Widget _textField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.ink,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.ink3, fontSize: 13),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
