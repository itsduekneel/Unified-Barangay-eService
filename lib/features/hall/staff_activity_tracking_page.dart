// ============================================================================
// lib/features/hall/staff_activity_tracking_page.dart
// Barangay Hall: Attendance and Staff Activity Tracking (Admin View)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class StaffActivityTrackingPage extends StatefulWidget {
  const StaffActivityTrackingPage({super.key});

  @override
  State<StaffActivityTrackingPage> createState() =>
      _StaffActivityTrackingPageState();
}

class _StaffActivityTrackingPageState extends State<StaffActivityTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<AttendanceModel> _attendance = [];
  List<StaffModel> _staff = [];
  List<TaskModel> _tasks = [];
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
      MockService.getAttendance(),
      MockService.getStaff(),
      MockService.getTasks(),
    ]);
    if (mounted) {
      setState(() {
        _attendance = results[0] as List<AttendanceModel>;
        _staff = results[1] as List<StaffModel>;
        _tasks = results[2] as List<TaskModel>;
        _isLoading = false;
      });
    }
  }

  List<AttendanceModel> get _filteredAttendance => _attendance.where((a) {
    return _searchQuery.isEmpty ||
        a.staffName.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  List<StaffModel> get _filteredStaff => _staff.where((s) {
    return _searchQuery.isEmpty ||
        s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.role.toLowerCase().contains(_searchQuery.toLowerCase());
  }).toList();

  int _getStaffTaskCount(String staffId) =>
      _tasks.where((t) => t.assignedToId == staffId).length;

  int _getStaffDoneTaskCount(String staffId) => _tasks
      .where(
        (t) => t.assignedToId == staffId && t.status == RequestStatus.completed,
      )
      .length;

  AttendanceStatus? _getTodayStatus(String staffId) {
    try {
      return _attendance
          .firstWhere((a) => a.staffId == staffId && a.date == 'May 4, 2025')
          .status;
    } catch (_) {
      return null;
    }
  }

  Color _attColor(AttendanceStatus s) => switch (s) {
    AttendanceStatus.present => const Color(0xFF16A34A),
    AttendanceStatus.late => const Color(0xFFF59E0B),
    AttendanceStatus.absent => const Color(0xFFDC2626),
    AttendanceStatus.onLeave => const Color(0xFF3B82F6),
  };

  String _attLabel(AttendanceStatus s) => switch (s) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.absent => 'Absent',
    AttendanceStatus.onLeave => 'On Leave',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Staff Activity Tracking',
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
            Tab(text: 'Attendance'),
            Tab(text: 'Staff Activity'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : Column(
              children: [
                const SizedBox(height: 10),
                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search staff...',
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
                    children: [
                      // ── TAB 1: Attendance ──────────────────────────────
                      _buildAttendanceTab(),
                      // ── TAB 2: Staff Activity ──────────────────────────
                      _buildActivityTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAttendanceTab() {
    final records = _filteredAttendance;
    final presentCount = _attendance
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final lateCount = _attendance
        .where((a) => a.status == AttendanceStatus.late)
        .length;
    final absentCount = _attendance
        .where((a) => a.status == AttendanceStatus.absent)
        .length;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _MiniStat('Present', presentCount, const Color(0xFF16A34A)),
                const SizedBox(width: 8),
                _MiniStat('Late', lateCount, const Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                _MiniStat('Absent', absentCount, const Color(0xFFDC2626)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final a = records[i];
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _attColor(a.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: _attColor(a.status),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.staffName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            a.date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (a.timeIn != null)
                            Text(
                              'In: ${a.timeIn}'
                              '${a.timeOut != null ? '  Out: ${a.timeOut}' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (a.notes != null)
                            Text(
                              a.notes!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _attColor(a.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _attColor(a.status).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        _attLabel(a.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _attColor(a.status),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    final staffList = _filteredStaff;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: staffList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = staffList[i];
        final totalTasks = _getStaffTaskCount(s.id);
        final doneTasks = _getStaffDoneTaskCount(s.id);
        final todayStatus = _getTodayStatus(s.id);
        final progress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          s.department,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (todayStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _attColor(todayStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _attColor(todayStatus).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        _attLabel(todayStatus),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _attColor(todayStatus),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Completion',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '$doneTasks / $totalTasks',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _kPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: _kBorder,
                            color: _kPrimary,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniStat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}
