import 'package:flutter/material.dart';

// ── Data models ──────────────────────────────────────────────────────────────

class RoleItem {
  final String title;
  final String accessLevel;
  final String description;
  final Color accentColor;
  final Color iconBg;
  final IconData icon;
  final int userCount;
  final Color badgeColor;
  final Color badgeText;

  const RoleItem({
    required this.title,
    required this.accessLevel,
    required this.description,
    required this.accentColor,
    required this.iconBg,
    required this.icon,
    required this.userCount,
    required this.badgeColor,
    required this.badgeText,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────

class RBACScreen extends StatefulWidget {
  const RBACScreen({super.key});

  @override
  State<RBACScreen> createState() => _RBACScreenState();
}

class _RBACScreenState extends State<RBACScreen> {
  static const Color _primary = Color(0xFF6B4EFF);
  static const Color _scaffoldBg = Color(0xFFF2F2F7);

  int _currentNavIndex = 2;
  final _searchController = TextEditingController();

  final List<RoleItem> _roles = const [
    RoleItem(
      title: 'Super Administrator',
      accessLevel: 'Full system access',
      description: 'Complete access to all features and settings',
      accentColor: Color(0xFF6B4EFF),
      iconBg: Color(0xFFEDE9FF),
      icon: Icons.workspace_premium_outlined,
      userCount: 3,
      badgeColor: Color(0xFFEDE9FF),
      badgeText: Color(0xFF6B4EFF),
    ),
    RoleItem(
      title: 'Barangay Secretary',
      accessLevel: 'Administrative access',
      description: 'Manage documents, requests, and records',
      accentColor: Color(0xFF27AE60),
      iconBg: Color(0xFFE8F8F0),
      icon: Icons.person_outline,
      userCount: 6,
      badgeColor: Color(0xFFE8F8F0),
      badgeText: Color(0xFF27AE60),
    ),
    RoleItem(
      title: 'Treasurer',
      accessLevel: 'Financial access',
      description: 'Manage payments, collections, and reports',
      accentColor: Color(0xFFF39C12),
      iconBg: Color(0xFFFFF3E0),
      icon: Icons.receipt_long_outlined,
      userCount: 4,
      badgeColor: Color(0xFFFFF3E0),
      badgeText: Color(0xFFF39C12),
    ),
    RoleItem(
      title: 'Staff',
      accessLevel: 'Operational access',
      description: 'Process requests and manage residents',
      accentColor: Color(0xFF3498DB),
      iconBg: Color(0xFFE8F4FD),
      icon: Icons.description_outlined,
      userCount: 8,
      badgeColor: Color(0xFFEDE9FF),
      badgeText: Color(0xFF6B4EFF),
    ),
    RoleItem(
      title: 'Tanod / Security',
      accessLevel: 'Limited access',
      description: 'View reports and incident logs',
      accentColor: Color(0xFF6B4EFF),
      iconBg: Color(0xFFEDE9FF),
      icon: Icons.person_outline,
      userCount: 5,
      badgeColor: Color(0xFFEDE9FF),
      badgeText: Color(0xFF6B4EFF),
    ),
    RoleItem(
      title: 'Read Only',
      accessLevel: 'View access only',
      description: 'View documents and records',
      accentColor: Color(0xFF95A5A6),
      iconBg: Color(0xFFF0F0F0),
      icon: Icons.remove_red_eye_outlined,
      userCount: 12,
      badgeColor: Color(0xFFF0F0F0),
      badgeText: Color(0xFF7F8C8D),
    ),
  ];

  final List<_StatCard> _stats = const [
    _StatCard(
      icon: Icons.people_outline,
      iconColor: Color(0xFF6B4EFF),
      iconBg: Color(0xFFEDE9FF),
      value: '6',
      label: 'Total Roles',
    ),
    _StatCard(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF27AE60),
      iconBg: Color(0xFFE8F8F0),
      value: '24',
      label: 'Permissions',
    ),
    _StatCard(
      icon: Icons.group_outlined,
      iconColor: Color(0xFFF39C12),
      iconBg: Color(0xFFFFF3E0),
      value: '38',
      label: 'Users Assigned',
    ),
    _StatCard(
      icon: Icons.article_outlined,
      iconColor: Color(0xFF3498DB),
      iconBg: Color(0xFFE8F4FD),
      value: '100%',
      label: 'System Secured',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 48,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Role-Based Access Control',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            'Barangay Hall',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: FloatingActionButton.small(
            onPressed: () {},
            backgroundColor: _primary,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text(
            'Manage user roles and their permissions in the system.',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          _buildAllRolesTab(),
          const SizedBox(height: 12),
          _buildRolesList(),
          const SizedBox(height: 12),
          _buildPermissionManagementBanner(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: _stats.map((s) {
        final isLast = s == _stats.last;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: s.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(s.icon, color: s.iconColor, size: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  s.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search roles...',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black38,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: _primary,
              size: 18,
            ),
            label: const Text(
              'Filter',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllRolesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Roles',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2.5,
          width: 64,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
      ],
    );
  }

  Widget _buildRolesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _roles.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: Colors.grey.shade100,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) => _buildRoleTile(_roles[index]),
      ),
    );
  }

  Widget _buildRoleTile(RoleItem role) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: role.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(role.icon, color: role.accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.accessLevel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: role.accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.description,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badge + menu + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: role.badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${role.userCount} Users',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: role.badgeText,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.more_vert, color: Colors.black26, size: 18),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.black26,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionManagementBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Permission Management',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Configure detailed permissions for each role',
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.home_outlined, label: 'Dashboard'),
      _NavItem(icon: Icons.description_outlined, label: 'Documents'),
      _NavItem(icon: Icons.people_outline, label: 'Users'),
      _NavItem(icon: Icons.bar_chart_outlined, label: 'Reports'),
      _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == _currentNavIndex;
              return GestureDetector(
                onTap: () => setState(() => _currentNavIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      color: isActive ? _primary : Colors.black38,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive ? _primary : Colors.black38,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Helper data classes ───────────────────────────────────────────────────────

class _StatCard {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.value,
    required this.label,
  });
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
