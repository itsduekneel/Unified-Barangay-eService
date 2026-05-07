// ============================================================================
// lib/features/staff/attendance_tracking_page.dart
// Staff: Attendance & Time Tracking Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class AttendanceTrackingPage extends StatefulWidget {
  const AttendanceTrackingPage({super.key});

  @override
  State<AttendanceTrackingPage> createState() => _AttendanceTrackingPageState();
}

class _AttendanceTrackingPageState extends State<AttendanceTrackingPage> {
  List<AttendanceModel> _attendance = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final data = await MockService.getAttendance();
    if (mounted)
      setState(() {
        _attendance = data;
        _isLoading = false;
      });
  }

  List<AttendanceModel> get _filtered {
    return _attendance.where((a) {
      final matchFilter =
          _filterStatus == 'all' || a.status.name == _filterStatus;
      final matchSearch =
          _searchQuery.isEmpty ||
          a.staffName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  Color _statusColor(AttendanceStatus s) => switch (s) {
    AttendanceStatus.present => const Color(0xFF16A34A),
    AttendanceStatus.late => const Color(0xFFF59E0B),
    AttendanceStatus.absent => const Color(0xFFDC2626),
    AttendanceStatus.onLeave => const Color(0xFF3B82F6),
  };

  String _statusLabel(AttendanceStatus s) => switch (s) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.absent => 'Absent',
    AttendanceStatus.onLeave => 'On Leave',
  };

  void _showLogDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Log Attendance',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Attendance logged successfully!',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _kPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final presentCount = _attendance
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absentCount = _attendance
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final lateCount = _attendance
        .where((a) => a.status == AttendanceStatus.late)
        .length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Attendance & Time Tracking',
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kPrimary,
        onPressed: _showLogDialog,
        icon: const Icon(Icons.fingerprint, color: Colors.white),
        label: const Text(
          'Log Time In/Out',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _SummaryChip(
                          label: 'Present',
                          count: presentCount,
                          color: const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Late',
                          count: lateCount,
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 8),
                        _SummaryChip(
                          label: 'Absent',
                          count: absentCount,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          value: 'all',
                          selected: _filterStatus == 'all',
                          onTap: () => setState(() => _filterStatus = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Present',
                          value: 'present',
                          selected: _filterStatus == 'present',
                          onTap: () =>
                              setState(() => _filterStatus = 'present'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Late',
                          value: 'late',
                          selected: _filterStatus == 'late',
                          onTap: () => setState(() => _filterStatus = 'late'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Absent',
                          value: 'absent',
                          selected: _filterStatus == 'absent',
                          onTap: () => setState(() => _filterStatus = 'absent'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Attendance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${filtered.length} records',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _statusColor(a.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: _statusColor(a.status),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    a.date,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (a.timeIn != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        _TimeTag(
                                          'IN: ${a.timeIn!}',
                                          const Color(0xFF16A34A),
                                        ),
                                        if (a.timeOut != null) ...[
                                          const SizedBox(width: 6),
                                          _TimeTag(
                                            'OUT: ${a.timeOut!}',
                                            const Color(0xFFDC2626),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                  if (a.notes != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      a.notes!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _StatusBadge(
                              label: _statusLabel(a.status),
                              color: _statusColor(a.status),
                            ),
                          ],
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

// ─── Small Reusable Widgets ───────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  final String label;
  final Color color;
  const _TimeTag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search staff...',
        hintStyle: const TextStyle(color: _kPrimary, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: _kPrimary, size: 20),
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
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kPrimary : _kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
