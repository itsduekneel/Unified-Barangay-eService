import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/core/utils/route_utils.dart';

final _sb = Supabase.instance.client;

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _kBg = Color(0xFFF5F4FA);
const _kSurface = Color(0xFFFFFFFF);
const _kSurface2 = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);
const _kAccent = Color(0xFF8B2CF5);
const _kText = Color(0xFF1E0447);
const _kText2 = Color(0xFF360C78);
const _kText3 = Color(0xFF6B7280);

const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFDCFCE7);
const _kGreenBorder = Color(0xFF86EFAC);
const _kOrange = Color(0xFFEA580C);
const _kOrangeBg = Color(0xFFFFF7ED);
const _kOrangeBorder = Color(0xFFFDBA74);
const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedBorder = Color(0xFFFCA5A5);
const _kBlue = Color(0xFF1D4ED8);
const _kBlueBg = Color(0xFFEFF6FF);
const _kBlueBorder = Color(0xFFBFDBFE);
const _kAccentBg = Color(0xFFF5F0FF);
const _kAccentBorder = Color(0xFFEBE0FF);
const _kGray = Color(0xFF6B7280);
const _kGrayBg = Color(0xFFF3F4F6);
const _kGrayBorder = Color(0xFFD1D5DB);

// ─── Incident Categories ───────────────────────────────────────────────────────
class _Category {
  final String key, label;
  final IconData icon;
  final Color color;
  const _Category(this.key, this.label, this.icon, this.color);
}

const _kCategories = [
  _Category(
    'fire',
    'Fire',
    Icons.local_fire_department_rounded,
    Color(0xFFDC2626),
  ),
  _Category('flood', 'Flood', Icons.water_rounded, Color(0xFF1D4ED8)),
  _Category(
    'crime',
    'Crime / Security',
    Icons.security_rounded,
    Color(0xFF7C3AED),
  ),
  _Category(
    'medical',
    'Medical Emergency',
    Icons.medical_services_rounded,
    Color(0xFFE11D48),
  ),
  _Category(
    'disaster',
    'Natural Disaster',
    Icons.storm_rounded,
    Color(0xFF0891B2),
  ),
  _Category(
    'accident',
    'Road Accident',
    Icons.car_crash_rounded,
    Color(0xFFEA580C),
  ),
  _Category(
    'property',
    'Property Damage',
    Icons.home_work_outlined,
    Color(0xFF92400E),
  ),
  _Category(
    'noise',
    'Noise Complaint',
    Icons.volume_up_rounded,
    Color(0xFF6D28D9),
  ),
  _Category('utility', 'Utility Issue', Icons.bolt_rounded, Color(0xFFCA8A04)),
  _Category('animal', 'Animal Incident', Icons.pets_rounded, Color(0xFF16A34A)),
  _Category(
    'missing',
    'Missing Person',
    Icons.person_search_rounded,
    Color(0xFF0F766E),
  ),
  _Category(
    'environmental',
    'Environmental',
    Icons.eco_rounded,
    Color(0xFF15803D),
  ),
  _Category(
    'dispute',
    'Dispute / Conflict',
    Icons.people_alt_rounded,
    Color(0xFFB45309),
  ),
  _Category('other', 'Other', Icons.more_horiz_rounded, Color(0xFF6B7280)),
];

_Category _catByKey(String key) => _kCategories.firstWhere(
  (c) => c.key == key,
  orElse: () => _kCategories.last,
);

// ─── Status Config ─────────────────────────────────────────────────────────────
class _StatusCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _StatusCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _statusMap = {
  'pending': _StatusCfg(
    'Pending',
    _kOrange,
    _kOrangeBg,
    _kOrangeBorder,
    Icons.hourglass_empty_rounded,
  ),
  'investigating': _StatusCfg(
    'Investigating',
    _kBlue,
    _kBlueBg,
    _kBlueBorder,
    Icons.manage_search_rounded,
  ),
  'resolved': _StatusCfg(
    'Resolved',
    _kGreen,
    _kGreenBg,
    _kGreenBorder,
    Icons.check_circle_outline_rounded,
  ),
  'dismissed': _StatusCfg(
    'Dismissed',
    _kGray,
    _kGrayBg,
    _kGrayBorder,
    Icons.do_not_disturb_rounded,
  ),
};

_StatusCfg _sCfg(String s) => _statusMap[s] ?? _statusMap['pending']!;
const _kStatuses = ['pending', 'investigating', 'resolved', 'dismissed'];

// ─── Severity Config ───────────────────────────────────────────────────────────
class _SeverityCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _SeverityCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _severityMap = {
  'low': _SeverityCfg(
    'Low',
    _kGreen,
    _kGreenBg,
    _kGreenBorder,
    Icons.arrow_downward_rounded,
  ),
  'medium': _SeverityCfg(
    'Medium',
    _kOrange,
    _kOrangeBg,
    _kOrangeBorder,
    Icons.remove_rounded,
  ),
  'high': _SeverityCfg(
    'High',
    _kRed,
    _kRedBg,
    _kRedBorder,
    Icons.arrow_upward_rounded,
  ),
  'critical': _SeverityCfg(
    'Critical',
    Color(0xFF7F1D1D),
    Color(0xFFFEE2E2),
    Color(0xFFFCA5A5),
    Icons.priority_high_rounded,
  ),
};

_SeverityCfg _sevCfg(String s) => _severityMap[s] ?? _severityMap['medium']!;
const _kSeverities = ['low', 'medium', 'high', 'critical'];

// ─── Personal Info Field Model ─────────────────────────────────────────────────
class _InfoField {
  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;
  // FIX 1: give isRequired an inline default so it is always initialized
  bool isRequired = false;

  _InfoField({String label = '', String value = ''})
    : labelCtrl = TextEditingController(text: label),
      valueCtrl = TextEditingController(text: value);

  void dispose() {
    labelCtrl.dispose();
    valueCtrl.dispose();
  }

  Map<String, dynamic> toMap() => {
    'label': labelCtrl.text.trim(),
    'value': valueCtrl.text.trim(),
    'required': isRequired,
  };
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _Incident {
  final String id;
  final String category;
  final String? incidentType;
  final String severity;
  String status;
  final String? referenceNo;
  final String? notes;
  final List<Map<String, dynamic>> personalInfo;
  final String createdAt;

  _Incident({
    required this.id,
    required this.category,
    this.incidentType,
    required this.severity,
    required this.status,
    this.referenceNo,
    this.notes,
    this.personalInfo = const [],
    required this.createdAt,
  });

  static List<Map<String, dynamic>> _parseList(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List)
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (raw is String) {
        final d = jsonDecode(raw);
        if (d is List)
          return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  factory _Incident.fromMap(Map<String, dynamic> m) => _Incident(
    id: m['id'].toString(),
    category: m['incident_category'] ?? 'other',
    incidentType: m['incident_type'],
    severity: m['severity'] ?? 'medium',
    status: m['status'] ?? 'pending',
    referenceNo: m['reference_no'],
    notes: m['notes'],
    personalInfo: _parseList(m['personal_info']),
    createdAt: m['created_at'] != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
        : '',
  );

  String get reporterName {
    if (personalInfo.isEmpty) return 'Unknown';
    final match = personalInfo.firstWhere(
      (f) => [
        'name',
        'full',
      ].any((k) => (f['label'] ?? '').toString().toLowerCase().contains(k)),
      orElse: () => personalInfo.first,
    );
    final v = match['value']?.toString() ?? '';
    return v.isEmpty ? 'Unknown' : v;
  }
}

// ============================================================================
//  ADMIN INCIDENT PAGE (List)
// ============================================================================
class AdminIncidentPage extends StatefulWidget {
  const AdminIncidentPage({super.key});

  @override
  State<AdminIncidentPage> createState() => _AdminIncidentPageState();
}

class _AdminIncidentPageState extends State<AdminIncidentPage>
    with SingleTickerProviderStateMixin {
  String _filterStatus = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  final _statusTabs = [
    'all',
    'pending',
    'investigating',
    'resolved',
    'dismissed',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _statusTabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging)
        setState(() => _filterStatus = _statusTabs[_tabCtrl.index]);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Incident> _filter(List<_Incident> all) {
    return all.where((inc) {
      final matchStatus = _filterStatus == 'all' || inc.status == _filterStatus;
      final q = _search.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          inc.reporterName.toLowerCase().contains(q) ||
          inc.category.toLowerCase().contains(q) ||
          (inc.incidentType?.toLowerCase().contains(q) ?? false) ||
          (inc.referenceNo?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('incidents')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        final all = (snapshot.data ?? []).map(_Incident.fromMap).toList();
        final filtered = _filter(all);

        final counts = {
          for (var s in _statusTabs)
            s: s == 'all' ? all.length : all.where((i) => i.status == s).length,
        };

        return Scaffold(
          backgroundColor: _kBg,
          appBar: AppBar(
            backgroundColor: _kBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kAccent,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Incident Reports',
              style: TextStyle(
                color: _kText,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
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
                    instantRoute(const _CreateIncidentPage()),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSummary(counts),
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
                      hintText: 'Search reporter, category…',
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
                child:
                    snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData
                    ? const Center(
                        child: CircularProgressIndicator(color: _kAccent),
                      )
                    : filtered.isEmpty
                    ? _EmptyState(filter: _filterStatus)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _IncidentCard(
                          incident: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            instantRoute(
                              _IncidentDetailPage(incident: filtered[i]),
                            ),
                          ),
                          onStatusChange: (s) async => await _sb
                              .from('incidents')
                              .update({'status': s})
                              .eq('id', filtered[i].id),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(Map<String, int> counts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _StatPill(
            '${counts['pending']}',
            'Pending',
            _kOrange,
            _kOrangeBg,
            _kOrangeBorder,
          ),
          const SizedBox(width: 8),
          _StatPill(
            '${counts['investigating']}',
            'Active',
            _kBlue,
            _kBlueBg,
            _kBlueBorder,
          ),
          const SizedBox(width: 8),
          _StatPill(
            '${counts['resolved']}',
            'Resolved',
            _kGreen,
            _kGreenBg,
            _kGreenBorder,
          ),
          const SizedBox(width: 8),
          _StatPill(
            '${counts['all']}',
            'Total',
            _kAccent,
            _kAccentBg,
            _kAccentBorder,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'Pending', 'Investigating', 'Resolved', 'Dismissed'];
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
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _tabCtrl.index == i
                        ? _kAccentBg
                        : const Color(0xFFF3F4F6),
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

// ─── Stat Pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String count, label;
  final Color fg, bg, border;
  const _StatPill(this.count, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: _kText3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Incident Card ─────────────────────────────────────────────────────────────
class _IncidentCard extends StatelessWidget {
  final _Incident incident;
  final VoidCallback onTap;
  final void Function(String) onStatusChange;

  const _IncidentCard({
    required this.incident,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final sCfg = _sCfg(incident.status);
    final sevCfg = _sevCfg(incident.severity);
    final cat = _catByKey(incident.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: cat.color.withOpacity(0.25)),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incident.incidentType?.isNotEmpty == true
                              ? incident.incidentType!
                              : cat.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: cat.color.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: cat.color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: sevCfg.bg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: sevCfg.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(sevCfg.icon, size: 8, color: sevCfg.fg),
                                  const SizedBox(width: 3),
                                  Text(
                                    sevCfg.label,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: sevCfg.fg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 11,
                              color: _kText3,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                incident.reporterName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kText3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sCfg.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sCfg.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sCfg.icon, size: 10, color: sCfg.fg),
                            const SizedBox(width: 4),
                            Text(
                              sCfg.label,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: sCfg.fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        incident.createdAt,
                        style: const TextStyle(fontSize: 9, color: _kText3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  if (incident.referenceNo != null) ...[
                    const Icon(Icons.sell_outlined, size: 11, color: _kText3),
                    const SizedBox(width: 4),
                    Text(
                      incident.referenceNo!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kText3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  if (incident.status == 'pending')
                    _QuickAction(
                      label: 'Investigate',
                      icon: Icons.manage_search_rounded,
                      color: _kBlue,
                      onTap: () => onStatusChange('investigating'),
                    ),
                  if (incident.status == 'investigating') ...[
                    _QuickAction(
                      label: 'Resolve',
                      icon: Icons.check_rounded,
                      color: _kGreen,
                      onTap: () => onStatusChange('resolved'),
                    ),
                    const SizedBox(width: 6),
                    _QuickAction(
                      label: 'Dismiss',
                      icon: Icons.do_not_disturb_rounded,
                      color: _kGray,
                      onTap: () => onStatusChange('dismissed'),
                    ),
                  ],
                  const SizedBox(width: 6),
                  _QuickAction(
                    label: 'View',
                    icon: Icons.arrow_forward_ios_rounded,
                    color: _kAccent,
                    onTap: onTap,
                    filled: true,
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

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(filled ? 1 : 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kAccentBg,
              shape: BoxShape.circle,
              border: Border.all(color: _kAccentBorder),
            ),
            child: const Icon(
              Icons.crisis_alert_rounded,
              color: _kAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No incident reports',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            filter == 'all'
                ? 'No incidents filed yet.\nTap "New" to file a report.'
                : 'No $filter incidents found.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Pill Button ───────────────────────────────────────────────────────────────
class _PillBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _kAccentBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kAccentBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _kAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: _kAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  INCIDENT DETAIL PAGE
// ============================================================================
class _IncidentDetailPage extends StatefulWidget {
  final _Incident incident;
  const _IncidentDetailPage({required this.incident});

  @override
  State<_IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<_IncidentDetailPage> {
  late String _status;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.incident.status;
    _notesCtrl.text = widget.incident.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _sb
        .from('incidents')
        .update({
          'status': _status,
          'notes': _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
        })
        .eq('id', widget.incident.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
      context,
      'Delete this report?',
      'This action cannot be undone.',
    );
    if (confirmed != true) return;
    await _sb.from('incidents').delete().eq('id', widget.incident.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sCfg = _sCfg(_status);
    final sevCfg = _sevCfg(widget.incident.severity);
    final cat = _catByKey(widget.incident.category);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kAccent,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Incident Detail',
          style: TextStyle(
            color: _kText,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: _kRed,
              size: 20,
            ),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.color.withOpacity(0.28)),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.incident.incidentType?.isNotEmpty == true
                              ? widget.incident.incidentType!
                              : cat.label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: cat.color.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: cat.color,
                                ),
                              ),
                            ),
                            if (widget.incident.referenceNo != null) ...[
                              const SizedBox(width: 5),
                              Text(
                                widget.incident.referenceNo!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kText3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: sCfg.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sCfg.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sCfg.icon, size: 11, color: sCfg.fg),
                            const SizedBox(width: 4),
                            Text(
                              sCfg.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: sCfg.fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sevCfg.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sevCfg.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sevCfg.icon, size: 10, color: sevCfg.fg),
                            const SizedBox(width: 3),
                            Text(
                              '${sevCfg.label} Severity',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: sevCfg.fg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _SectionLabel(label: 'Report Info'),
            const SizedBox(height: 8),
            _DetailCard(
              child: _DetailRow(
                Icons.calendar_today_rounded,
                'Filed',
                widget.incident.createdAt,
              ),
            ),

            const SizedBox(height: 12),
            _SectionLabel(label: 'Reporter'),
            const SizedBox(height: 8),
            _DetailCard(
              child: widget.incident.personalInfo.isNotEmpty
                  ? Column(
                      children: [
                        for (
                          int i = 0;
                          i < widget.incident.personalInfo.length;
                          i++
                        ) ...[
                          if (i > 0) _DividerLine(),
                          _InfoDetailRow(info: widget.incident.personalInfo[i]),
                        ],
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No reporter information provided.',
                        style: TextStyle(fontSize: 12, color: _kText3),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
            _SectionLabel(label: 'Update Status'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: _kStatuses.map((s) {
                final c = _sCfg(s);
                final active = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: active ? c.bg : _kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? c.border : _kBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(c.icon, size: 14, color: active ? c.fg : _kText3),
                        const SizedBox(width: 6),
                        Text(
                          c.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: active ? c.fg : _kText3,
                          ),
                        ),
                        if (active) ...[
                          const SizedBox(width: 5),
                          Icon(
                            Icons.check_circle_rounded,
                            size: 11,
                            color: c.fg,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),
            _SectionLabel(label: 'Admin Notes'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 13, color: _kText),
                decoration: const InputDecoration(
                  hintText: 'Add internal notes or remarks…',
                  hintStyle: TextStyle(color: _kText3, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  disabledBackgroundColor: _kAccent.withOpacity(0.45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Detail Row ───────────────────────────────────────────────────────────
class _InfoDetailRow extends StatelessWidget {
  final Map<String, dynamic> info;
  const _InfoDetailRow({required this.info});

  @override
  Widget build(BuildContext context) {
    final label = info['label']?.toString() ?? '';
    final value = info['value']?.toString() ?? '';
    final isRequired = info['required'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isRequired ? _kAccentBg : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isRequired ? _kAccentBorder : _kBorder),
            ),
            child: Icon(
              isRequired ? Icons.person_rounded : Icons.person_outline_rounded,
              size: 13,
              color: isRequired ? _kAccent : _kText3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label.isEmpty ? 'Unnamed Field' : label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kText2,
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _kRedBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _kRedBorder),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 9,
                            color: _kRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kText3,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  CREATE INCIDENT PAGE
// ============================================================================
class _CreateIncidentPage extends StatefulWidget {
  const _CreateIncidentPage();

  @override
  State<_CreateIncidentPage> createState() => _CreateIncidentPageState();
}

class _CreateIncidentPageState extends State<_CreateIncidentPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final _incidentTypeCtrl = TextEditingController();
  String _severity = 'medium';
  final List<_InfoField> _personalFields = [];
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  bool get _isOther => _selectedCategory == 'other';

  @override
  void dispose() {
    _incidentTypeCtrl.dispose();
    _notesCtrl.dispose();
    for (final f in _personalFields) f.dispose();
    super.dispose();
  }

  void _addPersonalField() => setState(() => _personalFields.add(_InfoField()));
  void _removePersonalField(int i) => setState(() {
    _personalFields[i].dispose();
    _personalFields.removeAt(i);
  });

  Future<void> _save() async {
    if (_selectedCategory == null) {
      _snack('Please select an incident category.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_isOther && _incidentTypeCtrl.text.trim().isEmpty) {
      _snack('Please specify the incident type.');
      return;
    }
    for (final f in _personalFields) {
      if (f.isRequired && f.valueCtrl.text.trim().isEmpty) {
        _snack(
          '"${f.labelCtrl.text.isEmpty ? 'A required field' : f.labelCtrl.text}" cannot be empty.',
        );
        return;
      }
    }

    setState(() => _saving = true);
    final refNo = 'INC-${Random().nextInt(90000) + 10000}';

    bool hasContent(_InfoField f) =>
        f.labelCtrl.text.trim().isNotEmpty ||
        f.valueCtrl.text.trim().isNotEmpty;

    final infoList = _personalFields
        .where(hasContent)
        .map((f) => f.toMap())
        .toList();

    try {
      await _sb.from('incidents').insert({
        'incident_category': _selectedCategory,
        'incident_type': _isOther ? _incidentTypeCtrl.text.trim() : null,
        'severity': _severity,
        'status': 'pending',
        'reference_no': refNo,
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'personal_info': infoList.isEmpty ? null : infoList,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _kRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kAccent,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Incident Report',
          style: TextStyle(
            color: _kText,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kAccent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.check_rounded,
                    color: _kAccent,
                    size: 22,
                  ),
                  onPressed: _save,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category ──
              Row(
                children: [
                  const Expanded(
                    child: _SectionLabel(label: 'Incident Category'),
                  ),
                  if (_selectedCategory == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kRedBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _kRedBorder),
                      ),
                      child: const Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 9,
                          color: _kRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3.2,
                children: _kCategories.map((cat) {
                  final active = _selectedCategory == cat.key;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = cat.key;
                      if (cat.key != 'other') _incidentTypeCtrl.clear();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: active ? cat.color.withOpacity(0.12) : _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? cat.color.withOpacity(0.5) : _kBorder,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            size: 15,
                            color: active ? cat.color : _kText3,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: active ? cat.color : _kText3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 11,
                              color: cat.color,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (_isOther) ...[
                const SizedBox(height: 14),
                _AdminFormField(
                  label: 'Specify Incident Type',
                  controller: _incidentTypeCtrl,
                  icon: Icons.crisis_alert_rounded,
                  hint: 'e.g. Stray animals, Flooding, Pothole…',
                  required: true,
                ),
              ],

              const SizedBox(height: 20),

              // ── Severity ──
              _SectionLabel(label: 'Severity Level'),
              const SizedBox(height: 10),
              Row(
                children: _kSeverities.map((s) {
                  final c = _sevCfg(s);
                  final active = _severity == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _severity = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(
                          right: s != _kSeverities.last ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? c.bg : _kSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? c.border : _kBorder,
                            width: active ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              c.icon,
                              size: 16,
                              color: active ? c.fg : _kText3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: active
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: active ? c.fg : _kText3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Personal Fields ──
              _DynamicFieldSection(
                sectionLabel: "Reporter's Personal Details",
                addButtonLabel: 'Add Field',
                infoText:
                    'Add fields for the reporter\'s personal information '
                    '(e.g. Full Name, Contact No, Address). Toggle "Required" '
                    'to mark fields as mandatory.',
                emptyHint:
                    'No personal fields added yet.\nTap "Add Field" to collect reporter info.',
                fields: _personalFields,
                onAdd: _addPersonalField,
                onRemove: _removePersonalField,
                onToggleRequired: (i, val) =>
                    setState(() => _personalFields[i].isRequired = val),
              ),

              const SizedBox(height: 20),

              // ── Admin Notes ──
              _SectionLabel(label: 'Admin Notes'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13, color: _kText),
                  decoration: const InputDecoration(
                    hintText: 'Internal remarks (optional)…',
                    hintStyle: TextStyle(color: _kText3, fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.crisis_alert_rounded, size: 18),
                  label: const Text(
                    'Submit Incident Report',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  DYNAMIC FIELD SECTION
// ============================================================================
class _DynamicFieldSection extends StatelessWidget {
  final String sectionLabel, addButtonLabel, infoText, emptyHint;
  final List<_InfoField> fields;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final void Function(int, bool) onToggleRequired;

  const _DynamicFieldSection({
    required this.sectionLabel,
    required this.addButtonLabel,
    required this.infoText,
    required this.emptyHint,
    required this.fields,
    required this.onAdd,
    required this.onRemove,
    required this.onToggleRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel(label: sectionLabel)),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kAccentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kAccentBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 13, color: _kAccent),
                    const SizedBox(width: 4),
                    Text(
                      addButtonLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _kSurface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: _kAccent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  infoText,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kText2,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (fields.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.playlist_add_rounded,
                    color: _kText3,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    emptyHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kText3,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(
            fields.length,
            (i) => _InfoFieldCard(
              key: ObjectKey(fields[i]),
              field: fields[i],
              index: i + 1,
              onRemove: () => onRemove(i),
              onToggleRequired: (val) => onToggleRequired(i, val),
            ),
          ),
      ],
    );
  }
}

// ─── Info Field Card ──────────────────────────────────────────────────────────
class _InfoFieldCard extends StatefulWidget {
  final _InfoField field;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<bool> onToggleRequired;

  const _InfoFieldCard({
    super.key,
    required this.field,
    required this.index,
    required this.onRemove,
    required this.onToggleRequired,
  });

  @override
  State<_InfoFieldCard> createState() => _InfoFieldCardState();
}

class _InfoFieldCardState extends State<_InfoFieldCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: widget.field.isRequired ? _kAccentBorder : _kBorder,
          width: widget.field.isRequired ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
            decoration: BoxDecoration(
              color: widget.field.isRequired
                  ? _kSurface2
                  : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: const Border(
                bottom: BorderSide(color: _kBorder, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: widget.field.isRequired ? _kAccent : _kBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.field.labelCtrl.text.isEmpty
                        ? 'Field ${widget.index}'
                        : widget.field.labelCtrl.text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.field.isRequired ? _kAccent : _kText2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      widget.onToggleRequired(!widget.field.isRequired),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.field.isRequired
                          ? _kRedBg
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.field.isRequired ? _kRedBorder : _kBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.field.isRequired
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 11,
                          color: widget.field.isRequired ? _kRed : _kText3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.field.isRequired ? 'Required' : 'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.field.isRequired ? _kRed : _kText3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _kRedBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kRedBorder),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: _kRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _InlineInput(
                  controller: widget.field.labelCtrl,
                  icon: Icons.label_outline_rounded,
                  hint: 'Field label (e.g. Full Name, Contact No)',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                _InlineInput(
                  controller: widget.field.valueCtrl,
                  icon: Icons.short_text_rounded,
                  hint: widget.field.isRequired
                      ? 'Value (required)…'
                      : 'Value (optional)…',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline Input ─────────────────────────────────────────────────────────────
class _InlineInput extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _InlineInput({
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              top: maxLines > 1 ? 11 : 0,
              right: 2,
            ),
            child: Icon(icon, size: 14, color: _kText3),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 12, color: _kText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _kText3, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Admin Form Field ─────────────────────────────────────────────────────────
class _AdminFormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  // FIX 2: maxLines declared final and given a default in the constructor
  final int maxLines;

  const _AdminFormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.required = false,
    this.maxLines = 1, // ← was missing; caused the compile error
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kText2,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: _kRed, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: _kText),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? '$label is required'
                    : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kText3, fontSize: 13),
            prefixIcon: Icon(icon, size: 17, color: _kText3),
            filled: true,
            fillColor: _kSurface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: maxLines > 1 ? 14 : 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _kRed, width: 1.5),
            ),
            errorStyle: const TextStyle(fontSize: 11, color: _kRed),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Components ────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _kText,
          ),
        ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _kText3),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _kText3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 12,
                color: _kText2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: _kBorder);
}

// ─── Utility ──────────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context, String title, String body) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Text(body, style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: _kText3)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Confirm',
            style: TextStyle(color: _kRed, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
