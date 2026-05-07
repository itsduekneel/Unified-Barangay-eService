// ============================================================================
// lib/features/hall/rbac_management_page.dart
// Barangay Hall: Role-Based Access Control Management
// ============================================================================

import 'package:flutter/material.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class _RoleData {
  final String name;
  final String description;
  final Color color;
  final List<String> permissions;
  final int userCount;

  const _RoleData({
    required this.name,
    required this.description,
    required this.color,
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
      color: Color(0xFF8B2CF5),
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
      color: Color(0xFF3B82F6),
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
      color: Color(0xFF16A34A),
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
      color: Color(0xFFEA580C),
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
      color: Color(0xFFDB2777),
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
      color: Color(0xFF64748B),
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

  void _showRoleDetail(_RoleData role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RoleDetailSheet(role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Role-Based Access Control',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Info banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: _kPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Access Control Overview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _kPrimary,
                            ),
                          ),
                          Text(
                            '${_roles.length} roles configured · '
                            '${_roles.fold<int>(0, (s, r) => s + r.userCount)} total users',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'System Roles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _roles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final role = _roles[i];
                return GestureDetector(
                  onTap: () => _showRoleDetail(role),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: role.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: role.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                role.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${role.permissions.length} permissions',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: role.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: role.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${role.userCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: role.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'users',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: role.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_outlined, color: role.color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${role.userCount} users assigned',
                      style: TextStyle(fontSize: 12, color: role.color),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            role.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          const Text(
            'Permissions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...role.permissions.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: role.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: role.color, size: 13),
                  ),
                  const SizedBox(width: 10),
                  Text(p, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: role.color),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
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
              icon: Icon(Icons.edit_outlined, color: role.color, size: 18),
              label: Text(
                'Edit Permissions',
                style: TextStyle(
                  color: role.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
