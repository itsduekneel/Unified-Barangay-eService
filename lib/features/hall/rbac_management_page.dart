// ============================================================================
// lib/features/hall/rbac_management_page.dart
// ============================================================================

import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF534AB7);
const _kBg = Color(0xFFF5F4FA);
const _kBorder = Color(0xFFE8E4F0);

class _RoleData {
  final String name;
  final String description;
  final Color color;
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final List<String> permissions;
  final int userCount;

  const _RoleData({
    required this.name,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.textColor,
    required this.icon,
    required this.permissions,
    required this.userCount,
  });
}

class RbacManagementPage extends StatefulWidget {
  const RbacManagementPage({super.key});

  @override
  State<RbacManagementPage> createState() => _RbacManagementPageState();
}

class _RbacManagementPageState extends State<RbacManagementPage> {
  static const List<_RoleData> _roles = [
    _RoleData(
      name: 'Barangay Captain',
      description: 'Full system access. Approves budgets and policies.',
      color: Color(0xFF534AB7),
      bgColor: Color(0xFFEEEDFE),
      textColor: Color(0xFF3C3489),
      icon: Icons.workspace_premium_outlined,
      userCount: 1,
      permissions: [
        'View all records',
        'Approve/reject all requests',
        'Manage staff accounts',
        'Set role permissions',
        'View financial reports',
        'Access emergency controls',
        'Publish announcements',
      ],
    ),
    _RoleData(
      name: 'Barangay Secretary',
      description: 'Manages documents, appointments, and records.',
      color: Color(0xFF185FA5),
      bgColor: Color(0xFFE6F1FB),
      textColor: Color(0xFF0C447C),
      icon: Icons.description_outlined,
      userCount: 2,
      permissions: [
        'View resident records',
        'Process document requests',
        'Manage appointments',
        'Record household data',
        'Issue barangay documents',
        'Manage queue',
      ],
    ),
    _RoleData(
      name: 'Barangay Treasurer',
      description: 'Manages financial records and fee collection.',
      color: Color(0xFF3B6D11),
      bgColor: Color(0xFFEAF3DE),
      textColor: Color(0xFF27500A),
      icon: Icons.monetization_on_outlined,
      userCount: 1,
      permissions: [
        'View financial records',
        'Collect document fees',
        'Generate financial reports',
        'View budget summary',
      ],
    ),
    _RoleData(
      name: 'Barangay Tanod',
      description: 'Handles security, patrol, and emergency response.',
      color: Color(0xFF854F0B),
      bgColor: Color(0xFFFAEEDA),
      textColor: Color(0xFF633806),
      icon: Icons.shield_outlined,
      userCount: 5,
      permissions: [
        'Log patrol routes',
        'Respond to emergencies',
        'File incident reports',
        'View patrol assignments',
        'Log attendance',
      ],
    ),
    _RoleData(
      name: 'Social Worker',
      description: 'Manages social services and livelihood programs.',
      color: Color(0xFF993556),
      bgColor: Color(0xFFFBEAF0),
      textColor: Color(0xFF72243E),
      icon: Icons.volunteer_activism_outlined,
      userCount: 2,
      permissions: [
        'View resident profiles',
        'Manage social service requests',
        'Record consultation notes',
        'File case reports',
      ],
    ),
    _RoleData(
      name: 'Resident',
      description: 'Standard resident access to barangay services.',
      color: Color(0xFF444441),
      bgColor: Color(0xFFF1EFE8),
      textColor: Color(0xFF2C2C2A),
      icon: Icons.people_outline,
      userCount: 125,
      permissions: [
        'Request documents',
        'Book appointments',
        'File incident reports',
        'Report emergencies',
        'View own records',
        'Submit feedback',
      ],
    ),
  ];

  int get _totalUsers => _roles.fold<int>(0, (s, r) => s + r.userCount);

  int get _totalPermissions =>
      _roles.fold<int>(0, (s, r) => s + r.permissions.length);

  void _showRoleDetail(_RoleData role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoleDetailSheet(role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Access control',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: _kBorder),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            // Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: _kPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Role-based access control',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${_roles.length} roles configured',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Stat row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(value: '${_roles.length}', label: 'Active roles'),
                  const SizedBox(width: 10),
                  _StatCard(value: '$_totalUsers', label: 'Total users'),
                  const SizedBox(width: 10),
                  _StatCard(value: '$_totalPermissions', label: 'Permissions'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SYSTEM ROLES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888780),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _roles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _RoleCard(
                role: _roles[i],
                onTap: () => _showRoleDetail(_roles[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888780)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final _RoleData role;
  final VoidCallback onTap;
  const _RoleCard({required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final previewPerms = role.permissions.take(2).toList();
    final moreCount = role.permissions.length - 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: role.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(role.icon, color: role.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: role.bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${role.userCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: role.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'users',
                      style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Permission preview tags
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ...previewPerms.map((p) => _PermTag(label: p)),
                        if (moreCount > 0)
                          _PermTag(label: '+$moreCount more', italic: true),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Color(0xFFB4B2A9),
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

class _PermTag extends StatelessWidget {
  final String label;
  final bool italic;
  const _PermTag({required this.label, this.italic = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFE8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: const Color(0xFF5F5E5A),
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

class _RoleDetailSheet extends StatelessWidget {
  final _RoleData role;
  const _RoleDetailSheet({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag pill
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: role.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(role.icon, color: role.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${role.userCount} ${role.userCount == 1 ? 'user' : 'users'} assigned',
                      style: TextStyle(fontSize: 12, color: role.color),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EFE8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 15,
                    color: Color(0xFF5F5E5A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            role.description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888780)),
          ),
          const SizedBox(height: 18),
          const Text(
            'PERMISSIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888780),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...role.permissions.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F4FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: role.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: role.color, size: 11),
                    ),
                    const SizedBox(width: 10),
                    Text(p, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: role.color, width: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Edit permissions for ${role.name}'),
                    backgroundColor: role.color,
                  ),
                );
              },
              icon: Icon(Icons.edit_outlined, color: role.color, size: 16),
              label: Text(
                'Edit permissions',
                style: TextStyle(
                  color: role.color,
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
