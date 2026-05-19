import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/chart.dart';
import '../core/utils/route_utils.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _kBg           = Color(0xFFF5F4FA);
const _kSurface      = Color(0xFFFFFFFF);
const _kSurface2     = Color(0xFFF5F0FF);
const _kBorder       = Color(0xFFEBE0FF);
const _kAccent       = Color(0xFF8B2CF5);
const _kText         = Color(0xFF1E0447);
const _kText2        = Color(0xFF360C78);
const _kText3        = Color(0xFF6B7280);
const _kGreen        = Color(0xFF16A34A);
const _kGreenBg      = Color(0xFFDCFCE7);
const _kGreenBorder  = Color(0xFF86EFAC);
const _kRed          = Color(0xFFDC2626);
const _kRedBg        = Color(0xFFFEF2F2);
const _kRedBorder    = Color(0xFFFCA5A5);
const _kAccentBg     = Color(0xFFF5F0FF);
const _kAccentBorder = Color(0xFFEBE0FF);
const _kGray         = Color(0xFF6B7280);
const _kGrayBg       = Color(0xFFF3F4F6);
const _kGrayBorder   = Color(0xFFD1D5DB);

// ─── Supabase Profile Model ───────────────────────────────────────────────────
class ProfileData {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? birthDate;
  final String? gender;
  final String? citizenship;
  final String? email;
  final String? country;
  final String? stateProvince;
  final String? cityMunicipality;
  final String? barangay;
  final String? streetAddress;
  final String? postalCode;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final bool isActive;

  const ProfileData({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.birthDate,
    this.gender,
    this.citizenship,
    this.email,
    this.country,
    this.stateProvince,
    this.cityMunicipality,
    this.barangay,
    this.streetAddress,
    this.postalCode,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name']?.toString() ?? '',
      middleName: map['middle_name']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      birthDate: map['birth_date']?.toString(),
      gender: map['gender']?.toString(),
      citizenship: map['citizenship']?.toString(),
      email: map['email']?.toString(),
      country: map['country']?.toString(),
      stateProvince: map['state_province']?.toString(),
      cityMunicipality: map['city_municipality']?.toString(),
      barangay: map['barangay']?.toString(),
      streetAddress: map['street_address']?.toString(),
      postalCode: map['postal_code']?.toString(),
      role: map['role']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      isActive: map['is_active'] ?? true,
    );
  }

  String get fullName =>
      [firstName, middleName, lastName].where((p) => p.isNotEmpty).join(' ');

  String get initials {
    final parts = [firstName, lastName.isNotEmpty ? lastName : middleName];
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }

  static String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $h:$m $ampm';
    } catch (_) {
      return raw;
    }
  }

  String get formattedCreatedAt => _formatTimestamp(createdAt);
  String get formattedUpdatedAt => _formatTimestamp(updatedAt);

  String get fullAddress {
    final parts = [
      streetAddress, barangay, cityMunicipality,
      stateProvince, country, postalCode,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class UserData {
  final String profileId;
  final String userId, firstName, middleName, lastName;
  final String sex, birthday, civilStatus, contactNo;
  final String residency, houseNo, street, purok, barangay, dateReg;
  final String email;
  final String role;
  final bool isActive;

  const UserData({
    this.profileId = '',
    required this.userId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.sex,
    required this.birthday,
    required this.civilStatus,
    required this.contactNo,
    required this.residency,
    required this.houseNo,
    required this.street,
    required this.purok,
    this.barangay = 'Unspecified',
    required this.dateReg,
    this.email = '',
    this.role = '',
    this.isActive = true,
  });

  String get fullName => '$firstName $middleName $lastName'.trim();

  String get initials {
    final parts = [firstName, lastName.isNotEmpty ? lastName : middleName];
    return parts
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();
  }

  factory UserData.fromProfile(ProfileData p) {
    return UserData(
      profileId: p.id,
      userId: p.id.length >= 8
          ? p.id.substring(0, 8).toUpperCase()
          : p.id.toUpperCase(),
      firstName: p.firstName,
      middleName: p.middleName,
      lastName: p.lastName,
      sex: p.gender ?? '—',
      birthday: p.birthDate ?? '—',
      civilStatus: '—',
      contactNo: '—',
      residency: 'Resident',
      houseNo: '—',
      street: p.streetAddress ?? '—',
      purok: '—',
      barangay: p.barangay ?? 'Unspecified',
      dateReg: p.formattedCreatedAt,
      email: p.email ?? '',
      role: p.role ?? 'User',
      isActive: p.isActive,
    );
  }
}

// ─── Avatar Colors ─────────────────────────────────────────────────────────────
const _avatarColors = [
  Color(0xFF7C3AED),
  Color(0xFF2563EB),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
  Color(0xFF059669),
];
Color _avatarColor(int i) => _avatarColors[i % _avatarColors.length];

// ══════════════════════════════════════════════════════════════════════════════
// USER MANAGEMENT PAGE
// ══════════════════════════════════════════════════════════════════════════════
class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement>
    with SingleTickerProviderStateMixin {
  String _search = '';
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;
  List<UserData> _users = [];

  late TabController _tabCtrl;
  final _statusTabs = ['all', 'active', 'inactive'];

  String get _filterStatus => _statusTabs[_tabCtrl.index];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _statusTabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
    _fetchUsers();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .order('first_name');

      final profiles = response
          .map((m) => ProfileData.fromMap(m as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _users = profiles.map((p) => UserData.fromProfile(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR FETCHING: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
        );
      }
    }
  }

  List<UserData> get _filteredUsers {
    return _users.where((u) {
      final passesStatus = switch (_filterStatus) {
        'active'   => u.isActive,
        'inactive' => !u.isActive,
        _          => true,
      };
      final q = _search.toLowerCase();
      final passesSearch = q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.userId.toLowerCase().contains(q) ||
          u.barangay.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
      return passesStatus && passesSearch;
    }).toList();
  }

  int get _totalCount    => _users.length;
  int get _activeCount   => _users.where((u) => u.isActive).length;
  int get _inactiveCount => _users.where((u) => !u.isActive).length;

  Map<String, int> get _counts => {
    'all':      _totalCount,
    'active':   _activeCount,
    'inactive': _inactiveCount,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final counts   = _counts;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Management',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),

      // ── Single scroll container for the entire body ──────────────────────
      body: RefreshIndicator(
        color: _kAccent,
        onRefresh: _fetchUsers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Stat Pills ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    _StatPill('${counts['active']}',   'Active',   _kGreen,  _kGreenBg,  _kGreenBorder),
                    const SizedBox(width: 8),
                    _StatPill('${counts['inactive']}', 'Inactive', _kRed,    _kRedBg,    _kRedBorder),
                    const SizedBox(width: 8),
                    _StatPill('${counts['all']}',      'Total',    _kAccent, _kAccentBg, _kAccentBorder),
                  ],
                ),
              ),

              // ── Search Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: _kText, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search name, ID, barangay…',
                      hintStyle: const TextStyle(color: _kText3, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: _kText3, size: 18),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: _kText3),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // ── Tab Bar ──────────────────────────────────────────────────
              _buildTabs(counts),

              // ── List Content ─────────────────────────────────────────────
              if (_isLoading && _users.isEmpty)
                const SizedBox(
                  height: 320,
                  child: Center(
                    child: CircularProgressIndicator(color: _kAccent),
                  ),
                )
              else if (filtered.isEmpty)
                SizedBox(
                  height: 320,
                  child: _EmptyState(filter: _filterStatus),
                )
              else
                ListView.separated(
                  // Nested inside SingleChildScrollView — must be non-scrollable
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _UserCard(
                    user: filtered[i],
                    avatarIndex: i,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        instantRoute(UserDetailPage(
                          user: filtered[i],
                          avatarIndex: i,
                        )),
                      );
                      if (result == true) _fetchUsers();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'Active', 'Inactive'];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: _kAccent,
        unselectedLabelColor: _kText3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        indicatorColor: _kAccent,
        indicatorWeight: 2.5,
        tabAlignment: TabAlignment.start,
        tabs: List.generate(labels.length, (i) {
          final key = _statusTabs[i];
          final isSelected = _tabCtrl.index == i;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(labels[i]),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? _kAccentBg : _kGrayBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${counts[key]}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? _kAccent : _kText3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Stat Pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String count, label;
  final Color fg, bg, border;
  const _StatPill(this.count, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserData user;
  final int avatarIndex;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.avatarIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(avatarIndex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        _IconText(Icons.sell_outlined, 'ID: ${user.userId}', 11),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            if (user.email.isNotEmpty)
                              _IconText(Icons.email_outlined, user.email, 11),
                            _IconText(Icons.location_on_outlined, user.barangay, 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _UserStatusBadge(isActive: user.isActive),
                            if (user.role.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _RoleBadge(role: user.role),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _IconText(Icons.calendar_today_rounded, user.dateReg, 9),
                  const Spacer(),
                  _ActionBtn(
                    label: 'View',
                    icon: Icons.arrow_forward_ios_rounded,
                    color: _kAccent,
                    onTap: onTap,
                    filled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Icon Text ────────────────────────────────────────────────────────────────
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;
  const _IconText(this.icon, this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: _kText3),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontSize: size, color: _kText3),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── User Status Badge ────────────────────────────────────────────────────────
class _UserStatusBadge extends StatelessWidget {
  final bool isActive;
  const _UserStatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? _kGreenBg : _kRedBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? _kGreenBorder : _kRedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline_rounded : Icons.do_not_disturb_rounded,
            size: 10,
            color: isActive ? _kGreen : _kRed,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isActive ? _kGreen : _kRed,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Role Badge ───────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kAccentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccentBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_outlined, size: 10, color: _kAccent),
          const SizedBox(width: 4),
          Text(
            role,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: _kAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(filled ? 1 : 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kAccentBg,
              shape: BoxShape.circle,
              border: Border.all(color: _kAccentBorder),
            ),
            child: const Icon(Icons.people_outline_rounded, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'No users found',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText),
          ),
          const SizedBox(height: 5),
          Text(
            filter == 'all'
                ? 'No registered users yet.'
                : 'No $filter users found.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kText,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// USER DETAIL PAGE
// ══════════════════════════════════════════════════════════════════════════════

class _Role {
  final String title, description;
  final IconData icon;
  const _Role({required this.title, required this.description, required this.icon});
}

const _kRoles = [
  _Role(title: 'Administrator',  description: 'Full access to all features and settings', icon: Icons.shield_outlined),
  _Role(title: 'Barangay Staff', description: 'Can manage records and view reports',       icon: Icons.people_outlined),
  _Role(title: 'Verifier',       description: 'Can verify users and view records',         icon: Icons.verified_user_outlined),
  _Role(title: 'Viewer',         description: 'Can view records only',                     icon: Icons.visibility_outlined),
];

class UserDetailPage extends StatefulWidget {
  final UserData user;
  final int avatarIndex;

  const UserDetailPage({super.key, required this.user, required this.avatarIndex});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _verifySelected = true;
  _Role? _selectedRole;
  bool _roleDropdownOpen = false;
  final _notesCtrl = TextEditingController();

  ProfileData? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _fetchError;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // Listener triggers rebuild so tab content switches without TabBarView
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && mounted) setState(() {});
    });
    _fetchProfile();
    _selectedRole = _kRoles.cast<_Role?>().firstWhere(
          (r) => r?.title == widget.user.role,
      orElse: () => null,
    );
    _verifySelected = widget.user.isActive;
  }

  Future<void> _fetchProfile() async {
    final pid = widget.user.profileId.trim();
    if (pid.isEmpty) return;
    setState(() {
      _isLoading = true;
      _fetchError = null;
    });
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', pid)
          .maybeSingle();
      if (!mounted) return;
      if (response == null) {
        setState(() { _fetchError = 'No profile found.'; _isLoading = false; });
        return;
      }
      setState(() { _profile = ProfileData.fromMap(response); _isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _fetchError = 'Error: $e'; _isLoading = false; });
    }
  }

  Future<void> _updateUser() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a role first.'),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.from('profiles').update({
        'role':       _selectedRole!.title,
        'is_active':  _verifySelected,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.user.profileId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${_verifySelected ? 'verified' : 'updated'} as ${_selectedRole!.title}',
          ),
          backgroundColor: _verifySelected ? _kGreen : _kRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u     = widget.user;
    final color = _avatarColor(widget.avatarIndex);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Detail',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),

      // ── Entire body is one SingleChildScrollView ─────────────────────────
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Profile Header Card ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withOpacity(0.25)),
                            ),
                            child: Center(
                              child: Text(
                                u.initials,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _kSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                u.isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 16,
                                color: u.isActive ? _kGreen : _kRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _IconText(Icons.sell_outlined,        'ID: ${u.userId}', 11),
                            const SizedBox(height: 2),
                            _IconText(Icons.location_on_outlined, u.barangay,        11),
                          ],
                        ),
                      ),
                      _UserStatusBadge(isActive: u.isActive),
                    ],
                  ),
                ),
              ),

              // ── Tab Selector ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: _kAccentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _kAccent,
                    unselectedLabelColor: _kText3,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_rounded, size: 14),
                            SizedBox(width: 5),
                            Text('Verify User'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14),
                            SizedBox(width: 5),
                            Text('Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab Content — rendered inline, no TabBarView ──────────────
              // AnimatedSwitcher gives a gentle fade when switching tabs
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _tabCtrl.index == 0
                    ? _VerifyTab(
                  key: const ValueKey('verify'),
                  verifySelected: _verifySelected,
                  selectedRole: _selectedRole,
                  roleDropdownOpen: _roleDropdownOpen,
                  notesCtrl: _notesCtrl,
                  isSaving: _isSaving,
                  onVerifyChanged: (v) => setState(() => _verifySelected = v),
                  onRoleChanged: (r) => setState(() {
                    _selectedRole = r;
                    _roleDropdownOpen = false;
                  }),
                  onToggleDropdown: () =>
                      setState(() => _roleDropdownOpen = !_roleDropdownOpen),
                  onCancel: () => Navigator.pop(context),
                  onSave: _updateUser,
                )
                    : _DetailsTab(
                  key: const ValueKey('details'),
                  fallbackUser: u,
                  profile: _profile,
                  isLoading: _isLoading,
                  error: _fetchError,
                  onRetry: _fetchProfile,
                  onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon…')),
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

// ─── Verify Tab ───────────────────────────────────────────────────────────────
// Plain Column — the parent SingleChildScrollView handles scrolling
class _VerifyTab extends StatelessWidget {
  final bool verifySelected, roleDropdownOpen, isSaving;
  final _Role? selectedRole;
  final TextEditingController notesCtrl;
  final void Function(bool) onVerifyChanged;
  final void Function(_Role) onRoleChanged;
  final VoidCallback onToggleDropdown, onCancel, onSave;

  const _VerifyTab({
    super.key,
    required this.verifySelected,
    required this.selectedRole,
    required this.roleDropdownOpen,
    required this.notesCtrl,
    required this.isSaving,
    required this.onVerifyChanged,
    required this.onRoleChanged,
    required this.onToggleDropdown,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(label: 'Verification Status'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _VerificationCard(
                  selected: verifySelected,
                  isVerify: true,
                  onTap: () => onVerifyChanged(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VerificationCard(
                  selected: !verifySelected,
                  isVerify: false,
                  onTap: () => onVerifyChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel(label: 'Assign Role'),
          const SizedBox(height: 10),

          // Dropdown trigger
          GestureDetector(
            onTap: onToggleDropdown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(roleDropdownOpen ? 0 : 12),
                  bottomRight: Radius.circular(roleDropdownOpen ? 0 : 12),
                ),
                border: Border.all(color: roleDropdownOpen ? _kAccent : _kBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 18, color: _kText3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedRole?.title ?? 'Select a role',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedRole != null ? _kText : _kText3,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: roleDropdownOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: _kText3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown options
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: roleDropdownOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              decoration: const BoxDecoration(
                color: _kSurface,
                border: Border(
                  left: BorderSide(color: _kAccent),
                  right: BorderSide(color: _kAccent),
                  bottom: BorderSide(color: _kAccent),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: _kRoles
                    .map((role) => _RoleOption(
                  role: role,
                  isSelected: selectedRole?.title == role.title,
                  onTap: () => onRoleChanged(role),
                ))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),
          const _SectionLabel(label: 'Notes (Optional)'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: notesCtrl,
              maxLines: 4,
              maxLength: 250,
              style: const TextStyle(fontSize: 13, color: _kText),
              decoration: const InputDecoration(
                hintText: 'Add a note about this verification…',
                hintStyle: TextStyle(color: _kText3, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
                counterStyle: TextStyle(color: _kText3, fontSize: 11),
              ),
            ),
          ),

          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: _kBorder),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: _kText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                  label: Text(
                    isSaving ? 'Processing…' : 'Verify User',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    disabledBackgroundColor: _kAccent.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Details Tab ──────────────────────────────────────────────────────────────
// Plain Column — scrolling handled by the parent SingleChildScrollView.
// Action buttons sit at the bottom of the column naturally.
class _DetailsTab extends StatelessWidget {
  final UserData fallbackUser;
  final ProfileData? profile;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onEdit;

  const _DetailsTab({
    super.key,
    required this.fallbackUser,
    required this.profile,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onEdit,
  });

  String _v(String? supaVal, String fallback) {
    if (supaVal != null && supaVal.isNotEmpty) return supaVal;
    return fallback.isNotEmpty ? fallback : '—';
  }

  @override
  Widget build(BuildContext context) {
    final u = fallbackUser;
    final p = profile;

    final firstName     = _v(p?.firstName,       u.firstName);
    final middleName    = _v(p?.middleName,       u.middleName);
    final lastName      = _v(p?.lastName,         u.lastName);
    final birthDate     = _v(p?.birthDate,        u.birthday);
    final gender        = _v(p?.gender,           u.sex);
    final citizenship   = p?.citizenship          ?? '—';
    final email         = _v(p?.email,            u.email);
    final role          = _v(p?.role,             u.role);
    final country       = p?.country              ?? '—';
    final stateProvince = p?.stateProvince        ?? '—';
    final cityMun       = p?.cityMunicipality     ?? '—';
    final barangay      = _v(p?.barangay,         u.barangay);
    final streetAddress = _v(p?.streetAddress,    u.street);
    final postalCode    = p?.postalCode           ?? '—';
    final createdAt     = p?.formattedCreatedAt   ?? u.dateReg;
    final updatedAt     = p?.formattedUpdatedAt   ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section content ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) ...[
                _InfoBanner(
                  icon: const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
                  ),
                  message: 'Fetching profile…',
                  fg: _kAccent,
                  bg: _kAccentBg,
                  border: _kAccentBorder,
                ),
                const SizedBox(height: 12),
              ],
              if (!isLoading && error != null) ...[
                _ErrorBanner(message: error!, onRetry: onRetry),
                const SizedBox(height: 12),
              ],
              if (p != null && !isLoading) ...[
                _InfoBanner(
                  icon: const Icon(Icons.cloud_done_outlined, size: 13, color: _kGreen),
                  message: 'Live data from Supabase',
                  fg: _kGreen,
                  bg: _kGreenBg,
                  border: _kGreenBorder,
                ),
                const SizedBox(height: 14),
              ],

              _DetailSection(title: 'Personal Information', rows: [
                _DetailRow(icon: Icons.badge_outlined,         label: 'User ID',     value: u.userId),
                _DetailRow(icon: Icons.person_outline_rounded, label: 'First Name',  value: firstName),
                _DetailRow(icon: Icons.person_outline_rounded, label: 'Middle Name', value: middleName.isNotEmpty ? middleName : '—'),
                _DetailRow(icon: Icons.person_outline_rounded, label: 'Last Name',   value: lastName),
                _DetailRow(icon: Icons.cake_outlined,          label: 'Birth Date',  value: birthDate),
                _DetailRow(icon: Icons.wc_outlined,            label: 'Gender',      value: gender),
                _DetailRow(icon: Icons.flag_outlined,          label: 'Citizenship', value: citizenship, isLast: true),
              ]),
              const SizedBox(height: 14),

              _DetailSection(title: 'Contact Information', rows: [
                _DetailRow(icon: Icons.email_outlined, label: 'Email', value: email, isLast: true),
              ]),
              const SizedBox(height: 14),

              _DetailSection(title: 'Address', rows: [
                _DetailRow(icon: Icons.home_outlined,               label: 'Street',        value: streetAddress),
                _DetailRow(icon: Icons.location_on_outlined,        label: 'Barangay',      value: barangay),
                _DetailRow(icon: Icons.location_city_outlined,      label: 'City / Mun.',   value: cityMun),
                _DetailRow(icon: Icons.map_outlined,                label: 'State / Prov.', value: stateProvince),
                _DetailRow(icon: Icons.public_outlined,             label: 'Country',       value: country),
                _DetailRow(icon: Icons.markunread_mailbox_outlined, label: 'Postal Code',   value: postalCode, isLast: true),
              ]),
              const SizedBox(height: 14),

              _DetailSection(title: 'Account Information', rows: [
                _DetailRow(
                  icon: Icons.shield_outlined,
                  label: 'Status',
                  value: '',
                  customTrailing: _UserStatusBadge(isActive: u.isActive),
                ),
                _DetailRow(
                  icon: Icons.people_outline_rounded,
                  label: 'Role',
                  value: '',
                  customTrailing: _RoleBadge(role: role),
                ),
                _DetailRow(icon: Icons.calendar_month_outlined, label: 'Registered',   value: createdAt),
                _DetailRow(icon: Icons.update_outlined,         label: 'Last Updated', value: updatedAt, isLast: true),
              ]),
              const SizedBox(height: 14),
            ],
          ),
        ),

        // ── Action Buttons — flows naturally at bottom of scroll ───────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: _kSurface,
            border: Border(top: BorderSide(color: _kBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: _kAccent),
                  label: const Text(
                    'Edit User',
                    style: TextStyle(
                      fontSize: 14,
                      color: _kAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: _kAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Detail Section ───────────────────────────────────────────────────────────
class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: title),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Widget? customTrailing;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.customTrailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _kText3),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _kText3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (customTrailing != null)
            customTrailing!
          else
            Flexible(
              child: Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(
                  fontSize: 12,
                  color: _kText2,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Info Banner ──────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final Widget icon;
  final String message;
  final Color fg, bg, border;

  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.fg,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kRedBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kRedBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: _kRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: _kRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Verification Card ────────────────────────────────────────────────────────
class _VerificationCard extends StatelessWidget {
  final bool selected, isVerify;
  final VoidCallback onTap;

  const _VerificationCard({
    required this.selected,
    required this.isVerify,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color  = isVerify ? _kGreen : _kRed;
    final bg     = isVerify ? _kGreenBg : _kRedBg;
    final border = isVerify ? _kGreenBorder : _kRedBorder;
    final icon   = isVerify ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label  = isVerify ? 'Verify Account' : 'Reject Account';
    final desc   = isVerify
        ? 'User will be able to access the system.'
        : 'User will not be able to access the system.';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kAccent : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: selected,
                  onChanged: (_) => onTap(),
                  activeColor: _kAccent,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: border),
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? _kAccent : _kText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: _kText3, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Role Option ──────────────────────────────────────────────────────────────
class _RoleOption extends StatelessWidget {
  final _Role role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _kAccentBg : Colors.transparent,
          border: const Border(top: BorderSide(color: _kBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? _kAccent.withOpacity(0.15) : _kBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                role.icon,
                size: 15,
                color: isSelected ? _kAccent : _kText3,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _kAccent : _kText,
                    ),
                  ),
                  Text(
                    role.description,
                    style: const TextStyle(fontSize: 11, color: _kText3),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 15, color: _kAccent),
          ],
        ),
      ),
    );
  }
}