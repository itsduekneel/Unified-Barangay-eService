import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/core/utils/route_utils.dart';

final _sb = Supabase.instance.client;

// ─── Design Tokens ─────────────────────────────────────────────────────────────
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

// ─── Picker Icon Options ───────────────────────────────────────────────────────
class _IconOption {
  final String key;
  final IconData icon;
  const _IconOption(this.key, this.icon);
}

const _kIconOptions = [
  _IconOption('calendar',   Icons.calendar_month_rounded),
  _IconOption('document',   Icons.description_outlined),
  _IconOption('person',     Icons.person_outline_rounded),
  _IconOption('id',         Icons.badge_outlined),
  _IconOption('briefcase',  Icons.work_outline_rounded),
  _IconOption('medical',    Icons.add_box_outlined),
  _IconOption('home',       Icons.home_outlined),
  _IconOption('star',       Icons.star_outline_rounded),
  _IconOption('shield',     Icons.shield_outlined),
  _IconOption('phone',      Icons.phone_outlined),
  _IconOption('check',      Icons.fact_check_outlined),
  _IconOption('stamp',      Icons.approval_outlined),
  _IconOption('info',       Icons.info_outline_rounded),
  _IconOption('list',       Icons.list_alt_rounded),
  _IconOption('other',      Icons.help_outline_rounded),
];

IconData _iconByKey(String key) =>
    _kIconOptions.firstWhere((o) => o.key == key, orElse: () => _kIconOptions.last).icon;

// ─── Picker Color Options ──────────────────────────────────────────────────────
const _kColorOptions = [
  Color(0xFF1E0447),
  Color(0xFFEA580C),
  Color(0xFFF97316),
  Color(0xFF1D4ED8),
  Color(0xFF16A34A),
  Color(0xFF7C3AED),
  Color(0xFF6B7280),
];

// ─── Status Config ─────────────────────────────────────────────────────────────
class _StatusCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _StatusCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _statusMap = {
  'pending':   _StatusCfg('Pending',   _kOrange, _kOrangeBg, _kOrangeBorder, Icons.hourglass_empty_rounded),
  'confirmed': _StatusCfg('Confirmed', _kBlue,   _kBlueBg,   _kBlueBorder,   Icons.event_available_rounded),
  'completed': _StatusCfg('Completed', _kGreen,  _kGreenBg,  _kGreenBorder,  Icons.check_circle_outline_rounded),
  'cancelled': _StatusCfg('Cancelled', _kGray,   _kGrayBg,   _kGrayBorder,   Icons.do_not_disturb_rounded),
};

_StatusCfg _sCfg(String s) => _statusMap[s] ?? _statusMap['pending']!;
const _kStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];

// ─── Resident Info Field Model ─────────────────────────────────────────────────
class _InfoField {
  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;
  bool isRequired = false;

  _InfoField({String label = '', String value = ''})
      : labelCtrl = TextEditingController(text: label),
        valueCtrl = TextEditingController(text: value);

  void dispose() {
    labelCtrl.dispose();
    valueCtrl.dispose();
  }

  Map<String, dynamic> toMap() => {
    'label':    labelCtrl.text.trim(),
    'value':    valueCtrl.text.trim(),
    'required': isRequired,
  };
}

// ─── Appointment Service Category Model ───────────────────────────────────────
class _ApptService {
  final String id;
  final String name;
  final String? duration;
  final String? description;
  final String? iconKey;
  final String? colorHex;
  final bool isActive;
  final String createdAt;

  _ApptService({
    required this.id,
    required this.name,
    this.duration,
    this.description,
    this.iconKey,
    this.colorHex,
    required this.isActive,
    required this.createdAt,
  });

  factory _ApptService.fromMap(Map<String, dynamic> m) => _ApptService(
    id:          m['id'].toString(),
    name:        m['name'] ?? '',
    duration:    m['duration'],
    description: m['description'],
    iconKey:     m['icon_key'],
    colorHex:    m['color_hex'],
    isActive:    m['is_active'] ?? true,
    createdAt:   m['created_at'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['created_at']))
        : '',
  );

  IconData get displayIcon {
    if (iconKey != null && iconKey!.isNotEmpty) return _iconByKey(iconKey!);
    return Icons.calendar_month_rounded;
  }

  Color get displayColor {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try { return Color(int.parse(colorHex!.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    return _kAccent;
  }
}

// ─── Appointment Model ─────────────────────────────────────────────────────────
class _Appt {
  final String id;
  final String serviceName;
  final String? serviceDuration;
  String status;
  final String? referenceNo;
  final String? notes;
  final List<Map<String, dynamic>> residentInfo;
  final String createdAt;
  final String? iconKey;
  final String? colorHex;
  final String date;
  final String time;

  _Appt({
    required this.id,
    required this.serviceName,
    this.serviceDuration,
    required this.status,
    this.referenceNo,
    this.notes,
    this.residentInfo = const [],
    required this.createdAt,
    this.iconKey,
    this.colorHex,
    required this.date,
    required this.time,
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

  factory _Appt.fromMap(Map<String, dynamic> m) => _Appt(
    id:              m['id'].toString(),
    serviceName:     m['service_name'] ?? '',
    serviceDuration: m['service_duration'],
    status:          m['status'] ?? 'pending',
    referenceNo:     m['reference_no'],
    notes:           m['notes'],
    residentInfo:    _parseList(m['resident_info']),
    createdAt:       m['created_at'] != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
        : '',
    iconKey:  m['icon_key'],
    colorHex: m['color_hex'],
    date: m['appointment_date'] ?? '',
    time: m['appointment_time'] ?? '',
  );

  String get residentName {
    if (residentInfo.isEmpty) return 'Unknown';
    final match = residentInfo.firstWhere(
          (f) => ['name', 'full'].any((k) => (f['label'] ?? '').toString().toLowerCase().contains(k)),
      orElse: () => residentInfo.first,
    );
    final v = match['value']?.toString() ?? '';
    return v.isEmpty ? 'Unknown' : v;
  }

  String get formattedDate {
    try { return DateFormat('MMM dd, yyyy').format(DateTime.parse(date)); }
    catch (_) { return date; }
  }

  IconData get displayIcon {
    if (iconKey != null && iconKey!.isNotEmpty) return _iconByKey(iconKey!);
    return Icons.calendar_month_rounded;
  }

  Color get displayColor {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try { return Color(int.parse(colorHex!.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    return _kAccent;
  }
}

// ============================================================================
//  ADMIN APPOINTMENT PAGE (List)
// ============================================================================
class AdminAppointmentPage extends StatefulWidget {
  const AdminAppointmentPage({super.key});

  @override
  State<AdminAppointmentPage> createState() => _AdminAppointmentPageState();
}

class _AdminAppointmentPageState extends State<AdminAppointmentPage>
    with SingleTickerProviderStateMixin {
  String _filterStatus = 'all';
  String _search = '';
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  final _statusTabs = ['all', 'pending', 'confirmed', 'completed', 'cancelled'];

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

  List<_Appt> _filter(List<_Appt> all) {
    return all.where((a) {
      final matchStatus = _filterStatus == 'all' || a.status == _filterStatus;
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          a.residentName.toLowerCase().contains(q) ||
          a.serviceName.toLowerCase().contains(q) ||
          (a.referenceNo?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('appointments')
          .stream(primaryKey: ['id']).order('created_at', ascending: false),
      builder: (context, snapshot) {
        final all      = (snapshot.data ?? []).map(_Appt.fromMap).toList();
        final filtered = _filter(all);
        final counts   = {
          for (var s in _statusTabs)
            s: s == 'all' ? all.length : all.where((a) => a.status == s).length,
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
              'Appointments',
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
                    instantRoute(const AdminApptServicePage()),
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
                      hintText: 'Search resident, service…',
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
                    ? _EmptyState(filter: _filterStatus)
                    : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ApptCard(
                    appt: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      instantRoute(_ApptDetailPage(appt: filtered[i])),
                    ),
                    onStatusChange: (s) async => await _sb
                        .from('appointments')
                        .update({'status': s}).eq('id', filtered[i].id),
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
          _StatPill('${counts['pending']}',   'Pending',  _kOrange, _kOrangeBg, _kOrangeBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['confirmed']}', 'Confirmed', _kBlue,  _kBlueBg,  _kBlueBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['completed']}', 'Done',     _kGreen,  _kGreenBg,  _kGreenBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['all']}',       'Total',    _kAccent, _kAccentBg, _kAccentBorder),
        ],
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'Pending', 'Confirmed', 'Done', 'Cancelled'];
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
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────
class _ApptCard extends StatelessWidget {
  final _Appt appt;
  final VoidCallback onTap;
  final void Function(String) onStatusChange;

  const _ApptCard({
    required this.appt,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = appt.displayColor;
    final displayIcon  = appt.displayIcon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: displayColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: displayColor.withOpacity(0.25)),
                    ),
                    child: Icon(displayIcon, color: displayColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.serviceName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kText),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        if (appt.serviceDuration != null)
                          Text(
                            appt.serviceDuration!,
                            style: const TextStyle(fontSize: 11, color: _kText3),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            _IconText(Icons.person_outline_rounded, appt.residentName, 11),
                            if (appt.referenceNo != null)
                              _IconText(Icons.sell_outlined, appt.referenceNo!, 11),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            if (appt.date.isNotEmpty)
                              _IconText(Icons.calendar_today_rounded, appt.formattedDate, 11),
                            if (appt.time.isNotEmpty)
                              _IconText(Icons.access_time_rounded, appt.time, 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _ApptStatusBadge(cfg: _sCfg(appt.status)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _ApptActionBar(appt: appt, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Icon Text ────────────────────────────────────────────────────────────────
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;
  const _IconText(this.icon, this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: _kText3),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: size, color: _kText3)),
      ],
    );
  }
}

// ─── Appointment Status Badge ──────────────────────────────────────────────────
class _ApptStatusBadge extends StatelessWidget {
  final _StatusCfg cfg;
  const _ApptStatusBadge({required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.border),
      ),
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

// ─── Appointment Action Bar ────────────────────────────────────────────────────
class _ApptActionBar extends StatelessWidget {
  final _Appt appt;
  final VoidCallback onTap;

  const _ApptActionBar({required this.appt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Text(appt.createdAt, style: const TextStyle(fontSize: 9, color: _kText3)),
        const SizedBox(width: 8),
        _QuickAction(
          label: 'View',
          icon: Icons.arrow_forward_ios_rounded,
          color: _kAccent,
          onTap: onTap,
          filled: true,
        ),
      ],
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
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: filled ? Colors.white : color)),
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
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _kAccentBg, shape: BoxShape.circle,
              border: Border.all(color: _kAccentBorder),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('No appointments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
          const SizedBox(height: 5),
          Text(
            filter == 'all'
                ? 'No appointments yet.\nTap "New" to create one.'
                : 'No $filter appointments found.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Pill Button ──────────────────────────────────────────────────────────────
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
            Text(label, style: const TextStyle(color: _kAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  ADMIN APPOINTMENT SERVICE PAGE  (mirrors AdminIncidentCategoryPage)
// ============================================================================
class AdminApptServicePage extends StatefulWidget {
  const AdminApptServicePage({super.key});

  @override
  State<AdminApptServicePage> createState() => _AdminApptServicePageState();
}

class _AdminApptServicePageState extends State<AdminApptServicePage> {
  List<_ApptService> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final data = await _sb
          .from('appointment_services')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _services = (data as List).map((m) => _ApptService.fromMap(m)).toList();
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goAdd() {
    Navigator.push(context, instantRoute(const _CreateApptServicePage()))
        .then((_) => _fetch());
  }

  void _goEdit(_ApptService svc) {
    Navigator.push(context, instantRoute(_EditApptServicePage(service: svc)))
        .then((_) => _fetch());
  }

  Future<void> _delete(_ApptService svc) async {
    final confirmed = await _confirm(context, 'Delete "${svc.name}"?', 'This action cannot be undone.');
    if (confirmed == true) {
      await _sb.from('appointment_services').delete().eq('id', svc.id);
      _fetch();
    }
  }

  Future<void> _toggle(_ApptService svc, bool val) async {
    setState(() {
      final idx = _services.indexWhere((s) => s.id == svc.id);
      if (idx != -1) {
        _services[idx] = _ApptService(
          id: svc.id, name: svc.name, duration: svc.duration,
          description: svc.description, iconKey: svc.iconKey,
          colorHex: svc.colorHex, isActive: val, createdAt: svc.createdAt,
        );
      }
    });
    try {
      await _sb.from('appointment_services').update({'is_active': val}).eq('id', svc.id);
    } catch (_) {
      setState(() {
        final idx = _services.indexWhere((s) => s.id == svc.id);
        if (idx != -1) {
          _services[idx] = _ApptService(
            id: svc.id, name: svc.name, duration: svc.duration,
            description: svc.description, iconKey: svc.iconKey,
            colorHex: svc.colorHex, isActive: !val, createdAt: svc.createdAt,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total    = _services.length;
    final active   = _services.where((s) => s.isActive).length;
    final disabled = total - active;

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
          'Appointment Services',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _PillBtn(icon: Icons.add_rounded, label: 'Add', onTap: _goAdd),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                _ServicePill('$total',    'Total',    _kAccent, _kAccentBg, _kAccentBorder),
                const SizedBox(width: 8),
                _ServicePill('$active',   'Active',   _kGreen,  _kGreenBg,  _kGreenBorder),
                const SizedBox(width: 8),
                _ServicePill('$disabled', 'Disabled', _kGray,   _kGrayBg,   _kGrayBorder),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _kAccent))
                : _services.isEmpty
                ? _ServiceEmptyState(onAdd: _goAdd)
                : RefreshIndicator(
              color: _kAccent,
              onRefresh: _fetch,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: _services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ServiceCard(
                  key: ValueKey(_services[i].id),
                  service: _services[i],
                  onToggle: (val) => _toggle(_services[i], val),
                  onEdit:   () => _goEdit(_services[i]),
                  onDelete: () => _delete(_services[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Service Summary Pill ──────────────────────────────────────────────────────
class _ServicePill extends StatelessWidget {
  final String count, label;
  final Color fg, bg, border;
  const _ServicePill(this.count, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Service Card (with animated toggle) ──────────────────────────────────────
class _ServiceCard extends StatefulWidget {
  final _ApptService service;
  final void Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    super.key,
    required this.service,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _thumbAnim;
  late Animation<Color?> _trackColor;
  late bool _localActive;

  @override
  void initState() {
    super.initState();
    _localActive = widget.service.isActive;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: _localActive ? 1.0 : 0.0,
    );
    _thumbAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _trackColor = ColorTween(begin: const Color(0xFFD1D5DB), end: _kAccent)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ServiceCard old) {
    super.didUpdateWidget(old);
    if (old.service.isActive != widget.service.isActive) {
      _localActive = widget.service.isActive;
      _localActive ? _animCtrl.forward() : _animCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    final next = !_localActive;
    setState(() => _localActive = next);
    next ? _animCtrl.forward() : _animCtrl.reverse();
    widget.onToggle(next);
  }

  @override
  Widget build(BuildContext context) {
    final displayColor = widget.service.displayColor;
    final displayIcon  = widget.service.displayIcon;

    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (_, __) {
        final isOn = _localActive;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOn ? _kBorder : _kBorder.withOpacity(0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isOn ? 0.05 : 0.02),
                blurRadius: isOn ? 10 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            opacity: isOn ? 1.0 : 0.5,
            child: Column(
              children: [
                // ── Main row ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: displayColor.withOpacity(isOn ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: displayColor.withOpacity(isOn ? 0.28 : 0.12)),
                        ),
                        child: Icon(displayIcon, color: displayColor.withOpacity(isOn ? 1.0 : 0.5), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText),
                            ),
                            if (widget.service.duration != null && widget.service.duration!.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kBlueBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _kBlueBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: _kBlue, shape: BoxShape.circle)),
                                    const SizedBox(width: 5),
                                    Text(widget.service.duration!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kBlue)),
                                  ],
                                ),
                              ),
                            ],
                            if (widget.service.description != null && widget.service.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.service.description!,
                                style: const TextStyle(fontSize: 12, color: _kText3, height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // ── Custom animated toggle ──
                      GestureDetector(
                        onTap: _handleTap,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: SizedBox(
                            width: 50, height: 28,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeInOut,
                                  width: 50, height: 28,
                                  decoration: BoxDecoration(
                                    color: _trackColor.value,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment(-0.65 + 1.3 * _thumbAnim.value, 0),
                                  child: Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 4, offset: const Offset(0, 1)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Divider + Edit / Delete ──
                Container(
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: _kBorder, width: 0.5))),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 14, color: _kAccent),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kAccent)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: const Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 14, color: _kRed),
                            SizedBox(width: 4),
                            Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kRed)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isOn
                            ? const _StatusLabel(key: ValueKey('on'), label: 'Active', fg: _kGreen, bg: _kGreenBg, border: _kGreenBorder, icon: Icons.check_circle_outline_rounded)
                            : const _StatusLabel(key: ValueKey('off'), label: 'Disabled', fg: _kGray, bg: _kGrayBg, border: _kGrayBorder, icon: Icons.do_not_disturb_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Status Label ─────────────────────────────────────────────────────────────
class _StatusLabel extends StatelessWidget {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _StatusLabel({super.key, required this.label, required this.fg, required this.bg, required this.border, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}

// ─── Service Empty State ───────────────────────────────────────────────────────
class _ServiceEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _ServiceEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: _kAccentBg, shape: BoxShape.circle, border: Border.all(color: _kAccentBorder)),
            child: const Icon(Icons.miscellaneous_services_rounded, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('No services yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
          const SizedBox(height: 5),
          const Text('Tap "Add" to create your first\nappointment service.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: _kText3, height: 1.6)),

        ],
      ),
    );
  }
}

// ============================================================================
//  CREATE APPOINTMENT SERVICE PAGE
// ============================================================================
class _CreateApptServicePage extends StatefulWidget {
  const _CreateApptServicePage();

  @override
  State<_CreateApptServicePage> createState() => _CreateApptServicePageState();
}

class _CreateApptServicePageState extends State<_CreateApptServicePage> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _durationCtrl  = TextEditingController();
  final _descCtrl      = TextEditingController();
  final List<_InfoField> _residentFields = [];
  bool _saving = false;

  String _selectedIconKey    = 'calendar';
  int    _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    for (final f in _residentFields) f.dispose();
    super.dispose();
  }

  void _addField()       => setState(() => _residentFields.add(_InfoField()));
  void _removeField(int i) => setState(() { _residentFields[i].dispose(); _residentFields.removeAt(i); });

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final residentSchema = _residentFields
        .where((f) => f.labelCtrl.text.trim().isNotEmpty)
        .map((f) => f.toMap())
        .toList();
    try {
      await _sb.from('appointment_services').insert({
        'name':            _nameCtrl.text.trim(),
        'duration':        _durationCtrl.text.trim().isEmpty ? null : _durationCtrl.text.trim(),
        'description':     _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'icon_key':        _selectedIconKey,
        'color_hex':       _colorToHex(_kColorOptions[_selectedColorIndex]),
        'is_active':       true,
        'resident_schema': residentSchema.isEmpty ? null : residentSchema,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: _kRed));
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
        title: const Text('New Appointment Service', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(label: 'Service Details'),
              const SizedBox(height: 10),
              _AdminFormField(
                label: 'Service Name',
                controller: _nameCtrl,
                icon: Icons.miscellaneous_services_rounded,
                hint: 'e.g. Barangay Clearance, Business Permit…',
                required: true,
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Estimated Duration',
                controller: _durationCtrl,
                icon: Icons.timer_outlined,
                hint: 'e.g. 15 mins, 30 mins',
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Description',
                controller: _descCtrl,
                icon: Icons.notes_rounded,
                hint: 'Brief description of this service…',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Icons & Colors'),
              const SizedBox(height: 10),
              _IconColorPicker(
                selectedIconKey: _selectedIconKey,
                selectedColorIndex: _selectedColorIndex,
                onIconSelected:  (key) => setState(() => _selectedIconKey = key),
                onColorSelected: (idx) => setState(() => _selectedColorIndex = idx),
              ),
              const SizedBox(height: 20),
              _DynamicFieldSection(
                sectionLabel:   "Resident's Personal Details",
                addButtonLabel: 'Add Field',
                infoText:       'Define fields for the resident\'s personal information '
                    '(e.g. Full Name, Contact No, Address). Toggle "Required" '
                    'to mark fields as mandatory.',
                emptyHint:      'No fields added yet.\nTap "Add Field" to define what info to collect.',
                fields:         _residentFields,
                onAdd:          _addField,
                onRemove:       _removeField,
                onToggleRequired: (i, val) => setState(() => _residentFields[i].isRequired = val),
              ),
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
                      : const Icon(Icons.calendar_today_rounded, size: 18),
                  label: const Text('Create Service', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
//  EDIT APPOINTMENT SERVICE PAGE
// ============================================================================
class _EditApptServicePage extends StatefulWidget {
  final _ApptService service;
  const _EditApptServicePage({required this.service});

  @override
  State<_EditApptServicePage> createState() => _EditApptServicePageState();
}

class _EditApptServicePageState extends State<_EditApptServicePage> {
  final _formKey      = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedIconKey;
  late int    _selectedColorIndex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl      = TextEditingController(text: widget.service.name);
    _durationCtrl  = TextEditingController(text: widget.service.duration ?? '');
    _descCtrl      = TextEditingController(text: widget.service.description ?? '');
    _selectedIconKey    = widget.service.iconKey ?? 'calendar';
    _selectedColorIndex = _findColorIndex(widget.service.colorHex);
  }

  int _findColorIndex(String? hex) {
    if (hex == null) return 0;
    try {
      final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      final idx   = _kColorOptions.indexOf(color);
      return idx >= 0 ? idx : 0;
    } catch (_) { return 0; }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _sb.from('appointment_services').update({
        'name':        _nameCtrl.text.trim(),
        'duration':    _durationCtrl.text.trim().isEmpty ? null : _durationCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'icon_key':    _selectedIconKey,
        'color_hex':   _colorToHex(_kColorOptions[_selectedColorIndex]),
      }).eq('id', widget.service.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: _kRed));
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
        title: const Text('Edit Service', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(label: 'Service Details'),
              const SizedBox(height: 10),
              _AdminFormField(
                label: 'Service Name',
                controller: _nameCtrl,
                icon: Icons.miscellaneous_services_rounded,
                hint: 'e.g. Barangay Clearance…',
                required: true,
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Estimated Duration',
                controller: _durationCtrl,
                icon: Icons.timer_outlined,
                hint: 'e.g. 15 mins, 30 mins',
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Description',
                controller: _descCtrl,
                icon: Icons.notes_rounded,
                hint: 'Brief description…',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Icons & Colors'),
              const SizedBox(height: 10),
              _IconColorPicker(
                selectedIconKey: _selectedIconKey,
                selectedColorIndex: _selectedColorIndex,
                onIconSelected:  (key) => setState(() => _selectedIconKey = key),
                onColorSelected: (idx) => setState(() => _selectedColorIndex = idx),
              ),
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
                      : const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
//  APPOINTMENT DETAIL PAGE
// ============================================================================
class _ApptDetailPage extends StatefulWidget {
  final _Appt appt;
  const _ApptDetailPage({required this.appt});

  @override
  State<_ApptDetailPage> createState() => _ApptDetailPageState();
}

class _ApptDetailPageState extends State<_ApptDetailPage> {
  late String _status;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.appt.status;
    _notesCtrl.text = widget.appt.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _sb.from('appointments').update({
      'status': _status,
      'notes':  _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    }).eq('id', widget.appt.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(context, 'Delete this appointment?', 'This action cannot be undone.');
    if (confirmed != true) return;
    await _sb.from('appointments').delete().eq('id', widget.appt.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sCfg         = _sCfg(_status);
    final displayIcon  = widget.appt.displayIcon;
    final displayColor = widget.appt.displayColor;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Appointment Detail', style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
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
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: displayColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: displayColor.withOpacity(0.28)),
                    ),
                    child: Icon(displayIcon, color: displayColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.appt.serviceName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
                        if (widget.appt.referenceNo != null)
                          Text(widget.appt.referenceNo!, style: const TextStyle(fontSize: 11, color: _kText3), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: sCfg.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: sCfg.border)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sCfg.icon, size: 11, color: sCfg.fg),
                        const SizedBox(width: 4),
                        Text(sCfg.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sCfg.fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _SectionLabel(label: 'Schedule Info'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(Icons.calendar_today_rounded,   'Date',     widget.appt.formattedDate),
                  _DividerLine(),
                  _DetailRow(Icons.access_time_rounded,      'Time',     widget.appt.time),
                  if (widget.appt.serviceDuration != null) ...[
                    _DividerLine(),
                    _DetailRow(Icons.timer_outlined,         'Duration', widget.appt.serviceDuration!),
                  ],
                  _DividerLine(),
                  _DetailRow(Icons.calendar_today_rounded,   'Filed',    widget.appt.createdAt),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _SectionLabel(label: 'Resident'),
            const SizedBox(height: 8),
            _DetailCard(
              child: widget.appt.residentInfo.isNotEmpty
                  ? Column(
                children: [
                  for (int i = 0; i < widget.appt.residentInfo.length; i++) ...[
                    if (i > 0) _DividerLine(),
                    _ResidentDetailRow(info: widget.appt.residentInfo[i]),
                  ],
                ],
              )
                  : const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No resident information provided.', style: TextStyle(fontSize: 12, color: _kText3)),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel(label: 'Update Status'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: _kStatuses.map((s) {
                final c      = _sCfg(s);
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
                        Icon(c.icon, size: 14, color: active ? c.fg : _kText3),
                        const SizedBox(width: 6),
                        Text(c.label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? c.fg : _kText3)),
                        if (active) ...[
                          const SizedBox(width: 5),
                          Icon(Icons.check_circle_rounded, size: 11, color: c.fg),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const _SectionLabel(label: 'Admin Notes'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
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

// ─── Resident Detail Row ───────────────────────────────────────────────────────
class _ResidentDetailRow extends StatelessWidget {
  final Map<String, dynamic> info;
  const _ResidentDetailRow({required this.info});

  @override
  Widget build(BuildContext context) {
    final label      = info['label']?.toString() ?? '';
    final value      = info['value']?.toString() ?? '';
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
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText2),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _kRedBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _kRedBorder)),
                        child: const Text('Required', style: TextStyle(fontSize: 9, color: _kRed, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 12, color: _kText3, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  ICON & COLOR PICKER WIDGET
// ============================================================================
class _IconColorPicker extends StatelessWidget {
  final String selectedIconKey;
  final int selectedColorIndex;
  final void Function(String key) onIconSelected;
  final void Function(int index) onColorSelected;

  const _IconColorPicker({
    required this.selectedIconKey,
    required this.selectedColorIndex,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = _kColorOptions[selectedColorIndex];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 1,
            ),
            itemCount: _kIconOptions.length,
            itemBuilder: (_, i) {
              final opt    = _kIconOptions[i];
              final active = opt.key == selectedIconKey;
              return GestureDetector(
                onTap: () => onIconSelected(opt.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: active ? activeColor.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? activeColor : _kBorder, width: active ? 1.5 : 1),
                  ),
                  child: Icon(opt.icon, size: 20, color: active ? activeColor : _kText3),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 8),
          Row(
            children: _kColorOptions.map((color) {
              final active = color == activeColor;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onColorSelected(_kColorOptions.indexOf(color)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? _kText : Colors.transparent, width: 3),
                    ),
                    child: active ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _kAccentBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _kAccentBorder)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 13, color: _kAccent),
                    const SizedBox(width: 4),
                    Text(addButtonLabel, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _kAccent)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: _kSurface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _kBorder)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 13, color: _kAccent),
              const SizedBox(width: 7),
              Expanded(child: Text(infoText, style: const TextStyle(fontSize: 11, color: _kText2, height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (fields.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(color: _kSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kBorder)),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.playlist_add_rounded, color: _kText3, size: 26),
                  const SizedBox(height: 6),
                  Text(emptyHint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: _kText3, height: 1.6)),
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

  const _InfoFieldCard({super.key, required this.field, required this.index, required this.onRemove, required this.onToggleRequired});

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
        border: Border.all(color: widget.field.isRequired ? _kAccentBorder : _kBorder, width: widget.field.isRequired ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
            decoration: BoxDecoration(
              color: widget.field.isRequired ? _kSurface2 : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: const Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: widget.field.isRequired ? _kAccent : _kBorder, borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('${widget.index}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.field.labelCtrl.text.isEmpty ? 'Field ${widget.index}' : widget.field.labelCtrl.text,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.field.isRequired ? _kAccent : _kText2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onToggleRequired(!widget.field.isRequired),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.field.isRequired ? _kRedBg : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: widget.field.isRequired ? _kRedBorder : _kBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.field.isRequired ? Icons.star_rounded : Icons.star_border_rounded, size: 11, color: widget.field.isRequired ? _kRed : _kText3),
                        const SizedBox(width: 4),
                        Text(widget.field.isRequired ? 'Required' : 'Optional', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.field.isRequired ? _kRed : _kText3)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: _kRedBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _kRedBorder)),
                    child: const Icon(Icons.close_rounded, size: 12, color: _kRed),
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
                  hint: widget.field.isRequired ? 'Value (required)…' : 'Value (optional)…',
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

  const _InlineInput({required this.controller, required this.icon, required this.hint, this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(9), border: Border.all(color: _kBorder)),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: maxLines > 1 ? 11 : 0, right: 2),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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

// ─── Shared Components ────────────────────────────────────────────────────────
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
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, color: _kText3, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 12, color: _kText2, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: _kBorder);
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
        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Confirm', style: TextStyle(color: _kRed, fontWeight: FontWeight.bold))),
      ],
    ),
  );
}