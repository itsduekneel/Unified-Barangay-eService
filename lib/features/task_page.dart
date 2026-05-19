import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/core/utils/route_utils.dart';

final _sb = Supabase.instance.client;

// ─── Design Tokens (mirrors appointment page) ──────────────────────────────────
const _kBg            = Color(0xFFF5F4FA);
const _kSurface       = Color(0xFFFFFFFF);
const _kSurface2      = Color(0xFFF5F0FF);
const _kBorder        = Color(0xFFEBE0FF);
const _kAccent        = Color(0xFF8B2CF5);
const _kText          = Color(0xFF1E0447);
const _kText2         = Color(0xFF360C78);
const _kText3         = Color(0xFF6B7280);
const _kGreen         = Color(0xFF16A34A);
const _kGreenBg       = Color(0xFFDCFCE7);
const _kGreenBorder   = Color(0xFF86EFAC);
const _kOrange        = Color(0xFFEA580C);
const _kOrangeBg      = Color(0xFFFFF7ED);
const _kOrangeBorder  = Color(0xFFFDBA74);
const _kRed           = Color(0xFFDC2626);
const _kRedBg         = Color(0xFFFEF2F2);
const _kRedBorder     = Color(0xFFFCA5A5);
const _kBlue          = Color(0xFF1D4ED8);
const _kBlueBg        = Color(0xFFEFF6FF);
const _kBlueBorder    = Color(0xFFBFDBFE);
const _kAccentBg      = Color(0xFFF5F0FF);
const _kAccentBorder  = Color(0xFFEBE0FF);
const _kGray          = Color(0xFF6B7280);
const _kGrayBg        = Color(0xFFF3F4F6);
const _kGrayBorder    = Color(0xFFD1D5DB);
const _kYellow        = Color(0xFFCA8A04);
const _kYellowBg      = Color(0xFFFEFCE8);
const _kYellowBorder  = Color(0xFFFDE68A);

// ─── Priority Config ───────────────────────────────────────────────────────────
class _PriorityCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _PriorityCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _priorityMap = {
  'low':      _PriorityCfg('Low',      _kGreen,  _kGreenBg,  _kGreenBorder,  Icons.arrow_downward_rounded),
  'medium':   _PriorityCfg('Medium',   _kYellow, _kYellowBg, _kYellowBorder, Icons.remove_rounded),
  'high':     _PriorityCfg('High',     _kOrange, _kOrangeBg, _kOrangeBorder, Icons.arrow_upward_rounded),
  'urgent':   _PriorityCfg('Urgent',   _kRed,    _kRedBg,    _kRedBorder,    Icons.priority_high_rounded),
};

_PriorityCfg _pCfg(String p) => _priorityMap[p] ?? _priorityMap['medium']!;
const _kPriorities = ['low', 'medium', 'high', 'urgent'];

// ─── Task Status Config ────────────────────────────────────────────────────────
class _TaskStatusCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _TaskStatusCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _taskStatusMap = {
  'todo':        _TaskStatusCfg('To Do',       _kGray,   _kGrayBg,   _kGrayBorder,   Icons.radio_button_unchecked_rounded),
  'in_progress': _TaskStatusCfg('In Progress', _kBlue,   _kBlueBg,   _kBlueBorder,   Icons.timelapse_rounded),
  'for_review':  _TaskStatusCfg('For Review',  _kYellow, _kYellowBg, _kYellowBorder, Icons.rate_review_outlined),
  'done':        _TaskStatusCfg('Done',        _kGreen,  _kGreenBg,  _kGreenBorder,  Icons.check_circle_outline_rounded),
  'blocked':     _TaskStatusCfg('Blocked',     _kRed,    _kRedBg,    _kRedBorder,    Icons.block_rounded),
};

_TaskStatusCfg _tsCfg(String s) => _taskStatusMap[s] ?? _taskStatusMap['todo']!;
const _kTaskStatuses = ['todo', 'in_progress', 'for_review', 'done', 'blocked'];

// ─── Task Model ────────────────────────────────────────────────────────────────
class _Task {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? assignedToName;
  final String? assignedToId;
  final String? category;
  final String? dueDate;
  final String createdAt;
  final int progress; // 0–100
  final List<Map<String, dynamic>> subtasks;
  final String? referenceNo;

  _Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedToName,
    this.assignedToId,
    this.category,
    this.dueDate,
    required this.createdAt,
    required this.progress,
    this.subtasks = const [],
    this.referenceNo,
  });

  static List<Map<String, dynamic>> _parseList(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (raw is String) {
        final d = jsonDecode(raw);
        if (d is List) return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  factory _Task.fromMap(Map<String, dynamic> m) => _Task(
    id:             m['id'].toString(),
    title:          m['title'] ?? '',
    description:    m['description'],
    status:         m['status'] ?? 'todo',
    priority:       m['priority'] ?? 'medium',
    assignedToName: m['assigned_to_name'],
    assignedToId:   m['assigned_to_id']?.toString(),
    category:       m['category'],
    dueDate:        m['due_date'],
    createdAt:      m['created_at'] != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
        : '',
    progress:  (m['progress'] as num?)?.toInt() ?? 0,
    subtasks:  _parseList(m['subtasks']),
    referenceNo: m['reference_no'],
  );

  String get formattedDueDate {
    if (dueDate == null || dueDate!.isEmpty) return '';
    try { return DateFormat('MMM dd, yyyy').format(DateTime.parse(dueDate!)); }
    catch (_) { return dueDate!; }
  }

  bool get isOverdue {
    if (dueDate == null || status == 'done') return false;
    try { return DateTime.parse(dueDate!).isBefore(DateTime.now()); }
    catch (_) { return false; }
  }
}

// ─── Worker Model ──────────────────────────────────────────────────────────────
class _Worker {
  final String id;
  final String name;
  final String? role;
  final String? avatarUrl;
  final int taskCount;
  final int doneCount;

  _Worker({
    required this.id,
    required this.name,
    this.role,
    this.avatarUrl,
    required this.taskCount,
    required this.doneCount,
  });

  factory _Worker.fromMap(Map<String, dynamic> m) => _Worker(
    id:         m['id'].toString(),
    name:       m['name'] ?? '',
    role:       m['role'],
    avatarUrl:  m['avatar_url'],
    taskCount:  (m['task_count'] as num?)?.toInt() ?? 0,
    doneCount:  (m['done_count'] as num?)?.toInt() ?? 0,
  );

  double get completion => taskCount == 0 ? 0 : doneCount / taskCount;
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ─── Color palette for avatars ─────────────────────────────────────────────────
const _kAvatarColors = [
  Color(0xFF8B2CF5), Color(0xFF1D4ED8), Color(0xFF16A34A),
  Color(0xFFEA580C), Color(0xFFCA8A04), Color(0xFFDC2626),
];
Color _avatarColor(String id) => _kAvatarColors[id.hashCode.abs() % _kAvatarColors.length];

// ============================================================================
//  ADMIN TASK PAGE (My Work / All Tasks)
// ============================================================================
class AdminTaskPage extends StatefulWidget {
  const AdminTaskPage({super.key});

  @override
  State<AdminTaskPage> createState() => _AdminTaskPageState();
}

class _AdminTaskPageState extends State<AdminTaskPage>
    with SingleTickerProviderStateMixin {
  String _filterStatus = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;
  String _viewMode = 'my'; // 'my' | 'all'

  final _statusTabs = ['all', 'todo', 'in_progress', 'for_review', 'done', 'blocked'];

  // TODO: Replace with actual current user ID from your auth
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _statusTabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() => _filterStatus = _statusTabs[_tabCtrl.index]);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Task> _filter(List<_Task> all) {
    return all.where((t) {
      final matchStatus = _filterStatus == 'all' || t.status == _filterStatus;
      final matchView   = _viewMode == 'all' || t.assignedToId == _currentUserId;
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          (t.assignedToName?.toLowerCase().contains(q) ?? false) ||
          (t.category?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchView && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('tasks')
          .stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (context, snapshot) {
        final all      = (snapshot.data ?? []).map(_Task.fromMap).toList();
        final myTasks  = all.where((t) => t.assignedToId == _currentUserId).toList();
        final displayed = _viewMode == 'my' ? myTasks : all;
        final filtered  = _filter(all);

        final counts = {
          for (var s in _statusTabs)
            s: s == 'all'
                ? displayed.length
                : displayed.where((t) => t.status == s).length,
        };

        return Scaffold(
          backgroundColor: _kBg,
          appBar: AppBar(
            backgroundColor: _kBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Task Management',
              style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _PillBtn(
                  icon: Icons.add_rounded,
                  label: 'New',
                  onTap: () => Navigator.push(
                    context,
                    instantRoute(const _CreateTaskPage()),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildViewToggle(myTasks.length, all.length),
              _buildSummary(counts, displayed),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: _kText, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search task, worker, category…',
                      hintStyle: TextStyle(color: _kText3, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: _kText3, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              _buildTabs(counts),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData
                    ? const Center(child: CircularProgressIndicator(color: _kAccent))
                    : filtered.isEmpty
                    ? _TaskEmptyState(filter: _filterStatus, viewMode: _viewMode)
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _TaskCard(
                    task: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      instantRoute(_TaskDetailPage(task: filtered[i])),
                    ),
                    onStatusChange: (s) async => await _sb
                        .from('tasks')
                        .update({'status': s}).eq('id', filtered[i].id),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: const Text('Workload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => Navigator.push(context, instantRoute(const _WorkloadPage())),
          ),
        );
      },
    );
  }

  Widget _buildViewToggle(int myCount, int allCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            _ViewToggleBtn(label: 'My Tasks', count: myCount, active: _viewMode == 'my', onTap: () => setState(() => _viewMode = 'my')),
            _ViewToggleBtn(label: 'All Tasks', count: allCount, active: _viewMode == 'all', onTap: () => setState(() => _viewMode = 'all')),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(Map<String, int> counts, List<_Task> tasks) {
    final done    = tasks.where((t) => t.status == 'done').length;
    final active  = tasks.where((t) => t.status == 'in_progress').length;
    final overdue = tasks.where((t) => t.isOverdue).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          _StatPill('$active',  'Active',   _kBlue,   _kBlueBg,   _kBlueBorder),
          const SizedBox(width: 8),
          _StatPill('$done',    'Done',     _kGreen,  _kGreenBg,  _kGreenBorder),
          const SizedBox(width: 8),
          _StatPill('$overdue', 'Overdue',  _kRed,    _kRedBg,    _kRedBorder),
          const SizedBox(width: 8),
          _StatPill('${tasks.length}', 'Total', _kAccent, _kAccentBg, _kAccentBorder),
        ],
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'To Do', 'In Progress', 'Review', 'Done', 'Blocked'];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        labelColor: _kAccent,
        unselectedLabelColor: _kText3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        indicatorColor: _kAccent,
        indicatorWeight: 2.5,
        tabAlignment: TabAlignment.start,
        tabs: List.generate(labels.length, (i) {
          final key = _statusTabs[i];
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(labels[i]),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _tabCtrl.index == i ? _kAccentBg : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${counts[key]}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _tabCtrl.index == i ? _kAccent : _kText3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── View Toggle Button ────────────────────────────────────────────────────────
class _ViewToggleBtn extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _ViewToggleBtn({required this.label, required this.count, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? _kAccentBg : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: active ? _kAccentBorder : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? _kAccent : _kText3)),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? _kAccent : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: active ? Colors.white : _kText3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Task Card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final _Task task;
  final VoidCallback onTap;
  final void Function(String) onStatusChange;

  const _TaskCard({required this.task, required this.onTap, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final tsCfg  = _tsCfg(task.status);
    final pCfg   = _pCfg(task.priority);
    final acColor = _avatarColor(task.assignedToId ?? task.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: task.isOverdue && task.status != 'done' ? _kRedBorder : _kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overdue banner ──
            if (task.isOverdue && task.status != 'done')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: const BoxDecoration(
                  color: _kRedBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  border: Border(bottom: BorderSide(color: _kRedBorder, width: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 11, color: _kRed),
                    SizedBox(width: 5),
                    Text('OVERDUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _kRed, letterSpacing: 0.8)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.category != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _kAccentBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: _kAccentBorder),
                                  ),
                                  child: Text(task.category!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _kAccent)),
                                ),
                              ),
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _kText,
                                decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
                                decorationColor: _kText3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.description != null && task.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(task.description!, style: const TextStyle(fontSize: 11, color: _kText3, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Priority badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: pCfg.bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: pCfg.border)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(pCfg.icon, size: 10, color: pCfg.fg),
                            const SizedBox(width: 3),
                            Text(pCfg.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: pCfg.fg)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress bar
                  if (task.status != 'todo')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress', style: TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
                            Text('${task.progress}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: task.progress == 100 ? _kGreen : _kAccent)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.progress / 100,
                            backgroundColor: _kBorder,
                            valueColor: AlwaysStoppedAnimation(task.progress == 100 ? _kGreen : _kAccent),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  // Metadata row
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (task.assignedToName != null)
                        _MetaChip(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(color: acColor, shape: BoxShape.circle),
                                child: Center(child: Text(task.assignedToName![0].toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white))),
                              ),
                              const SizedBox(width: 4),
                              Text(task.assignedToName!, style: const TextStyle(fontSize: 10, color: _kText2, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (task.formattedDueDate.isNotEmpty)
                        _MetaChip(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 10, color: task.isOverdue ? _kRed : _kText3),
                              const SizedBox(width: 3),
                              Text(task.formattedDueDate, style: TextStyle(fontSize: 10, color: task.isOverdue ? _kRed : _kText3, fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.w500)),
                            ],
                          ),
                        ),
                      if (task.subtasks.isNotEmpty)
                        _MetaChip(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.checklist_rounded, size: 10, color: _kText3),
                              const SizedBox(width: 3),
                              Text('${task.subtasks.where((s) => s['done'] == true).length}/${task.subtasks.length}', style: const TextStyle(fontSize: 10, color: _kText3)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _TaskStatusBadge(cfg: tsCfg),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  Text(task.createdAt, style: const TextStyle(fontSize: 9, color: _kText3)),
                  const SizedBox(width: 8),
                  _QuickAction(label: 'View', icon: Icons.arrow_forward_ios_rounded, color: _kAccent, onTap: onTap, filled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final Widget child;
  const _MetaChip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: _kGrayBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _kGrayBorder)),
      child: child,
    );
  }
}

// ─── Task Status Badge ─────────────────────────────────────────────────────────
class _TaskStatusBadge extends StatelessWidget {
  final _TaskStatusCfg cfg;
  const _TaskStatusBadge({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: cfg.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 10, color: cfg.fg),
          const SizedBox(width: 4),
          Text(cfg.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: cfg.fg)),
        ],
      ),
    );
  }
}

// ============================================================================
//  WORKLOAD PAGE (per-worker task distribution)
// ============================================================================
class _WorkloadPage extends StatefulWidget {
  const _WorkloadPage();

  @override
  State<_WorkloadPage> createState() => _WorkloadPageState();
}

class _WorkloadPageState extends State<_WorkloadPage> {
  List<_Worker> _workers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      // Fetches workers with aggregated task counts via a view or RPC
      // Example: create a 'worker_workload' view in Supabase
      final data = await _sb.from('worker_workload').select().order('task_count', ascending: false);
      if (mounted) {
        setState(() {
          _workers = (data as List).map((m) => _Worker.fromMap(m)).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _workers.fold<int>(0, (sum, w) => sum + w.taskCount);
    final totalDone  = _workers.fold<int>(0, (sum, w) => sum + w.doneCount);
    final overallPct = totalTasks == 0 ? 0.0 : totalDone / totalTasks;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Worker Workload', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : RefreshIndicator(
        color: _kAccent,
        onRefresh: _fetch,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          children: [
            // ── Overall summary card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C22E0), _kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overall Team Progress', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  Text('${(overallPct * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: overallPct,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _OverallStat('$totalTasks', 'Total Tasks'),
                      const SizedBox(width: 20),
                      _OverallStat('$totalDone', 'Completed'),
                      const SizedBox(width: 20),
                      _OverallStat('${_workers.length}', 'Workers'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel(label: 'Team Members'),
            const SizedBox(height: 10),
            if (_workers.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('No worker data available.', style: TextStyle(color: _kText3, fontSize: 13)),
              ))
            else
              ...List.generate(_workers.length, (i) => _WorkerCard(worker: _workers[i])),
          ],
        ),
      ),
    );
  }
}

class _OverallStat extends StatelessWidget {
  final String value, label;
  const _OverallStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Worker Card ───────────────────────────────────────────────────────────────
class _WorkerCard extends StatelessWidget {
  final _Worker worker;
  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    final acColor = _avatarColor(worker.id);
    final pct     = worker.completion;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: acColor.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: acColor.withOpacity(0.3))),
                child: Center(child: Text(worker.initials, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: acColor))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kText)),
                    if (worker.role != null)
                      Text(worker.role!, style: const TextStyle(fontSize: 11, color: _kText3)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${(pct * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _kAccent)),
                  Text('${worker.doneCount}/${worker.taskCount} done', style: const TextStyle(fontSize: 10, color: _kText3)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: _kBorder,
              valueColor: AlwaysStoppedAnimation(pct == 1.0 ? _kGreen : _kAccent),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _WorkerStat('${worker.taskCount}', 'Total', _kAccent, _kAccentBg, _kAccentBorder),
              const SizedBox(width: 8),
              _WorkerStat('${worker.doneCount}', 'Done', _kGreen, _kGreenBg, _kGreenBorder),
              const SizedBox(width: 8),
              _WorkerStat('${worker.taskCount - worker.doneCount}', 'Pending', _kOrange, _kOrangeBg, _kOrangeBorder),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkerStat extends StatelessWidget {
  final String count, label;
  final Color fg, bg, border;
  const _WorkerStat(this.count, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
            Text(label, style: const TextStyle(fontSize: 9, color: _kText3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  TASK DETAIL PAGE
// ============================================================================
class _TaskDetailPage extends StatefulWidget {
  final _Task task;
  const _TaskDetailPage({required this.task});

  @override
  State<_TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<_TaskDetailPage> {
  late String _status;
  late String _priority;
  late int    _progress;
  final _notesCtrl = TextEditingController();
  late List<Map<String, dynamic>> _subtasks;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status   = widget.task.status;
    _priority = widget.task.priority;
    _progress = widget.task.progress;
    _notesCtrl.text = widget.task.description ?? '';
    _subtasks = List<Map<String, dynamic>>.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _sb.from('tasks').update({
      'status':   _status,
      'priority': _priority,
      'progress': _progress,
      'subtasks': _subtasks,
    }).eq('id', widget.task.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(context, 'Delete this task?', 'This action cannot be undone.');
    if (confirmed != true) return;
    await _sb.from('tasks').delete().eq('id', widget.task.id);
    if (mounted) Navigator.pop(context);
  }

  void _toggleSubtask(int i, bool val) {
    setState(() {
      _subtasks[i] = {..._subtasks[i], 'done': val};
      final done  = _subtasks.where((s) => s['done'] == true).length;
      _progress   = _subtasks.isEmpty ? _progress : ((done / _subtasks.length) * 100).round();
      if (_progress == 100 && _status == 'in_progress') _status = 'for_review';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tsCfg        = _tsCfg(_status);
    final pCfg         = _pCfg(_priority);
    final acColor      = _avatarColor(widget.task.assignedToId ?? widget.task.id);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Task Detail', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: _kRed, size: 20),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ──
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.task.category != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(color: _kAccentBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _kAccentBorder)),
                                  child: Text(widget.task.category!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _kAccent)),
                                ),
                              ),
                            Text(widget.task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _kText)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: tsCfg.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: tsCfg.border)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tsCfg.icon, size: 11, color: tsCfg.fg),
                            const SizedBox(width: 4),
                            Text(tsCfg.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: tsCfg.fg)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.task.description!, style: const TextStyle(fontSize: 12, color: _kText3, height: 1.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Schedule / Assignment ──
            const _SectionLabel(label: 'Task Info'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  if (widget.task.assignedToName != null) ...[
                    _AssigneeRow(name: widget.task.assignedToName!, acColor: acColor),
                    _DividerLine(),
                  ],
                  if (widget.task.formattedDueDate.isNotEmpty) ...[
                    _DetailRow(
                      widget.task.isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
                      'Due Date',
                      widget.task.formattedDueDate,
                      valueFg: widget.task.isOverdue ? _kRed : _kText2,
                    ),
                    _DividerLine(),
                  ],
                  _DetailRow(Icons.flag_outlined, 'Priority', pCfg.label, valueFg: pCfg.fg),
                  _DividerLine(),
                  _DetailRow(Icons.calendar_today_rounded, 'Created', widget.task.createdAt),
                  if (widget.task.referenceNo != null) ...[
                    _DividerLine(),
                    _DetailRow(Icons.sell_outlined, 'Ref No.', widget.task.referenceNo!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Progress ──
            const _SectionLabel(label: 'Progress'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_progress%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _progress == 100 ? _kGreen : _kAccent)),
                      Text('Completion', style: const TextStyle(fontSize: 12, color: _kText3)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress / 100,
                      backgroundColor: _kBorder,
                      valueColor: AlwaysStoppedAnimation(_progress == 100 ? _kGreen : _kAccent),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: _kAccent,
                    inactiveColor: _kBorder,
                    label: '$_progress%',
                    onChanged: (v) => setState(() => _progress = v.round()),
                  ),
                ],
              ),
            ),

            // ── Subtasks ──
            if (_subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _SectionLabel(label: 'Subtasks'),
              const SizedBox(height: 8),
              _DetailCard(
                child: Column(
                  children: List.generate(_subtasks.length, (i) {
                    final sub  = _subtasks[i];
                    final done = sub['done'] == true;
                    return Column(
                      children: [
                        if (i > 0) _DividerLine(),
                        InkWell(
                          onTap: () => _toggleSubtask(i, !done),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: done ? _kGreen : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: done ? _kGreen : _kGrayBorder, width: 1.5),
                                  ),
                                  child: done ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sub['title']?.toString() ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: done ? _kText3 : _kText,
                                      decoration: done ? TextDecoration.lineThrough : null,
                                      decorationColor: _kText3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // ── Update Status ──
            const _SectionLabel(label: 'Update Status'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: _kTaskStatuses.map((s) {
                final c      = _tsCfg(s);
                final active = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: active ? c.bg : _kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: active ? c.border : _kBorder, width: active ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.icon, size: 13, color: active ? c.fg : _kText3),
                        const SizedBox(width: 5),
                        Text(c.label, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? c.fg : _kText3)),
                        if (active) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle_rounded, size: 10, color: c.fg),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Update Priority ──
            const _SectionLabel(label: 'Update Priority'),
            const SizedBox(height: 10),
            Row(
              children: _kPriorities.map((p) {
                final c      = _pCfg(p);
                final active = _priority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: EdgeInsets.only(right: p != _kPriorities.last ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? c.bg : _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? c.border : _kBorder, width: active ? 1.5 : 1),
                      ),
                      child: Column(
                        children: [
                          Icon(c.icon, size: 14, color: active ? c.fg : _kText3),
                          const SizedBox(height: 3),
                          Text(c.label, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? c.fg : _kText3)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  disabledBackgroundColor: _kAccent.withOpacity(0.45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Assignee Row ─────────────────────────────────────────────────────────────
class _AssigneeRow extends StatelessWidget {
  final String name;
  final Color acColor;
  const _AssigneeRow({required this.name, required this.acColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded, size: 14, color: _kText3),
          const SizedBox(width: 8),
          const SizedBox(width: 80, child: Text('Assigned', style: TextStyle(fontSize: 12, color: _kText3, fontWeight: FontWeight.w600))),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: acColor, shape: BoxShape.circle),
            child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
          const SizedBox(width: 7),
          Text(name, style: const TextStyle(fontSize: 12, color: _kText2, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ============================================================================
//  CREATE TASK PAGE
// ============================================================================
class _CreateTaskPage extends StatefulWidget {
  const _CreateTaskPage();

  @override
  State<_CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<_CreateTaskPage> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _catCtrl    = TextEditingController();
  final _assignCtrl = TextEditingController();
  DateTime? _dueDate;
  String _status   = 'todo';
  String _priority = 'medium';
  bool _saving = false;

  final List<TextEditingController> _subtaskCtrls = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _catCtrl.dispose();
    _assignCtrl.dispose();
    for (final c in _subtaskCtrls) c.dispose();
    super.dispose();
  }

  void _addSubtask() => setState(() => _subtaskCtrls.add(TextEditingController()));
  void _removeSubtask(int i) {
    _subtaskCtrls[i].dispose();
    setState(() => _subtaskCtrls.removeAt(i));
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: _kAccent)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final subtasks = _subtaskCtrls
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => {'title': c.text.trim(), 'done': false})
        .toList();

    try {
      await _sb.from('tasks').insert({
        'title':       _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'category':    _catCtrl.text.trim().isEmpty ? null : _catCtrl.text.trim(),
        'assigned_to_name': _assignCtrl.text.trim().isEmpty ? null : _assignCtrl.text.trim(),
        'due_date':    _dueDate?.toIso8601String().split('T').first,
        'status':      _status,
        'priority':    _priority,
        'progress':    0,
        'subtasks':    subtasks.isEmpty ? null : subtasks,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: _kRed),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Task', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(label: 'Task Details'),
              const SizedBox(height: 10),
              _AdminFormField(label: 'Task Title', controller: _titleCtrl, icon: Icons.task_alt_rounded, hint: 'e.g. Process Barangay Clearance…', required: true),
              const SizedBox(height: 12),
              _AdminFormField(label: 'Category', controller: _catCtrl, icon: Icons.category_outlined, hint: 'e.g. Documentation, Field Work…'),
              const SizedBox(height: 12),
              _AdminFormField(label: 'Description', controller: _descCtrl, icon: Icons.notes_rounded, hint: 'Task details or instructions…', maxLines: 3),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Assignment & Schedule'),
              const SizedBox(height: 10),
              _AdminFormField(label: 'Assign To', controller: _assignCtrl, icon: Icons.person_add_outlined, hint: 'Worker name…'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(11), border: Border.all(color: _kBorder)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 17, color: _kText3),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _dueDate == null ? 'Set Due Date (optional)' : DateFormat('MMM dd, yyyy').format(_dueDate!),
                          style: TextStyle(fontSize: 13, color: _dueDate == null ? _kText3 : _kText),
                        ),
                      ),
                      if (_dueDate != null)
                        GestureDetector(onTap: () => setState(() => _dueDate = null), child: const Icon(Icons.close_rounded, size: 15, color: _kText3)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Priority'),
              const SizedBox(height: 10),
              Row(
                children: _kPriorities.map((p) {
                  final c      = _pCfg(p);
                  final active = _priority == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        margin: EdgeInsets.only(right: p != _kPriorities.last ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? c.bg : _kSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: active ? c.border : _kBorder, width: active ? 1.5 : 1),
                        ),
                        child: Column(
                          children: [
                            Icon(c.icon, size: 14, color: active ? c.fg : _kText3),
                            const SizedBox(height: 3),
                            Text(c.label, style: TextStyle(fontSize: 9, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? c.fg : _kText3)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // ── Subtasks ──
              Row(
                children: [
                  const Expanded(child: _SectionLabel(label: 'Subtasks')),
                  GestureDetector(
                    onTap: _addSubtask,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: _kAccentBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kAccentBorder)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 13, color: _kAccent),
                          SizedBox(width: 4),
                          Text('Add Subtask', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kAccent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_subtaskCtrls.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.checklist_rounded, color: _kText3, size: 24),
                        SizedBox(height: 5),
                        Text('No subtasks yet.\nTap "Add Subtask" to break this task down.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: _kText3, height: 1.5)),
                      ],
                    ),
                  ),
                )
              else
                ...List.generate(_subtaskCtrls.length, (i) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
                  child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.drag_indicator_rounded, size: 16, color: _kText3)),
                      Expanded(
                        child: TextField(
                          controller: _subtaskCtrls[i],
                          style: const TextStyle(fontSize: 13, color: _kText),
                          decoration: InputDecoration(
                            hintText: 'Subtask ${i + 1}…',
                            hintStyle: const TextStyle(color: _kText3, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeSubtask(i),
                        child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: _kRedBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _kRedBorder)), child: const Icon(Icons.close_rounded, size: 12, color: _kRed)),
                      ),
                    ],
                  ),
                )),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text('Create Task', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared / Reusable Components ─────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String count, label;
  final Color fg, bg, border;
  const _StatPill(this.count, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: _kAccentBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kAccentBorder)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _kAccent),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: _kAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: filled ? color : color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(filled ? 1 : 0.25))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: filled ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: _kAccent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kText)),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueFg;
  const _DetailRow(this.icon, this.label, this.value, {this.valueFg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _kText3),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: _kText3, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: TextStyle(fontSize: 12, color: valueFg ?? _kText2, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: _kBorder);
}

class _AdminFormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  final int maxLines;

  const _AdminFormField({required this.label, required this.controller, required this.icon, required this.hint, this.required = false, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
              if (required) const Text(' *', style: TextStyle(color: _kRed, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: _kText),
          validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kText3, fontSize: 13),
            prefixIcon: Icon(icon, size: 17, color: _kText3),
            filled: true,
            fillColor: _kSurface,
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: maxLines > 1 ? 14 : 13),
            border:             OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kBorder)),
            enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kBorder)),
            focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kAccent, width: 1.5)),
            errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kRed, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _kRed, width: 1.5)),
            errorStyle: const TextStyle(fontSize: 11, color: _kRed),
          ),
        ),
      ],
    );
  }
}

class _TaskEmptyState extends StatelessWidget {
  final String filter, viewMode;
  const _TaskEmptyState({required this.filter, required this.viewMode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: _kAccentBg, shape: BoxShape.circle, border: Border.all(color: _kAccentBorder)),
            child: const Icon(Icons.task_alt_rounded, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('No tasks found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
          const SizedBox(height: 5),
          Text(
            filter == 'all' && viewMode == 'my'
                ? 'No tasks assigned to you.\nWait for tasks to be assigned.'
                : filter == 'all'
                ? 'No tasks yet.\nTap "New" to create one.'
                : 'No $filter tasks found.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Utility ──────────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context, String title, String body) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(body, style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: _kText3))),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm', style: TextStyle(color: _kRed, fontWeight: FontWeight.bold))),
      ],
    ),
  );
}