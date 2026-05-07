import 'package:flutter/material.dart';
import 'package:ube/widgets/chart.dart';

// ─── Theme Constants ───────────────────────────────────────────────────────────
// One place to change all colors. No magic hex values scattered in code.
class _C {
  static const primary = Color(0xFF8B2CF5);
  static const primaryLight = Color(0xFFEEECFD);
  static const text = Color(0xFF1A1A2E);
  static const subtext = Color(0xFF9490B0);
  static const border = Color(0xFFE8E5F5);
  static const bg = Color(0xFFF7F6FC);
  static const white = Colors.white;
  static const rowAlt = Color(0xFFFAF9FF);
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFFEBEE);
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class UserData {
  final String userId, firstName, middleName, lastName;
  final String sex, birthday, civilStatus, contactNo;
  final String residency, houseNo, street, purok, dateReg;
  final bool isActive;

  const UserData({
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
    required this.dateReg,
    this.isActive = true,
  });

  String get fullName => '$firstName $middleName $lastName'.trim();

  List<String> toRow() => [
    userId,
    firstName,
    middleName,
    lastName,
    sex,
    birthday,
    civilStatus,
    contactNo,
    residency,
    houseNo,
    street,
    purok,
    dateReg,
  ];

  static const List<String> columnLabels = [
    'User ID',
    'First Name',
    'Middle Name',
    'Last Name',
    'Sex',
    'Birthday',
    'Civil Status',
    'Contact No.',
    'Residency',
    'House No.',
    'Street',
    'Purok',
    'Date Registered',
  ];

  static const List<double> columnWidths = [
    110,
    120,
    120,
    120,
    55,
    110,
    110,
    130,
    110,
    80,
    140,
    90,
    130,
  ];
}

// ─── Sample Data ──────────────────────────────────────────────────────────────
const List<UserData> kSampleUsers = [
  UserData(
    userId: 'KONOHA-001',
    firstName: 'Naruto',
    middleName: 'Uzumaki',
    lastName: '',
    sex: 'M',
    birthday: 'Oct 10, 1990',
    civilStatus: 'Single',
    contactNo: '09123456001',
    residency: 'Resident',
    houseNo: '7',
    street: 'Leaf Village St.',
    purok: 'Purok 1',
    dateReg: 'Feb 01, 2026',
    isActive: true,
  ),
  UserData(
    userId: 'KONOHA-002',
    firstName: 'Sasuke',
    middleName: 'Uchiha',
    lastName: '',
    sex: 'M',
    birthday: 'Jul 23, 1989',
    civilStatus: 'Single',
    contactNo: '09123456002',
    residency: 'Resident',
    houseNo: '10',
    street: 'Uchiha Lane',
    purok: 'Purok 2',
    dateReg: 'Feb 02, 2026',
    isActive: false,
  ),
  UserData(
    userId: 'KONOHA-003',
    firstName: 'Sakura',
    middleName: 'Haruno',
    lastName: '',
    sex: 'F',
    birthday: 'Mar 28, 1991',
    civilStatus: 'Single',
    contactNo: '09123456003',
    residency: 'Resident',
    houseNo: '5',
    street: 'Leaf Village St.',
    purok: 'Purok 1',
    dateReg: 'Feb 03, 2026',
    isActive: true,
  ),
  UserData(
    userId: 'KONOHA-004',
    firstName: 'Kakashi',
    middleName: 'Hatake',
    lastName: '',
    sex: 'M',
    birthday: 'Sep 15, 1970',
    civilStatus: 'Single',
    contactNo: '09123456004',
    residency: 'Resident',
    houseNo: '1',
    street: 'Konoha Street',
    purok: 'Purok 3',
    dateReg: 'Feb 04, 2026',
    isActive: true,
  ),
  UserData(
    userId: 'KONOHA-005',
    firstName: 'Hinata',
    middleName: 'Hyuga',
    lastName: '',
    sex: 'F',
    birthday: 'Dec 27, 1990',
    civilStatus: 'Single',
    contactNo: '09123456005',
    residency: 'Resident',
    houseNo: '2',
    street: 'Hyuga Lane',
    purok: 'Purok 2',
    dateReg: 'Feb 05, 2026',
    isActive: true,
  ),
];

// ─── Main Page ────────────────────────────────────────────────────────────────
class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String _filter = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static const _filterOptions = ['All', 'Active', 'Inactive'];

  // ── Computed properties (easy to read & debug) ────────────────────────────
  List<UserData> get _filteredUsers {
    return kSampleUsers.where((user) {
      // Step 1: apply status filter
      final passesFilter = switch (_filter) {
        'Active' => user.isActive,
        'Inactive' => !user.isActive,
        _ => true, // 'All'
      };

      // Step 2: apply search (name, ID, or purok)
      final q = _searchQuery.toLowerCase();
      final passesSearch =
          q.isEmpty ||
          user.fullName.toLowerCase().contains(q) ||
          user.userId.toLowerCase().contains(q) ||
          user.purok.toLowerCase().contains(q);

      return passesFilter && passesSearch;
    }).toList();
  }

  int get _totalUsers => kSampleUsers.length;
  int get _activeCount => kSampleUsers.where((u) => u.isActive).length;
  int get _inactiveCount => kSampleUsers.where((u) => !u.isActive).length;

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
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _C.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            tooltip: 'Advanced filters',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Summary stat cards
            _StatRow(
              total: _totalUsers,
              active: _activeCount,
              inactive: _inactiveCount,
            ),

            const SizedBox(height: 20),

            // 2. Chart
            _SectionCard(
              title: 'Barangay Coverage',
              subtitle: 'Active user distribution per barangay',
              child: const MultiRingChart(
                items: [
                  ProgressItem(label: 'Barangay 1', value: 0.82),
                  ProgressItem(label: 'Barangay 2', value: 0.47),
                  ProgressItem(label: 'Barangay 3', value: 0.63),
                  ProgressItem(label: 'Barangay 4', value: 0.29),
                  ProgressItem(label: 'Barangay 5', value: 0.91),
                  ProgressItem(label: 'Barangay 6', value: 0.54),
                  ProgressItem(label: 'Barangay 7', value: 0.38),
                  ProgressItem(label: 'Barangay 8', value: 0.76),
                  ProgressItem(label: 'Barangay 9', value: 0.15),
                  ProgressItem(label: 'Barangay 10', value: 0.68),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Search + filter chips
            _SearchAndFilter(
              controller: _searchCtrl,
              selectedFilter: _filter,
              filterOptions: _filterOptions,
              onSearch: (q) => setState(() => _searchQuery = q),
              onFilterChange: (f) => setState(() => _filter = f),
            ),

            const SizedBox(height: 12),

            // 4. Result count label
            Text(
              '${users.length} ${users.length == 1 ? 'result' : 'results'} found',
              style: const TextStyle(fontSize: 12, color: _C.subtext),
            ),

            const SizedBox(height: 10),

            // 5. Data table
            _UserTable(users: users),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Cards Row ───────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final int total, active, inactive;
  const _StatRow({
    required this.total,
    required this.active,
    required this.inactive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Total Users',
          value: '$total',
          icon: Icons.people_alt_outlined,
          color: _C.primary,
          bgColor: _C.primaryLight,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Active',
          value: '$active',
          icon: Icons.check_circle_outline_rounded,
          color: _C.success,
          bgColor: _C.successBg,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Inactive',
          value: '$inactive',
          icon: Icons.cancel_outlined,
          color: _C.danger,
          bgColor: _C.dangerBg,
        ),
      ],
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: _C.subtext),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Card Wrapper ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          _SectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Section Title with accent bar ───────────────────────────────────────────
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
          height: 16,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _C.text,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 11, color: _C.subtext),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Search + Filter Chips ────────────────────────────────────────────────────
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(13),
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
              hintText: 'Search by name, ID, or purok…',
              hintStyle: const TextStyle(color: _C.subtext, fontSize: 14),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filter chips (All / Active / Inactive)
        Row(
          children: filterOptions.map((option) {
            final isSelected = selectedFilter == option;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onFilterChange(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _C.primary : _C.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _C.primary : _C.border,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _C.subtext,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── User Table ───────────────────────────────────────────────────────────────
class _UserTable extends StatelessWidget {
  final List<UserData> users;
  const _UserTable({required this.users});

  static final double _totalWidth = UserData.columnWidths.reduce(
    (a, b) => a + b,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                _SectionTitle(title: 'Registered Users'),
                const Spacer(),
                Text(
                  '${users.length} records',
                  style: const TextStyle(fontSize: 12, color: _C.subtext),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: _C.border),

          // Empty state or scrollable table
          if (users.isEmpty)
            const _EmptyState()
          else
            SizedBox(
              height: 340,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _totalWidth,
                      child: Column(
                        children: [
                          // Column header row
                          Container(
                            height: 44,
                            color: _C.primaryLight,
                            child: Row(
                              children: List.generate(
                                UserData.columnLabels.length,
                                (i) => _HeaderCell(
                                  label: UserData.columnLabels[i],
                                  width: UserData.columnWidths[i],
                                ),
                              ),
                            ),
                          ),

                          // Data rows
                          Expanded(
                            child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) => _TableRow(
                                user: users[index],
                                isEven: index % 2 == 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Header Cell ──────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  const _HeaderCell({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _C.primary,
            letterSpacing: 0.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ─── Data Row ─────────────────────────────────────────────────────────────────
class _TableRow extends StatelessWidget {
  final UserData user;
  final bool isEven;
  const _TableRow({required this.user, required this.isEven});

  @override
  Widget build(BuildContext context) {
    final cells = user.toRow();
    return Container(
      height: 48,
      color: isEven ? _C.white : _C.rowAlt,
      child: Row(
        children: List.generate(cells.length, (i) {
          // Sex column (index 4) gets a colored badge
          final isSexCol = i == 4;
          return _DataCell(
            text: cells[i],
            width: UserData.columnWidths[i],
            isBadge: isSexCol,
          );
        }),
      ),
    );
  }
}

// ─── Data Cell ────────────────────────────────────────────────────────────────
class _DataCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isBadge;
  const _DataCell({
    required this.text,
    required this.width,
    this.isBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: isBadge && text.isNotEmpty
            ? _SexBadge(sex: text)
            : Text(
                text,
                style: const TextStyle(fontSize: 13, color: _C.text),
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

// ─── Sex Badge ────────────────────────────────────────────────────────────────
class _SexBadge extends StatelessWidget {
  final String sex;
  const _SexBadge({required this.sex});

  @override
  Widget build(BuildContext context) {
    final isMale = sex == 'M';
    final label = isMale ? 'M' : 'F';
    final color = isMale ? const Color(0xFF2563EB) : const Color(0xFFDB2777);
    final bgColor = isMale ? const Color(0xFFEFF6FF) : const Color(0xFFFDF2F8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
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
