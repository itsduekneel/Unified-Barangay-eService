// ============================================================================
// lib/features/hall/user_management_page.dart
// Barangay Hall: User Management Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<StaffModel> _staff = [];
  List<ResidentModel> _residents = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      MockService.getStaff(),
      MockService.getResidents(),
    ]);
    if (mounted) {
      setState(() {
        _staff = results[0] as List<StaffModel>;
        _residents = results[1] as List<ResidentModel>;
        _isLoading = false;
      });
    }
  }

  List<StaffModel> get _filteredStaff => _staff.where((s) {
    return _searchQuery.isEmpty ||
        s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.email.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  List<ResidentModel> get _filteredResidents => _residents.where((r) {
    return _searchQuery.isEmpty ||
        r.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.purok.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  void _showAddStaffDialog() {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Add Staff Account',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(ctrl: firstCtrl, label: 'First Name'),
              const SizedBox(height: 8),
              _Field(ctrl: lastCtrl, label: 'Last Name'),
              const SizedBox(height: 8),
              _Field(ctrl: emailCtrl, label: 'Email'),
              const SizedBox(height: 8),
              _Field(ctrl: roleCtrl, label: 'Role (e.g. Tanod, Clerk)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final newStaff = StaffModel(
                id: 'S_NEW',
                firstName: firstCtrl.text,
                lastName: lastCtrl.text,
                role: roleCtrl.text,
                department: 'General',
                contactNo: '',
                email: emailCtrl.text,
                isActive: true,
                dateHired: 'May 5, 2025',
              );
              await MockService.createStaff(newStaff);
              _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Staff account created!'),
                    backgroundColor: _kPrimary,
                  ),
                );
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(StaffModel s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          s.isActive ? 'Deactivate Account' : 'Activate Account',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${s.isActive ? 'Deactivate' : 'Activate'} account for ${s.fullName}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await MockService.updateStaffStatus(s.id, !s.isActive);
              _load();
            },
            child: Text(
              s.isActive ? 'Deactivate' : 'Activate',
              style: TextStyle(
                color: s.isActive
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
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
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add_outlined,
              color: _kPrimary,
              size: 22,
            ),
            onPressed: _showAddStaffDialog,
            tooltip: 'Add Staff',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _kPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _kPrimary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Staff'),
            Tab(text: 'Residents'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: const TextStyle(
                        color: _kPrimary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: _kPrimary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: _kPrimaryLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [_buildStaffTab(), _buildResidentTab()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStaffTab() {
    final staff = _filteredStaff;
    final activeCount = _staff.where((s) => s.isActive).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${staff.length} staff  ·  ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$activeCount active',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: staff.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = staff[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: _kPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            s.role,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            s.email,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: s.isActive
                                ? const Color(0xFFEDFAF3)
                                : const Color(0xFFFFEEEE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: s.isActive
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _showToggleStatusDialog(s),
                          child: Text(
                            s.isActive ? 'Deactivate' : 'Activate',
                            style: TextStyle(
                              fontSize: 10,
                              color: s.isActive
                                  ? const Color(0xFFDC2626)
                                  : _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResidentTab() {
    final residents = _filteredResidents;
    final activeCount = _residents.where((r) => r.isActive).length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${residents.length} residents  ·  ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$activeCount active',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: residents.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = residents[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: r.gender == 'Female'
                            ? const Color(0xFFFFF0F5)
                            : _kPrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        r.gender == 'Female'
                            ? Icons.person_outline
                            : Icons.person_outline,
                        color: r.gender == 'Female'
                            ? const Color(0xFFDB2777)
                            : _kPrimary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${r.purok} · ${r.role}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            r.email,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: r.isActive
                            ? const Color(0xFFEDFAF3)
                            : const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: r.isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _Field({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: _kPrimary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kPrimary),
        ),
      ),
    );
  }
}
