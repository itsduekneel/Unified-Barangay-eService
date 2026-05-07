// ============================================================================
// lib/features/staff/task_assignment_page.dart
// Staff: Task Assignment Dashboard
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class TaskAssignmentPage extends StatefulWidget {
  const TaskAssignmentPage({super.key});

  @override
  State<TaskAssignmentPage> createState() => _TaskAssignmentPageState();
}

class _TaskAssignmentPageState extends State<TaskAssignmentPage> {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getTasks();
    if (mounted)
      setState(() {
        _tasks = data;
        _isLoading = false;
      });
  }

  List<TaskModel> get _filtered => _tasks.where((t) {
    final matchStatus =
        _filterStatus == 'all' || t.status.name == _filterStatus;
    final matchSearch =
        _searchQuery.isEmpty ||
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.assignedTo.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchStatus && matchSearch;
  }).toList();

  Color _priorityColor(String p) => switch (p) {
    'High' => const Color(0xFFDC2626),
    'Medium' => const Color(0xFFF59E0B),
    _ => const Color(0xFF16A34A),
  };

  Color _statusColor(RequestStatus s) => switch (s) {
    RequestStatus.pending => const Color(0xFFF59E0B),
    RequestStatus.approved => const Color(0xFF3B82F6),
    RequestStatus.completed => const Color(0xFF16A34A),
    RequestStatus.rejected => const Color(0xFFDC2626),
    _ => Colors.grey,
  };

  String _statusLabel(RequestStatus s) => switch (s) {
    RequestStatus.pending => 'Pending',
    RequestStatus.approved => 'In Progress',
    RequestStatus.completed => 'Completed',
    RequestStatus.rejected => 'Cancelled',
    _ => 'Unknown',
  };

  void _showMarkDoneDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Mark as Done',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Mark "${task.title}" as completed?',
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
              await MockService.updateTaskStatus(
                task.id,
                RequestStatus.completed,
              );
              _load();
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pending = _tasks
        .where((t) => t.status == RequestStatus.pending)
        .length;
    final inProgress = _tasks
        .where((t) => t.status == RequestStatus.approved)
        .length;
    final done = _tasks
        .where((t) => t.status == RequestStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Task Assignment Dashboard',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Summary row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TaskStat('Pending', pending, const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _TaskStat(
                          'In Progress',
                          inProgress,
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        _TaskStat('Done', done, const Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
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
                  const SizedBox(height: 12),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _Chip(
                          'All',
                          'all',
                          _filterStatus == 'all',
                          () => setState(() => _filterStatus = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          'Pending',
                          'pending',
                          _filterStatus == 'pending',
                          () => setState(() => _filterStatus = 'pending'),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          'In Progress',
                          'approved',
                          _filterStatus == 'approved',
                          () => setState(() => _filterStatus = 'approved'),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          'Completed',
                          'completed',
                          _filterStatus == 'completed',
                          () => setState(() => _filterStatus = 'completed'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${filtered.length} tasks',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final t = filtered[i];
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
                                Expanded(
                                  child: Text(
                                    t.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                _PriorityBadge(
                                  t.priority,
                                  _priorityColor(t.priority),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: _kPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t.assignedTo,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _kPrimary,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t.deadline,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      t.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _statusColor(
                                        t.status,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _statusLabel(t.status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _statusColor(t.status),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (t.status != RequestStatus.completed)
                                  GestureDetector(
                                    onTap: () => _showMarkDoneDialog(t),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _kPrimary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Mark Done',
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

class _TaskStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _TaskStat(this.label, this.count, this.color);

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

class _PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PriorityBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(this.label, this.value, this.selected, this.onTap);

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
