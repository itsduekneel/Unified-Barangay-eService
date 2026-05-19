import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final _sb = Supabase.instance.client;

// ============================================================================
//  BARANGAY ATTENDANCE PAGE
// ============================================================================
class BarangayAttendancePage extends StatefulWidget {
  const BarangayAttendancePage({super.key});

  @override
  State<BarangayAttendancePage> createState() => _BarangayAttendancePageState();
}

class _BarangayAttendancePageState extends State<BarangayAttendancePage>
    with SingleTickerProviderStateMixin {
  // ── state ──────────────────────────────────────────────────────────────────
  DateTime _selectedDate    = DateTime.now();
  bool     _loading         = true;
  bool     _saving          = false;
  String   _filterStatus    = 'All';
  String   _searchQuery     = '';
  late TabController _tabController;

  final _searchCtrl = TextEditingController();

  // ── data ───────────────────────────────────────────────────────────────────
  List<_WorkerAttendance> _records = [];

  static const _filterOptions = ['All', 'Present', 'Late', 'Absent', 'On Leave'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAttendance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── data loading ───────────────────────────────────────────────────────────
  Future<void> _loadAttendance() async {
    setState(() => _loading = true);
    final isoDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      final res = await _sb
          .from('attendance')
          .select()
          .eq('date', isoDate)
          .order('worker_name');

      final fetched = (res as List).map((r) => _WorkerAttendance.fromMap(r)).toList();

      // If no records yet for this date, load workers list to pre-populate
      if (fetched.isEmpty) {
        final workers = await _sb
            .from('workers')
            .select()
            .eq('is_active', true)
            .order('full_name');

        _records = (workers as List).map((w) => _WorkerAttendance(
          id: null,
          workerId: w['id'] as String,
          workerName: w['full_name'] as String,
          position: w['position'] as String? ?? 'Staff',
          date: isoDate,
          status: 'Absent',
          timeIn: null,
          timeOut: null,
          remarks: null,
        )).toList();
      } else {
        _records = fetched;
      }
    } catch (e) {
      _snack('Failed to load: $e');
      _records = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── save all ───────────────────────────────────────────────────────────────
  Future<void> _saveAll() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      for (final r in _records) {
        final data = {
          'worker_id':   r.workerId,
          'worker_name': r.workerName,
          'position':    r.position,
          'date':        r.date,
          'status':      r.status,
          'time_in':     r.timeIn,
          'time_out':    r.timeOut,
          'remarks':     r.remarks,
        };
        if (r.id == null) {
          await _sb.from('attendance').insert(data);
        } else {
          await _sb.from('attendance').update(data).eq('id', r.id!);
        }
      }
      _snack('Attendance saved!', success: true);
      await _loadAttendance();
    } catch (e) {
      _snack('Error saving: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── mark all ───────────────────────────────────────────────────────────────
  void _markAll(String status) {
    setState(() {
      for (final r in _records) {
        r.status = status;
        if (status == 'Present' || status == 'Late') {
          r.timeIn ??= '08:00 AM';
        }
      }
    });
  }

  // ── date picker ────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadAttendance();
    }
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.green : AppColors.red,
      ),
    );
  }

  // ── filtered list ──────────────────────────────────────────────────────────
  List<_WorkerAttendance> get _filtered {
    return _records.where((r) {
      final matchStatus = _filterStatus == 'All' || r.status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty ||
          r.workerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.position.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── summary counts ─────────────────────────────────────────────────────────
  Map<String, int> get _summary {
    final counts = <String, int>{'Present': 0, 'Late': 0, 'Absent': 0, 'On Leave': 0};
    for (final r in _records) {
      counts[r.status] = (counts[r.status] ?? 0) + 1;
    }
    return counts;
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Attendance Tracking',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            )
                : const Icon(Icons.save_rounded, color: AppColors.primary, size: 22),
            onPressed: _saving ? null : _saveAll,
            tooltip: 'Save All',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Date selector
          _DateHeader(
            selectedDate: _selectedDate,
            onPickDate: _pickDate,
          ),

          // ── Summary chips
          if (!_loading) _SummaryRow(summary: _summary, total: _records.length),

          // ── Filter + Search + Mark All
          _FilterBar(
            filterStatus: _filterStatus,
            searchCtrl: _searchCtrl,
            filterOptions: _filterOptions,
            onFilterChanged: (v) => setState(() => _filterStatus = v),
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onMarkAll: _markAll,
          ),

          // ── List
          Expanded(
            child: _loading
                ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            )
                : _filtered.isEmpty
                ? _EmptyState(filterStatus: _filterStatus)
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _AttendanceCard(
                record: _filtered[i],
                onChanged: () => setState(() {}),
              ),
            ),
          ),
        ],
      ),

      // ── FAB: Save
      floatingActionButton: !_loading && _records.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _saving ? null : _saveAll,
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: _saving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.check_circle_outline_rounded, size: 20),
        label: Text(
          _saving ? 'Saving…' : 'Save Attendance',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Date Header
// ─────────────────────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPickDate;

  const _DateHeader({required this.selectedDate, required this.onPickDate});

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: GestureDetector(
        onTap: onPickDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Date',
                    style: TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary Row
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final Map<String, int> summary;
  final int total;

  const _SummaryRow({required this.summary, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Present',
            count: summary['Present'] ?? 0,
            color: AppColors.green,
            bgColor: AppColors.greenBg,
            borderColor: AppColors.greenBorder,
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 7),
          _SummaryChip(
            label: 'Late',
            count: summary['Late'] ?? 0,
            color: AppColors.orange,
            bgColor: AppColors.orangeBg,
            borderColor: AppColors.orangeBorder,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(width: 7),
          _SummaryChip(
            label: 'Absent',
            count: summary['Absent'] ?? 0,
            color: AppColors.red,
            bgColor: const Color(0xFFFFF0F0),
            borderColor: const Color(0xFFFFCCCC),
            icon: Icons.cancel_outlined,
          ),
          const SizedBox(width: 7),
          _SummaryChip(
            label: 'Leave',
            count: summary['On Leave'] ?? 0,
            color: AppColors.textGrey,
            bgColor: const Color(0xFFF4F4F4),
            borderColor: AppColors.border,
            icon: Icons.beach_access_outlined,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bgColor, borderColor;
  final IconData icon;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(height: 3),
            Text(
              '$count',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter Bar
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final String filterStatus;
  final TextEditingController searchCtrl;
  final List<String> filterOptions;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onMarkAll;

  const _FilterBar({
    required this.filterStatus,
    required this.searchCtrl,
    required this.filterOptions,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          // Search
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText: 'Search worker…',
                hintStyle: TextStyle(fontSize: 12, color: AppColors.textGrey),
                prefixIcon: Icon(Icons.search_rounded, size: 17, color: AppColors.textGrey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filter chips + mark all
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterOptions.map((opt) {
                      final active = filterStatus == opt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => onFilterChanged(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? AppColors.primary : AppColors.border,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Mark All button
              GestureDetector(
                onTap: () => _showMarkAllSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.checklist_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Mark All',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMarkAllSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mark All Workers As',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            ...[
              ('Present',  AppColors.green,   AppColors.greenBg,   AppColors.greenBorder,   Icons.check_circle_outline_rounded),
              ('Late',     AppColors.orange,  AppColors.orangeBg,  AppColors.orangeBorder,  Icons.schedule_rounded),
              ('Absent',   AppColors.red,     const Color(0xFFFFF0F0), const Color(0xFFFFCCCC), Icons.cancel_outlined),
              ('On Leave', AppColors.textGrey, const Color(0xFFF4F4F4), AppColors.border,    Icons.beach_access_outlined),
            ].map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onMarkAll(t.$1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: t.$3,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: t.$4),
                  ),
                  child: Row(
                    children: [
                      Icon(t.$5, size: 16, color: t.$2),
                      const SizedBox(width: 10),
                      Text(
                        t.$1,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: t.$2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Attendance Card
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final _WorkerAttendance record;
  final VoidCallback onChanged;

  const _AttendanceCard({required this.record, required this.onChanged});

  static const _statuses = ['Present', 'Late', 'Absent', 'On Leave'];

  Color _statusColor(String s) {
    switch (s) {
      case 'Present':  return AppColors.green;
      case 'Late':     return AppColors.orange;
      case 'Absent':   return AppColors.red;
      default:         return AppColors.textGrey;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Present':  return AppColors.greenBg;
      case 'Late':     return AppColors.orangeBg;
      case 'Absent':   return const Color(0xFFFFF0F0);
      default:         return const Color(0xFFF4F4F4);
    }
  }

  Color _statusBorder(String s) {
    switch (s) {
      case 'Present':  return AppColors.greenBorder;
      case 'Late':     return AppColors.orangeBorder;
      case 'Absent':   return const Color(0xFFFFCCCC);
      default:         return AppColors.border;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Present':  return Icons.check_circle_outline_rounded;
      case 'Late':     return Icons.schedule_rounded;
      case 'Absent':   return Icons.cancel_outlined;
      default:         return Icons.beach_access_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color  = _statusColor(record.status);
    final bg     = _statusBg(record.status);
    final border = _statusBorder(record.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: Avatar + Name + Status badge
            Row(
              children: [
                // Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: border),
                  ),
                  child: Center(
                    child: Text(
                      record.workerName.isNotEmpty
                          ? record.workerName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.workerName,
                        style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        record.position,
                        style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(record.status), size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        record.status,
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w700, color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // ── Status Selector
            Row(
              children: _statuses.map((s) {
                final active = record.status == s;
                final sColor  = _statusColor(s);
                final sBg     = _statusBg(s);
                final sBorder = _statusBorder(s);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: GestureDetector(
                      onTap: () {
                        record.status = s;
                        if (s == 'Absent' || s == 'On Leave') {
                          record.timeIn  = null;
                          record.timeOut = null;
                        }
                        onChanged();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? sBg : AppColors.bgColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: active ? sBorder : AppColors.border,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_statusIcon(s), size: 14, color: active ? sColor : AppColors.textGrey),
                            const SizedBox(height: 2),
                            Text(
                              s == 'On Leave' ? 'Leave' : s,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: active ? sColor : AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Time in/out (only for Present/Late)
            if (record.status == 'Present' || record.status == 'Late') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'Time In',
                      value: record.timeIn,
                      icon: Icons.login_rounded,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 8, minute: 0),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          record.timeIn = picked.format(context);
                          onChanged();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimeField(
                      label: 'Time Out',
                      value: record.timeOut,
                      icon: Icons.logout_rounded,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 17, minute: 0),
                          builder: (ctx, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          record.timeOut = picked.format(context);
                          onChanged();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],

            // ── Remarks
            const SizedBox(height: 8),
            _RemarksField(
              value: record.remarks,
              onChanged: (v) {
                record.remarks = v.trim().isEmpty ? null : v.trim();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Time Field
// ─────────────────────────────────────────────────────────────────────────────
class _TimeField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryLight : AppColors.bgColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.border,
            width: filled ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: filled ? AppColors.primary : AppColors.textGrey),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    filled ? value! : 'Tap to set',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: filled ? FontWeight.w700 : FontWeight.normal,
                      color: filled ? AppColors.textDark : AppColors.textGrey,
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  Remarks Field
// ─────────────────────────────────────────────────────────────────────────────
class _RemarksField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const _RemarksField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value ?? '',
      onChanged: onChanged,
      style: const TextStyle(fontSize: 11, color: AppColors.textDark),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Remarks (optional)…',
        hintStyle: const TextStyle(fontSize: 11, color: AppColors.textGrey),
        prefixIcon: const Icon(Icons.notes_rounded, size: 14, color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.bgColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filterStatus;
  const _EmptyState({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filterStatus == 'All'
                ? Icons.people_outline_rounded
                : Icons.filter_list_off_rounded,
            size: 48,
            color: AppColors.border,
          ),
          const SizedBox(height: 12),
          Text(
            filterStatus == 'All'
                ? 'No workers found'
                : 'No workers with "$filterStatus" status',
            style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data Model
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerAttendance {
  final String?  id;
  final String   workerId;
  final String   workerName;
  final String   position;
  final String   date;
  String         status;
  String?        timeIn;
  String?        timeOut;
  String?        remarks;

  _WorkerAttendance({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.position,
    required this.date,
    required this.status,
    this.timeIn,
    this.timeOut,
    this.remarks,
  });

  factory _WorkerAttendance.fromMap(Map<String, dynamic> m) => _WorkerAttendance(
    id:          m['id'] as String?,
    workerId:    m['worker_id'] as String,
    workerName:  m['worker_name'] as String,
    position:    m['position'] as String? ?? 'Staff',
    date:        m['date'] as String,
    status:      m['status'] as String? ?? 'Absent',
    timeIn:      m['time_in'] as String?,
    timeOut:     m['time_out'] as String?,
    remarks:     m['remarks'] as String?,
  );
}