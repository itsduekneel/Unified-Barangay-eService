import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/chart.dart';
import '../core/utils/route_utils.dart';

// ─── Theme Constants ───────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFEDE9FE);
  static const text = Color(0xFF1A1A2E);
  static const subtext = Color(0xFF9490B0);
  static const border = Color(0xFFE8E5F5);
  static const bg = Color(0xFFF5F4FA);
  static const white = Colors.white;
  static const rowAlt = Color(0xFFFAF9FF);
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFFEBEE);
}

// ─── Supabase Profile Model ────────────────────────────────────────────────────
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
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • ${dt.hour > 12
          ? dt.hour - 12
          : dt.hour == 0
          ? 12
          : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return raw;
    }
  }

  String get formattedCreatedAt => _formatTimestamp(createdAt);
  String get formattedUpdatedAt => _formatTimestamp(updatedAt);

  String get fullAddress {
    final parts = [
      streetAddress,
      barangay,
      cityMunicipality,
      stateProvince,
      country,
      postalCode,
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
  final String lastLogin;
  final String passwordChanged;
  final String registeredDevice;
  final String ipAddress;
  final String notes;
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
    this.lastLogin = '',
    this.passwordChanged = '',
    this.registeredDevice = '',
    this.ipAddress = '',
    this.notes = '',
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

  // Factory to map ProfileData to UserData for the list view
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
      civilStatus: '—', // This could be added to ProfileData if exists in DB
      contactNo: '—', // This could be added to ProfileData if exists in DB
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
const List<Color> _avatarColors = [
  Color(0xFF7C3AED),
  Color(0xFF2563EB),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
  Color(0xFF059669),
];
Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

// ══════════════════════════════════════════════════════════════════════════════
// USER MANAGEMENT PAGE
// ══════════════════════════════════════════════════════════════════════════════
class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String _filter = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  bool _isLoading = false;
  List<UserData> _users = [];

  static const _filterOptions = ['All', 'Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Sa lib/features/user_management.dart, palitan mo yung _fetchUsers function:

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Mas safe na select query
      final List<dynamic> response = await Supabase.instance.client
          .from('profiles')
          .select('*')
          .order('first_name');

      debugPrint('LOG: Supabase Response Type: ${response.runtimeType}');
      debugPrint('LOG: Profiles Count: ${response.length}');
      debugPrint('LOG: Raw Data: $response');

      final profiles = response
          .map((m) => ProfileData.fromMap(m as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _users = profiles.map((p) => UserData.fromProfile(p)).toList();
        _isLoading = false;
      });

      if (_users.isEmpty) {
        debugPrint('WARNING: Walang laman ang profiles table mo sa Supabase.');
      }
    } catch (e) {
      debugPrint('ERROR FETCHING: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<UserData> get _filteredUsers {
    return _users.where((user) {
      final passesFilter = switch (_filter) {
        'Active' => user.isActive,
        'Inactive' => !user.isActive,
        _ => true,
      };
      final q = _searchQuery.toLowerCase();
      final passesSearch =
          q.isEmpty ||
          user.fullName.toLowerCase().contains(q) ||
          user.userId.toLowerCase().contains(q) ||
          user.barangay.toLowerCase().contains(q);
      return passesFilter && passesSearch;
    }).toList();
  }

  int get _totalUsers => _users.length;
  int get _activeCount => _users.where((u) => u.isActive).length;
  int get _inactiveCount => _users.where((u) => !u.isActive).length;

  List<ProgressItem> get _chartItems {
    final activeUsers = _users.where((u) => u.isActive).toList();
    if (activeUsers.isEmpty) return [];

    final Map<String, int> counts = {};
    for (var u in activeUsers) {
      final b = u.barangay;
      counts[b] = (counts[b] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = activeUsers.length.toDouble();
    return sorted
        .take(5)
        .map(
          (e) => ProgressItem(
            label: '${e.key} (${e.value})',
            value: e.value / total,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: _fetchUsers,
              color: _C.primary,
              child: _isLoading && _users.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatRow(
                            total: _totalUsers,
                            active: _activeCount,
                            inactive: _inactiveCount,
                          ),
                          const SizedBox(height: 20),
                          _SectionCard(
                            title: 'Barangay Coverage',
                            subtitle: 'Active user distribution per barangay',
                            trailing: _MonthDropdown(),
                            child: _chartItems.isEmpty
                                ? Container(
                                    height: 150,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _C.bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _isLoading
                                          ? 'Loading distribution...'
                                          : 'No active users found',
                                      style: const TextStyle(color: _C.subtext),
                                    ),
                                  )
                                : MultiRingChart(items: _chartItems),
                          ),
                          const SizedBox(height: 20),
                          _SearchAndFilter(
                            controller: _searchCtrl,
                            selectedFilter: _filter,
                            filterOptions: _filterOptions,
                            onSearch: (q) => setState(() => _searchQuery = q),
                            onFilterChange: (f) => setState(() => _filter = f),
                          ),
                          const SizedBox(height: 16),
                          _UserListCard(users: users, onRefresh: _fetchUsers),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'User Management',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      centerTitle: true,
      backgroundColor: _C.bg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _C.primary,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

// ─── Month Dropdown ────────────────────────────────────────────────────────────
class _MonthDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_outlined, size: 13, color: _C.subtext),
          SizedBox(width: 5),
          Text(
            'All Time',
            style: TextStyle(
              fontSize: 11,
              color: _C.subtext,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _C.subtext),
        ],
      ),
    );
  }
}

// ─── Stat Row ─────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final int total, active, inactive;
  const _StatRow({
    required this.total,
    required this.active,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: _StatCard(
              label: 'Total Users',
              value: '$total',
              icon: Icons.people_alt_outlined,
              color: _C.primary,
              bgColor: _C.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _StatCard(
              label: 'Active',
              value: '$active',
              icon: Icons.check_circle_rounded,
              color: _C.success,
              bgColor: _C.successBg,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _StatCard(
              label: 'Inactive',
              value: '$inactive',
              icon: Icons.cancel_rounded,
              color: _C.danger,
              bgColor: _C.dangerBg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: _C.subtext),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SectionTitle(title: title, subtitle: subtitle),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 11, color: _C.subtext),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Search + Filter ──────────────────────────────────────────────────────────
class _SearchAndFilter extends StatelessWidget {
  final TextEditingController controller;
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFilterChange;

  const _SearchAndFilter({
    required this.controller,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSearch,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _C.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onSearch,
              style: const TextStyle(fontSize: 14, color: _C.text),
              decoration: InputDecoration(
                hintText: 'Search by name, ID, or barangay...',
                hintStyle: const TextStyle(color: _C.subtext, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _C.subtext,
                  size: 20,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: _C.subtext,
                        ),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            onSelected: onFilterChange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, color: _C.primary, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            itemBuilder: (_) => filterOptions
                .map((o) => PopupMenuItem(value: o, child: Text(o)))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─── User List Card ───────────────────────────────────────────────────────────
class _UserListCard extends StatelessWidget {
  final List<UserData> users;
  final VoidCallback onRefresh;
  const _UserListCard({required this.users, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                const Expanded(child: _SectionTitle(title: 'Registered Users')),
                Text(
                  '${users.length} records',
                  style: const TextStyle(fontSize: 12, color: _C.subtext),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _C.border),
          if (users.isEmpty)
            const _EmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: _C.border),
              itemBuilder: (_, i) =>
                  _UserListTile(user: users[i], index: i, onRefresh: onRefresh),
            ),
        ],
      ),
    );
  }
}

// ─── User List Tile ───────────────────────────────────────────────────────────
class _UserListTile extends StatelessWidget {
  final UserData user;
  final int index;
  final VoidCallback onRefresh;
  const _UserListTile({
    required this.user,
    required this.index,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor(index);
    final bg = color.withOpacity(0.12);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: bg,
        child: Text(
          user.initials,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _C.text,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            'ID: ${user.userId}',
            style: const TextStyle(fontSize: 11, color: _C.subtext),
          ),
          Text(
            user.barangay,
            style: const TextStyle(
              fontSize: 11,
              color: _C.subtext,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusBadge(isActive: user.isActive),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: _C.subtext, size: 20),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          instantRoute(UserDetailPage(user: user, avatarIndex: index)),
        );
        if (result == true) {
          onRefresh();
        }
      },
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? _C.successBg : _C.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 12,
            color: isActive ? _C.success : _C.danger,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? _C.success : _C.danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: _C.subtext),
            SizedBox(height: 12),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.subtext,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Try adjusting your search or filter.',
              style: TextStyle(fontSize: 12, color: _C.subtext),
            ),
          ],
        ),
      ),
    );
  }
}
// ══════════════════════════════════════════════════════════════════════════════
// USER DETAIL PAGE
// ══════════════════════════════════════════════════════════════════════════════

class _Role {
  final String title, description;
  final IconData icon;
  const _Role({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const _kRoles = [
  _Role(
    title: 'Administrator',
    description: 'Full access to all features and settings',
    icon: Icons.shield_outlined,
  ),
  _Role(
    title: 'Barangay Staff',
    description: 'Can manage records and view reports',
    icon: Icons.people_outlined,
  ),
  _Role(
    title: 'Verifier',
    description: 'Can verify users and view records',
    icon: Icons.verified_user_outlined,
  ),
  _Role(
    title: 'Viewer',
    description: 'Can view records only',
    icon: Icons.visibility_outlined,
  ),
];

class UserDetailPage extends StatefulWidget {
  final UserData user;
  final int avatarIndex;

  const UserDetailPage({
    super.key,
    required this.user,
    required this.avatarIndex,
  });

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
    _fetchProfile();
    // Pre-select role if user already has one
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
        setState(() {
          _fetchError = 'No profile found for this user.';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _profile = ProfileData.fromMap(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchError = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a role before verifying.'),
          backgroundColor: _C.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final pid = widget.user.profileId;
      await Supabase.instance.client
          .from('profiles')
          .update({
            'role': _selectedRole!.title,
            'is_active': _verifySelected,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', pid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User successfully ${_verifySelected ? 'verified' : 'updated'} as ${_selectedRole!.title}',
          ),
          backgroundColor: _verifySelected ? _C.success : _C.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: _C.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
    final color = _avatarColor(widget.avatarIndex);
    final u = widget.user;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _C.bg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _C.primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _C.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: color.withOpacity(0.12),
                            child: Text(
                              u.initials,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _C.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                u.isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 16,
                                color: u.isActive ? _C.success : _C.danger,
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _C.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              u.userId,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.subtext,
                              ),
                            ),
                            Text(
                              u.barangay,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.subtext,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: u.isActive ? _C.successBg : _C.dangerBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              u.isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 13,
                              color: u.isActive ? _C.success : _C.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              u.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: u.isActive ? _C.success : _C.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  decoration: BoxDecoration(
                    color: _C.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _C.border),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: _C.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _C.primary,
                    unselectedLabelColor: _C.subtext,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                            SizedBox(width: 4),
                            Text('Verify User'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 14),
                            SizedBox(width: 4),
                            Text('Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _C.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Verify User Account',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _C.text,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Verify this user's account and assign a role.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _C.subtext,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Verification Status',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.text,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _VerificationCard(
                                    selected: _verifySelected,
                                    isVerify: true,
                                    onTap: () =>
                                        setState(() => _verifySelected = true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _VerificationCard(
                                    selected: !_verifySelected,
                                    isVerify: false,
                                    onTap: () =>
                                        setState(() => _verifySelected = false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Assign Role',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.text,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => setState(
                                () => _roleDropdownOpen = !_roleDropdownOpen,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _C.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(
                                      _roleDropdownOpen ? 0 : 12,
                                    ),
                                    bottomRight: Radius.circular(
                                      _roleDropdownOpen ? 0 : 12,
                                    ),
                                  ),
                                  border: Border.all(
                                    color: _roleDropdownOpen
                                        ? _C.primary
                                        : _C.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline_rounded,
                                      size: 18,
                                      color: _C.subtext,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _selectedRole?.title ?? 'Select a role',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _selectedRole != null
                                              ? _C.text
                                              : _C.subtext,
                                        ),
                                      ),
                                    ),
                                    AnimatedRotation(
                                      turns: _roleDropdownOpen ? 0.5 : 0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: _C.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              crossFadeState: _roleDropdownOpen
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Container(
                                decoration: BoxDecoration(
                                  color: _C.white,
                                  border: Border(
                                    left: BorderSide(color: _C.primary),
                                    right: BorderSide(color: _C.primary),
                                    bottom: BorderSide(color: _C.primary),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  children: _kRoles
                                      .map(
                                        (role) => _RoleOption(
                                          role: role,
                                          isSelected:
                                              _selectedRole?.title ==
                                              role.title,
                                          onTap: () => setState(() {
                                            _selectedRole = role;
                                            _roleDropdownOpen = false;
                                          }),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Notes (Optional)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _C.text,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: _C.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _C.border),
                              ),
                              child: TextField(
                                controller: _notesCtrl,
                                maxLines: 4,
                                maxLength: 250,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.text,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Add a note about this verification...',
                                  hintStyle: TextStyle(
                                    color: _C.subtext,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(14),
                                  counterStyle: TextStyle(
                                    color: _C.subtext,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      side: const BorderSide(color: _C.border),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _C.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _updateUser,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.shield_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                    label: Text(
                                      _isSaving
                                          ? 'Processing...'
                                          : 'Verify User',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _C.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _DetailsTab(
                        fallbackUser: u,
                        profile: _profile,
                        isLoading: _isLoading,
                        error: _fetchError,
                        onRetry: _fetchProfile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final UserData fallbackUser;
  final ProfileData? profile;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _DetailsTab({
    required this.fallbackUser,
    required this.profile,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  String _val(String? supabaseVal, String fallback) {
    if (supabaseVal != null && supabaseVal.isNotEmpty) return supabaseVal;
    return fallback.isNotEmpty ? fallback : '—';
  }

  @override
  Widget build(BuildContext context) {
    final u = fallbackUser;
    final p = profile;
    final hasProfile = p != null;

    // ── Resolved values (Supabase → fallback) ──────────────────────────────
    final userId = u.userId;
    final firstName = _val(p?.firstName, u.firstName);
    final middleName = _val(p?.middleName, u.middleName);
    final lastName = _val(p?.lastName, u.lastName);
    final fullName = hasProfile
        ? (p.fullName.isNotEmpty ? p.fullName : u.fullName)
        : u.fullName;
    final birthDate = _val(p?.birthDate, u.birthday);
    final gender = _val(p?.gender, u.sex);
    final citizenship = p?.citizenship ?? '—';
    final email = _val(p?.email, u.email);
    final role = _val(p?.role, u.role);
    final country = p?.country ?? '—';
    final stateProvince = p?.stateProvince ?? '—';
    final cityMunicipality = p?.cityMunicipality ?? '—';
    final barangay = _val(p?.barangay, u.barangay);
    final streetAddress = _val(
      p?.streetAddress,
      u.street.isNotEmpty ? u.street : '',
    );
    final postalCode = p?.postalCode ?? '—';
    final fullAddress = hasProfile ? p.fullAddress : '—';
    final createdAt = hasProfile ? p.formattedCreatedAt : u.dateReg;
    final updatedAt = hasProfile ? p.formattedUpdatedAt : u.passwordChanged;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading) ...[
                  _LoadingBanner(),
                  const SizedBox(height: 16),
                ],
                if (!isLoading && error != null) ...[
                  _ErrorBanner(message: error!, onRetry: onRetry),
                  const SizedBox(height: 16),
                ],
                if (hasProfile && !isLoading) ...[
                  _SourceBadge(),
                  const SizedBox(height: 16),
                ],

                // ── Personal Information ──────────────────────────────────
                _DetailSection(
                  title: 'Personal Information',
                  rows: [
                    _DetailRow(
                      icon: Icons.badge_outlined,
                      label: 'User ID',
                      value: userId,
                    ),
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'First Name',
                      value: firstName,
                    ),
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Middle Name',
                      value: middleName.isNotEmpty ? middleName : '—',
                    ),
                    _DetailRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Last Name',
                      value: lastName,
                    ),
                    _DetailRow(
                      icon: Icons.cake_outlined,
                      label: 'Birth Date',
                      value: birthDate,
                    ),
                    _DetailRow(
                      icon: Icons.wc_outlined,
                      label: 'Gender',
                      value: gender,
                    ),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'Citizenship',
                      value: citizenship,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Contact Information ───────────────────────────────────
                _DetailSection(
                  title: 'Contact Information',
                  rows: [
                    _DetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Address ───────────────────────────────────────────────
                _DetailSection(
                  title: 'Address',
                  rows: [
                    _DetailRow(
                      icon: Icons.home_outlined,
                      label: 'Street Address',
                      value: streetAddress,
                    ),
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Barangay',
                      value: barangay,
                    ),
                    _DetailRow(
                      icon: Icons.location_city_outlined,
                      label: 'City / Municipality',
                      value: cityMunicipality,
                    ),
                    _DetailRow(
                      icon: Icons.map_outlined,
                      label: 'State / Province',
                      value: stateProvince,
                    ),
                    _DetailRow(
                      icon: Icons.public_outlined,
                      label: 'Country',
                      value: country,
                    ),
                    _DetailRow(
                      icon: Icons.markunread_mailbox_outlined,
                      label: 'Postal Code',
                      value: postalCode,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Account Information ───────────────────────────────────
                _DetailSection(
                  title: 'Account Information',
                  rows: [
                    _DetailRow(
                      icon: Icons.shield_outlined,
                      label: 'Account Status',
                      value: '',
                      customTrailing: _StatusBadge(isActive: u.isActive),
                    ),
                    _DetailRow(
                      icon: Icons.people_outline_rounded,
                      label: 'Role',
                      value: '',
                      customTrailing: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.primary,
                        ),
                      ),
                    ),
                    _DetailRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Registered At',
                      value: createdAt,
                    ),
                    _DetailRow(
                      icon: Icons.update_outlined,
                      label: 'Last Updated',
                      value: updatedAt,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: _C.white,
            border: Border(top: BorderSide(color: _C.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit feature coming soon...'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: _C.primary,
                  ),
                  label: const Text(
                    'Edit User',
                    style: TextStyle(
                      fontSize: 14,
                      color: _C.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: _C.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Password reset link sent to user email.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
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

class _LoadingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.primary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_C.primary),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Fetching profile from Supabase…',
            style: TextStyle(
              fontSize: 12,
              color: _C.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.dangerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: _C.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: _C.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _C.danger,
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

class _SourceBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _C.successBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.success.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_done_outlined, size: 12, color: _C.success),
              SizedBox(width: 5),
              Text(
                'Live from Supabase',
                style: TextStyle(
                  fontSize: 11,
                  color: _C.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailSection({required this.title, required this.rows});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: _C.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _C.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: _C.subtext),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _C.subtext,
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
                  fontSize: 13,
                  color: _C.text,
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
    final color = isVerify ? _C.success : _C.danger;
    final bg = isVerify ? _C.successBg : _C.dangerBg;
    final icon = isVerify ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = isVerify ? 'Verify Account' : 'Reject Account';
    final desc = isVerify
        ? 'User will be able to access the system.'
        : 'User will not be able to access the system.';
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _C.primary : _C.border,
            width: selected ? 2 : 1,
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
                  activeColor: _C.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? _C.primary : _C.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 11,
                color: _C.subtext,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          color: isSelected ? _C.primaryLight : Colors.transparent,
          border: const Border(top: BorderSide(color: _C.border)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected ? _C.primary.withOpacity(0.15) : _C.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                role.icon,
                size: 16,
                color: isSelected ? _C.primary : _C.subtext,
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
                      color: isSelected ? _C.primary : _C.text,
                    ),
                  ),
                  Text(
                    role.description,
                    style: const TextStyle(fontSize: 11, color: _C.subtext),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, size: 16, color: _C.primary),
          ],
        ),
      ),
    );
  }
}
