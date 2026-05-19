import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audit_details_page.dart';
import 'package:ube/core/utils/route_utils.dart';

// =============================================================================
// THEME
// =============================================================================

const kPrimary    = Color(0xFF8B2CF5);
const kPrimary900 = Color(0xFF3B0F8C);
const kPrimary700 = Color(0xFF6A1FC2);
const kPrimary400 = Color(0xFFAB65F7);
const kPrimary200 = Color(0xFFD9B8FC);
const kPrimary100 = Color(0xFFEFDEFE);
const kPrimary50  = Color(0xFFF8F2FF);

const kBg      = Color(0xFFF5F4FA);
const kSurface = Colors.white;
const kDivider = Color(0xFFEFEDF6);
const kTextPri = Color(0xFF1A1A2E);
const kTextSec = Color(0xFF6B6880);
const kTextMut = Color(0xFFB0ADBE);

// =============================================================================
// MODEL
// =============================================================================

enum ActionType { create, update, delete, login, logout, settings }

class AuditEntry {
  final String title;
  final String subtitle;
  final String detail;
  final String time;
  final ActionType action;
  final IconData icon;

  final String activityType;
  final String module;
  final String actionLabel;
  final String description;
  final String performedBy;
  final String role;
  final String department;
  final String targetType;
  final String referenceId;
  final String nameTitle;
  final String ipAddress;
  final String device;
  final String browserApp;
  final String location;
  final String date;

  const AuditEntry({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
    required this.action,
    required this.icon,
    this.activityType = '',
    this.module = '',
    this.actionLabel = '',
    this.description = '',
    this.performedBy = '',
    this.role = '',
    this.department = 'N/A',
    this.targetType = '',
    this.referenceId = '',
    this.nameTitle = 'N/A',
    this.ipAddress = 'N/A',
    this.device = 'N/A',
    this.browserApp = 'N/A',
    this.location = 'N/A',
    this.date = '',
  });
}

// =============================================================================
// SAMPLE DATA
// =============================================================================

const auditLogs = [
  AuditEntry(
    title: 'Document Approved',
    subtitle: 'Barangay Clearance • BC-0512',
    detail: 'Approved by Maria Santos',
    time: '9:30 AM',
    action: ActionType.create,
    icon: Icons.task_alt_rounded,
    activityType: 'Approval',
    module: 'Documents',
    actionLabel: 'Approved',
    description: 'A document was approved in the system.',
    performedBy: 'Maria Santos',
    role: 'Administrator',
    targetType: 'Document',
    referenceId: 'BC-0512',
    nameTitle: 'Barangay Clearance',
    ipAddress: '192.168.1.10',
    device: 'iPhone 14 Pro',
    browserApp: 'UBE eService iOS App',
    date: 'May 12, 2024 • 9:30 AM',
  ),
  AuditEntry(
    title: 'Status Updated',
    subtitle: 'Health Certificate • HC-0341',
    detail: 'Ready for Pickup',
    time: '9:15 AM',
    action: ActionType.update,
    icon: Icons.edit_note_rounded,
    activityType: 'Update',
    module: 'Documents',
    actionLabel: 'Updated',
    description: 'Document status changed to Ready for Pickup.',
    performedBy: 'User B',
    role: 'Staff',
    department: 'Health',
    targetType: 'Document',
    referenceId: 'HC-0341',
    nameTitle: 'Health Certificate',
    ipAddress: '192.168.1.11',
    device: 'Samsung Galaxy S23',
    browserApp: 'UBE eService Android App',
    date: 'May 12, 2024 • 9:15 AM',
  ),
  AuditEntry(
    title: 'User Login',
    subtitle: 'Juan Dela Cruz',
    detail: 'Logged in to system',
    time: '9:02 AM',
    action: ActionType.login,
    icon: Icons.login_rounded,
    activityType: 'Authentication',
    module: 'Auth',
    actionLabel: 'Login',
    description: 'User logged in to the system.',
    performedBy: 'Juan Dela Cruz',
    role: 'Resident',
    targetType: 'Session',
    referenceId: 'SES-0029',
    ipAddress: '192.168.1.22',
    device: 'iPhone 13',
    browserApp: 'UBE eService iOS App',
    date: 'May 12, 2024 • 9:02 AM',
  ),
  AuditEntry(
    title: 'Document Deleted',
    subtitle: 'Business Permit • BP-0123',
    detail: 'Deleted by Ana Reyes',
    time: '8:45 AM',
    action: ActionType.delete,
    icon: Icons.delete_sweep_rounded,
    activityType: 'Deletion',
    module: 'Documents',
    actionLabel: 'Deleted',
    description: 'A business permit document was permanently deleted.',
    performedBy: 'Ana Reyes',
    role: 'Administrator',
    department: 'Business',
    targetType: 'Document',
    referenceId: 'BP-0123',
    nameTitle: 'Business Permit',
    ipAddress: '192.168.1.15',
    device: 'MacBook Pro',
    browserApp: 'Chrome 120',
    date: 'May 12, 2024 • 8:45 AM',
  ),
  AuditEntry(
    title: 'User Logout',
    subtitle: 'Maria Santos',
    detail: 'Logged out',
    time: '5:45 PM',
    action: ActionType.logout,
    icon: Icons.logout_rounded,
    activityType: 'Authentication',
    module: 'Auth',
    actionLabel: 'Logout',
    description: 'User logged out of the system.',
    performedBy: 'Maria Santos',
    role: 'Administrator',
    targetType: 'Session',
    referenceId: 'SES-0028',
    ipAddress: '192.168.1.10',
    device: 'iPhone 14 Pro',
    browserApp: 'UBE eService iOS App',
    date: 'May 11, 2024 • 5:45 PM',
  ),
];

// =============================================================================
// ACTION STYLE — purple-forward per type
// =============================================================================

class _ActionStyle {
  final Color dot;
  final Color iconBg;
  final Color iconFg;
  final Color labelFg;
  final Color badgeBg;
  const _ActionStyle({
    required this.dot,
    required this.iconBg,
    required this.iconFg,
    required this.labelFg,
    required this.badgeBg,
  });
}

_ActionStyle _styleOf(ActionType a) {
  switch (a) {
    case ActionType.create:
      return const _ActionStyle(
        dot: kPrimary700,
        iconBg: kPrimary100,
        iconFg: kPrimary700,
        labelFg: kPrimary900,
        badgeBg: kPrimary100,
      );
    case ActionType.update:
      return const _ActionStyle(
        dot: kPrimary,
        iconBg: kPrimary50,
        iconFg: kPrimary,
        labelFg: kPrimary700,
        badgeBg: kPrimary50,
      );
    case ActionType.delete:
      return const _ActionStyle(
        dot: Color(0xFFE24B4A),
        iconBg: Color(0xFFFCEBEB),
        iconFg: Color(0xFFA32D2D),
        labelFg: Color(0xFFA32D2D),
        badgeBg: Color(0xFFFCEBEB),
      );
    case ActionType.login:
      return const _ActionStyle(
        dot: kPrimary400,
        iconBg: kPrimary100,
        iconFg: kPrimary,
        labelFg: kPrimary700,
        badgeBg: kPrimary100,
      );
    case ActionType.logout:
      return const _ActionStyle(
        dot: Color(0xFFB0ADBE),
        iconBg: Color(0xFFF5F4FA),
        iconFg: kTextSec,
        labelFg: kTextSec,
        badgeBg: Color(0xFFF5F4FA),
      );
    default:
      return const _ActionStyle(
        dot: kPrimary400,
        iconBg: kPrimary100,
        iconFg: kPrimary,
        labelFg: kPrimary700,
        badgeBg: kPrimary100,
      );
  }
}

// =============================================================================
// SCREEN
// =============================================================================

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  bool _showFilters  = false;
  ActionType? _filter;
  late AnimationController _animCtrl;
  late Animation<double>   _animH;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _animH = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _searchFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    _showFilters ? _animCtrl.forward() : _animCtrl.reverse();
  }

  List<AuditEntry> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return auditLogs.where((e) {
      final matchQ = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q) ||
          e.performedBy.toLowerCase().contains(q) ||
          e.referenceId.toLowerCase().contains(q);
      final matchF = _filter == null || e.action == _filter;
      return matchQ && matchF;
    }).toList();
  }

  Map<String, List<AuditEntry>> _grouped(List<AuditEntry> list) {
    final today     = list.where((e) => e.date.startsWith('May 12')).toList();
    final yesterday = list.where((e) => e.date.startsWith('May 11')).toList();
    return {
      if (today.isNotEmpty)     'Today|May 12, 2024': today,
      if (yesterday.isNotEmpty) 'Yesterday|May 11, 2024': yesterday,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final grouped  = _grouped(filtered);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        appBar: _appBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            _filtersSection(),
            Expanded(
              child: filtered.isEmpty
                  ? _emptyState()
                  : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                children: [
                  for (final g in grouped.entries) ...[
                    _DateGroupHeader(raw: g.key, entries: g.value),
                    for (final e in g.value) _AuditRow(entry: e),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: kBg,
    elevation: 0,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kPrimary100,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kPrimary, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    title: Column(children: [
      const Text('Audit Log',
          style: TextStyle(
            color: kTextPri,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          )),
      Text('${auditLogs.length} total entries',
          style: const TextStyle(
              color: kTextMut,
              fontSize: 11,
              fontWeight: FontWeight.w400)),
    ]),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 14),
        child: GestureDetector(
          onTap: _toggleFilters,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _showFilters ? kPrimary : kPrimary100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.tune_rounded,
                color: _showFilters ? Colors.white : kPrimary, size: 18),
          ),
        ),
      ),
    ],
  );

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _searchBar() {
    final focused = _searchFocus.hasFocus;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: focused ? kPrimary400 : kDivider,
              width: focused ? 1.5 : 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(Icons.search_rounded,
                color: focused ? kPrimary : kTextMut, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    fontSize: 13,
                    color: kTextPri,
                    fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Search events, users, references...',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: kTextMut,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            if (_searchCtrl.text.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => _searchCtrl.clear()),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      color: kPrimary200, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      size: 12, color: kPrimary700),
                ),
              )
            else
              const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // ── Filters section ─────────────────────────────────────────────────────────
  static const _filterDefs = [
    (null, 'All', Icons.apps_rounded),
    (ActionType.create, 'Approved', Icons.task_alt_rounded),
    (ActionType.update, 'Updated', Icons.edit_note_rounded),
    (ActionType.delete, 'Deleted', Icons.delete_sweep_rounded),
    (ActionType.login, 'Login', Icons.login_rounded),
    (ActionType.logout, 'Logout', Icons.logout_rounded),
  ];

  Widget _filtersSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: _toggleFilters,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          child: Row(children: [
            const Text('FILTERS',
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: kTextMut,
                    letterSpacing: 1.0)),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _showFilters ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: kTextMut),
            ),
            const Spacer(),
            if (_filter != null)
              GestureDetector(
                onTap: () => setState(() => _filter = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimary100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Clear',
                          style: TextStyle(
                              fontSize: 11,
                              color: kPrimary700,
                              fontWeight: FontWeight.w600)),
                      SizedBox(width: 3),
                      Icon(Icons.close_rounded,
                          size: 11, color: kPrimary700),
                    ],
                  ),
                ),
              ),
          ]),
        ),
      ),
      SizeTransition(
        sizeFactor: _animH,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filterDefs.map((f) {
                final active = _filter == f.$1;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? kPrimary : kSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: active ? kPrimary : kDivider,
                          width: active ? 0 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(f.$3,
                            size: 14,
                            color:
                            active ? Colors.white : kTextSec),
                        const SizedBox(width: 5),
                        Text(f.$2,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : kTextSec)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ],
  );

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
              color: kPrimary100,
              borderRadius: BorderRadius.circular(22)),
          child: const Icon(Icons.search_off_rounded,
              color: kPrimary400, size: 38),
        ),
        const SizedBox(height: 16),
        const Text('No entries found',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kTextPri)),
        const SizedBox(height: 6),
        const Text('Try a different search or filter',
            style: TextStyle(fontSize: 12, color: kTextMut)),
      ],
    ),
  );
}

// =============================================================================
// DATE GROUP HEADER
// =============================================================================

class _DateGroupHeader extends StatelessWidget {
  final String raw;
  final List<AuditEntry> entries;
  const _DateGroupHeader({required this.raw, required this.entries});

  @override
  Widget build(BuildContext context) {
    final parts   = raw.split('|');
    final day     = parts[0];
    final date    = parts.length > 1 ? parts[1] : '';
    final deleted = entries.where((e) => e.action == ActionType.delete).length;
    final approved = entries.where((e) => e.action == ActionType.create).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kPrimary50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary100),
      ),
      child: Row(children: [
        Container(
          width: 6, height: 6,
          decoration:
          const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(day,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kPrimary900)),
        const SizedBox(width: 6),
        Text(date,
            style: const TextStyle(fontSize: 11, color: kTextMut)),
        const Spacer(),
        if (deleted > 0) ...[
          _Chip(
              label: '-$deleted deleted',
              bg: const Color(0xFFFCEBEB),
              fg: const Color(0xFFA32D2D)),
          const SizedBox(width: 6),
        ],
        if (approved > 0)
          _Chip(
              label: '+$approved approved',
              bg: kPrimary100,
              fg: kPrimary700),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration:
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
  );
}

// =============================================================================
// AUDIT ROW
// =============================================================================

class _AuditRow extends StatelessWidget {
  final AuditEntry entry;
  const _AuditRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final s = _styleOf(entry.action);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: kPrimary.withOpacity(0.05),
          highlightColor: kPrimary.withOpacity(0.02),
          onTap: () => Navigator.push(
            context,
            instantRoute(AuditLogDetailScreen(entry: entry)),
          ),
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Time
                SizedBox(
                  width: 42,
                  child: Text(
                    entry.time,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        color: kTextMut,
                        height: 1.5,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),

                // Dot
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: s.dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),

                // Icon
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: s.iconBg,
                      borderRadius: BorderRadius.circular(11)),
                  child: Icon(entry.icon, color: s.iconFg, size: 19),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTextPri,
                              height: 1.3)),
                      const SizedBox(height: 3),
                      Text(entry.subtitle,
                          style: const TextStyle(
                              fontSize: 11,
                              color: kTextSec,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Badge + user
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: s.badgeBg,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(entry.actionLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: s.labelFg)),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.performedBy,
                        style: const TextStyle(
                            fontSize: 10, color: kTextMut)),
                  ],
                ),
                const SizedBox(width: 6),

                // More
                GestureDetector(
                  onTap: () => _showMenu(context),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.more_horiz_rounded,
                        color: kTextMut, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final s = _styleOf(entry.action);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: s.iconBg,
                    borderRadius: BorderRadius.circular(13)),
                child: Icon(entry.icon, color: s.iconFg, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: kTextPri)),
                    Text(entry.referenceId,
                        style: const TextStyle(
                            fontSize: 11, color: kTextMut)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: s.badgeBg,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(entry.actionLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: s.labelFg)),
              ),
            ]),
            const SizedBox(height: 20),
            const Divider(color: kDivider, height: 1),
            const SizedBox(height: 8),
            _SheetAction(
              icon: Icons.info_outline_rounded,
              label: 'View Full Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    instantRoute(AuditLogDetailScreen(entry: entry)));
              },
            ),
            _SheetAction(
              icon: Icons.copy_rounded,
              label: 'Copy Reference ID',
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: entry.referenceId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                    Text('${entry.referenceId} copied to clipboard'),
                    backgroundColor: kPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
            _SheetAction(
              icon: Icons.share_rounded,
              label: 'Share Log Entry',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHEET ACTION TILE
// =============================================================================

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: kPrimary50,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: kPrimary, size: 18),
        ),
        const SizedBox(width: 14),
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextPri)),
        const Spacer(),
        const Icon(Icons.chevron_right_rounded,
            color: kTextMut, size: 20),
      ]),
    ),
  );
}