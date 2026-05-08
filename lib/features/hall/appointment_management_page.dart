import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL — run once:
//
//   create table appointments (
//     id uuid primary key default gen_random_uuid(),
//     created_at timestamptz default now(),
//     service_name text not null,
//     service_duration text,
//     appointment_date date not null,
//     appointment_time text not null,
//     full_name text not null,
//     contact_no text not null,
//     purpose text,
//     status text default 'pending',   -- pending | confirmed | completed | cancelled
//     reference_no text,
//     notes text,                      -- admin notes
//     requirements jsonb,              -- [{label, value, required}]
//     resident_info jsonb              -- [{label, value, required}]
//   );
// ─────────────────────────────────────────────────────────────────────────────

final _sb = Supabase.instance.client;

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _kBg = Color(0xFFF5F4FA);
const _kSurface = Color(0xFFFFFFFF);
const _kSurface2 = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);
const _kAccent = Color(0xFF8B2CF5);
const _kAccent2 = Color(0xFF6B1BD4);
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

// ─── Status Config ─────────────────────────────────────────────────────────────
class _StatusCfg {
  final String label;
  final Color fg, bg, border;
  final IconData icon;
  const _StatusCfg(this.label, this.fg, this.bg, this.border, this.icon);
}

const _statusMap = {
  'pending': _StatusCfg(
      'Pending', _kOrange, _kOrangeBg, _kOrangeBorder, Icons.hourglass_empty_rounded),
  'confirmed': _StatusCfg(
      'Confirmed', _kBlue, _kBlueBg, _kBlueBorder, Icons.event_available_rounded),
  'completed': _StatusCfg(
      'Completed', _kGreen, _kGreenBg, _kGreenBorder, Icons.check_circle_outline_rounded),
  'cancelled': _StatusCfg(
      'Cancelled', _kRed, _kRedBg, _kRedBorder, Icons.cancel_outlined),
};

_StatusCfg _cfg(String s) => _statusMap[s] ?? _statusMap['pending']!;

const _kStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];

// ─── Requirement Field Model ───────────────────────────────────────────────────
class _ReqField {
  final TextEditingController labelCtrl;
  final TextEditingController valueCtrl;
  bool isRequired;

  _ReqField({String label = '', String value = '', this.isRequired = false})
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
class _Appt {
  final String id;
  final String? userId; // Added userId
  final String serviceName;
  final String? serviceDuration;
  final String date;
  final String time;
  final String fullName;
  final String contactNo;
  final String? purpose;
  String status;
  final String? referenceNo;
  final String? notes;
  final List<Map<String, dynamic>> requirements;
  final List<Map<String, dynamic>> residentInfo;
  final String createdAt;

  _Appt({
    required this.id,
    this.userId,
    required this.serviceName,
    this.serviceDuration,
    required this.date,
    required this.time,
    required this.fullName,
    required this.contactNo,
    this.purpose,
    required this.status,
    this.referenceNo,
    this.notes,
    this.requirements = const [],
    this.residentInfo = const [],
    required this.createdAt,
  });

  static List<Map<String, dynamic>> _parseJsonbList(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (raw is String) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  factory _Appt.fromMap(Map<String, dynamic> m) {
    return _Appt(
      id: m['id'].toString(),
      userId: m['user_id']?.toString(), // Map user_id
      serviceName: m['service_name'] ?? '',
      serviceDuration: m['service_duration'],
      date: m['appointment_date'] ?? '',
      time: m['appointment_time'] ?? '',
      fullName: m['full_name'] ?? '',
      contactNo: m['contact_no'] ?? '',
      purpose: m['purpose'],
      status: m['status'] ?? 'pending',
      referenceNo: m['reference_no'],
      notes: m['notes'],
      requirements: _parseJsonbList(m['requirements']),
      residentInfo: _parseJsonbList(m['resident_info']),
      createdAt: m['created_at'] != null
          ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
          : '',
    );
  }

  String get formattedDate {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
Route _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);

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
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _filterStatus = _statusTabs[_tabCtrl.index]);
      }
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
          a.fullName.toLowerCase().contains(q) ||
          a.serviceName.toLowerCase().contains(q) ||
          a.contactNo.contains(q) ||
          (a.referenceNo?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('appointments')
          .stream(primaryKey: ['id'])
          .order('appointment_date', ascending: true),
      builder: (context, snapshot) {
        final all = (snapshot.data ?? []).map(_Appt.fromMap).toList();
        final filtered = _filter(all);

        final counts = {
          for (var s in _statusTabs)
            s: s == 'all' ? all.length : all.where((a) => a.status == s).length
        };

        return Scaffold(
          backgroundColor: _kBg,
          appBar: AppBar(
            backgroundColor: _kBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _kAccent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Appointments',
              style: TextStyle(
                  color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _PillBtn(
                  icon: Icons.add_rounded,
                  label: 'New',
                  onTap: () => Navigator.push(
                      context, _slide(const _CreateApptPage())),
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
                      hintText: 'Search name, service, reference…',
                      hintStyle: TextStyle(color: _kText3, fontSize: 13),
                      prefixIcon:
                      Icon(Icons.search, color: _kText3, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              _buildTabs(counts),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData
                    ? const Center(
                    child:
                    CircularProgressIndicator(color: _kAccent))
                    : filtered.isEmpty
                    ? _EmptyState(filter: _filterStatus)
                    : ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ApptCard(
                    appt: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      _slide(_ApptDetailPage(appt: filtered[i])),
                    ),
                    onStatusChange: (s) async {
                      await _sb
                          .from('appointments')
                          .update({'status': s}).eq(
                          'id', filtered[i].id);
                    },
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
          _StatPill('${counts['pending']}', 'Pending', _kOrange, _kOrangeBg,
              _kOrangeBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['confirmed']}', 'Today', _kBlue, _kBlueBg,
              _kBlueBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['completed']}', 'Done', _kGreen, _kGreenBg,
              _kGreenBorder),
          const SizedBox(width: 8),
          _StatPill(
              '${counts['all']}', 'Total', _kAccent, _kAccentBg, _kAccentBorder),
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
        labelStyle:
        const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
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
                      horizontal: 6, vertical: 1),
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
            Text(count,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: fg)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: _kText3,
                    fontWeight: FontWeight.w600)),
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
    final cfg = _cfg(appt.status);

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
                offset: const Offset(0, 2)),
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
                      color: _kSurface2,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayNum(appt.date),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _kAccent),
                        ),
                        Text(
                          _monthShort(appt.date),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _kText3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              appt.fullName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _kText),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (appt.userId != null) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified_user_rounded, size: 12, color: _kAccent),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          appt.serviceName,
                          style: const TextStyle(
                              fontSize: 11, color: _kText3),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 11, color: _kText3),
                            const SizedBox(width: 3),
                            Text(appt.time,
                                style: const TextStyle(
                                    fontSize: 11, color: _kText3)),
                            const SizedBox(width: 8),
                            const Icon(Icons.phone_outlined,
                                size: 11, color: _kText3),
                            const SizedBox(width: 3),
                            Text(appt.contactNo,
                                style: const TextStyle(
                                    fontSize: 11, color: _kText3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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
                        Text(cfg.label,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: cfg.fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: _kBorder, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  if (appt.referenceNo != null) ...[
                    const Icon(Icons.sell_outlined,
                        size: 11, color: _kText3),
                    const SizedBox(width: 4),
                    Text(
                      appt.referenceNo!,
                      style: const TextStyle(
                          fontSize: 10,
                          color: _kText3,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  if (appt.status == 'pending')
                    _QuickAction(
                      label: 'Confirm',
                      icon: Icons.event_available_rounded,
                      color: _kBlue,
                      onTap: () => onStatusChange('confirmed'),
                    ),
                  if (appt.status == 'confirmed') ...[
                    _QuickAction(
                      label: 'Complete',
                      icon: Icons.check_rounded,
                      color: _kGreen,
                      onTap: () => onStatusChange('completed'),
                    ),
                    const SizedBox(width: 8),
                    _QuickAction(
                      label: 'Cancel',
                      icon: Icons.close_rounded,
                      color: _kRed,
                      onTap: () => onStatusChange('cancelled'),
                    ),
                  ],
                  const SizedBox(width: 8),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border:
          Border.all(color: color.withOpacity(filled ? 1 : 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 11, color: filled ? Colors.white : color),
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

// ─── Empty State ──────────────────────────────────────────────────────────────
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
            child: const Icon(Icons.calendar_today_outlined,
                color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'No appointments',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kText),
          ),
          const SizedBox(height: 5),
          Text(
            filter == 'all'
                ? 'Create a new appointment using the\nbutton in the top right.'
                : 'No $filter appointments found.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Pill Button ─────────────────────────────────────────────────────────────
class _PillBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            Text(label,
                style: const TextStyle(
                    color: _kAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
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
  const _ApptDetailPage({super.key, required this.appt});

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
      'notes': _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    }).eq('id', widget.appt.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
        context, 'Delete this appointment?', 'This action cannot be undone.');
    if (confirmed != true) return;
    await _sb
        .from('appointments')
        .delete()
        .eq('id', widget.appt.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg(_status);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointment Detail',
          style: TextStyle(
              color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: _kRed, size: 20),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Reference & Status ──
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _kAccentBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kAccentBorder),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: _kAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appt.serviceName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kText),
                        ),
                        if (widget.appt.referenceNo != null)
                          Text(
                            widget.appt.referenceNo!,
                            style: const TextStyle(
                                fontSize: 11, color: _kText3),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cfg.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cfg.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cfg.icon, size: 11, color: cfg.fg),
                        const SizedBox(width: 4),
                        Text(cfg.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: cfg.fg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Schedule ──
            _SectionLabel(label: 'Schedule'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(Icons.event_rounded, 'Date',
                      widget.appt.formattedDate),
                  _DividerLine(),
                  _DetailRow(
                      Icons.access_time_rounded, 'Time', widget.appt.time),
                  if (widget.appt.serviceDuration != null) ...[
                    _DividerLine(),
                    _DetailRow(Icons.timer_outlined, 'Duration',
                        widget.appt.serviceDuration!),
                  ],
                  _DividerLine(),
                  _DetailRow(Icons.calendar_today_rounded, 'Filed',
                      widget.appt.createdAt),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Resident Info — dynamic fields if present, fallback to legacy ──
            _SectionLabel(label: 'Resident'),
            const SizedBox(height: 8),
            _DetailCard(
              child: widget.appt.residentInfo.isNotEmpty
                  ? Column(
                children: [
                  for (int i = 0; i < widget.appt.residentInfo.length; i++) ...[
                    if (i > 0) _DividerLine(),
                    _RequirementDetailRow(req: widget.appt.residentInfo[i]),
                  ],
                ],
              )
                  : Column(
                children: [
                  _DetailRow(Icons.person_outline_rounded, 'Name',
                      widget.appt.fullName),
                  _DividerLine(),
                  _DetailRow(Icons.phone_outlined, 'Contact',
                      widget.appt.contactNo),
                  if (widget.appt.purpose?.isNotEmpty == true) ...[
                    _DividerLine(),
                    _DetailRow(Icons.notes_rounded, 'Purpose',
                        widget.appt.purpose!),
                  ],
                ],
              ),
            ),

            // ── Requirements (if any) ──
            if (widget.appt.requirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionLabel(label: 'Service Requirements'),
              const SizedBox(height: 8),
              _DetailCard(
                child: Column(
                  children: [
                    for (int i = 0;
                    i < widget.appt.requirements.length;
                    i++) ...[
                      if (i > 0) _DividerLine(),
                      _RequirementDetailRow(
                          req: widget.appt.requirements[i]),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Update Status ──
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
                final c = _cfg(s);
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
                        Icon(c.icon,
                            size: 14,
                            color: active ? c.fg : _kText3),
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
                          Icon(Icons.check_circle_rounded,
                              size: 11, color: c.fg),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

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
                style:
                const TextStyle(fontSize: 13, color: _kText),
                decoration: const InputDecoration(
                  hintText: 'Add internal notes or remarks…',
                  hintStyle:
                  TextStyle(color: _kText3, fontSize: 12),
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
                  disabledBackgroundColor:
                  _kAccent.withOpacity(0.45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Requirement Detail Row ───────────────────────────────────────────────────
class _RequirementDetailRow extends StatelessWidget {
  final Map<String, dynamic> req;
  const _RequirementDetailRow({required this.req});

  @override
  Widget build(BuildContext context) {
    final label = req['label']?.toString() ?? '';
    final value = req['value']?.toString() ?? '';
    final isRequired = req['required'] == true;

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
              border: Border.all(
                  color: isRequired ? _kAccentBorder : _kBorder),
            ),
            child: Icon(
              isRequired
                  ? Icons.assignment_turned_in_outlined
                  : Icons.assignment_outlined,
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
                            color: _kText2),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontSize: 12, color: _kText3, height: 1.4),
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
//  CREATE APPOINTMENT PAGE (Admin)
//  — Schedule & Initial Status removed
//  — Resident Details now uses the same dynamic field system as Requirements
// ============================================================================
class _CreateApptPage extends StatefulWidget {
  const _CreateApptPage();

  @override
  State<_CreateApptPage> createState() => _CreateApptPageState();
}

class _CreateApptPageState extends State<_CreateApptPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Service ──
  final _serviceNameCtrl = TextEditingController();
  final _serviceDurationCtrl = TextEditingController();

  // ── Resident Details — dynamic fields ──
  final List<_ReqField> _residentFields = [];

  // ── Service Requirements — dynamic fields ──
  final List<_ReqField> _requirements = [];

  // ── Admin Notes ──
  final _notesCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _serviceNameCtrl.dispose();
    _serviceDurationCtrl.dispose();
    _notesCtrl.dispose();
    for (final r in _residentFields) r.dispose();
    for (final r in _requirements) r.dispose();
    super.dispose();
  }

  // ── Resident field helpers ──
  void _addResidentField() => setState(() => _residentFields.add(_ReqField()));
  void _removeResidentField(int i) => setState(() {
    _residentFields[i].dispose();
    _residentFields.removeAt(i);
  });

  // ── Requirement field helpers ──
  void _addRequirement() => setState(() => _requirements.add(_ReqField()));
  void _removeRequirement(int i) => setState(() {
    _requirements[i].dispose();
    _requirements.removeAt(i);
  });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_serviceNameCtrl.text.trim().isEmpty) {
      _snack('Please enter a service name.');
      return;
    }

    // Validate required resident fields
    for (final r in _residentFields) {
      if (r.isRequired && r.valueCtrl.text.trim().isEmpty) {
        _snack(
            '"${r.labelCtrl.text.isEmpty ? 'A required resident field' : r.labelCtrl.text}" cannot be empty.');
        return;
      }
    }

    // Validate required requirement fields
    for (final r in _requirements) {
      if (r.isRequired && r.valueCtrl.text.trim().isEmpty) {
        _snack(
            '"${r.labelCtrl.text.isEmpty ? 'A required field' : r.labelCtrl.text}" cannot be empty.');
        return;
      }
    }

    setState(() => _saving = true);
    final refNo = 'APT-${Random().nextInt(90000) + 10000}';
    final now = DateTime.now();

    // Extract full_name / contact_no from resident fields for DB compat.
    // Looks for a field whose label contains "name" → full_name.
    // Looks for a field whose label contains "contact" or "phone" → contact_no.
    // Falls back to first / second field if no match; defaults to "N/A" if empty.
    String _extractField(List<_ReqField> fields, List<String> keywords,
        {int fallbackIndex = 0}) {
      final match = fields.firstWhere(
            (f) => keywords.any(
                (k) => f.labelCtrl.text.toLowerCase().contains(k)),
        orElse: () =>
        fields.length > fallbackIndex ? fields[fallbackIndex] : _ReqField(),
      );
      final v = match.valueCtrl.text.trim();
      return v.isEmpty ? 'N/A' : v;
    }

    final fullName = _residentFields.isEmpty
        ? 'N/A'
        : _extractField(_residentFields, ['name', 'full'], fallbackIndex: 0);
    final contactNo = _residentFields.isEmpty
        ? 'N/A'
        : _extractField(_residentFields, ['contact', 'phone', 'mobile'],
        fallbackIndex: 1);

    // Build jsonb lists — skip completely empty rows
    bool _hasContent(_ReqField f) =>
        f.labelCtrl.text.trim().isNotEmpty ||
            f.valueCtrl.text.trim().isNotEmpty;

    final residentList = _residentFields
        .where(_hasContent)
        .map((r) => r.toMap())
        .toList();

    final reqList = _requirements
        .where(_hasContent)
        .map((r) => r.toMap())
        .toList();

    try {
      await _sb.from('appointments').insert({
        'service_name': _serviceNameCtrl.text.trim(),
        'service_duration': _serviceDurationCtrl.text.trim().isEmpty
            ? null
            : _serviceDurationCtrl.text.trim(),
        // Default to today's date and current time since schedule is set later
        'appointment_date': _isoDate(now),
        'appointment_time': TimeOfDay.fromDateTime(now).format(context),
        'full_name': fullName,
        'contact_no': contactNo,
        'purpose': null,
        'status': 'pending',
        'reference_no': refNo,
        'notes': _notesCtrl.text.trim().isEmpty
            ? null
            : _notesCtrl.text.trim(),
        'resident_info': residentList.isEmpty ? null : residentList,
        'requirements': reqList.isEmpty ? null : reqList,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: _kRed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Appointment',
          style: TextStyle(
              color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
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
                  strokeWidth: 2, color: _kAccent),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.check_rounded,
                color: _kAccent, size: 22),
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

              // ══════════════════════════════════════════════════
              //  SERVICE SECTION
              // ══════════════════════════════════════════════════
              _SectionLabel(label: 'Service'),
              const SizedBox(height: 10),

              _AdminFormField(
                label: 'Service Name',
                controller: _serviceNameCtrl,
                icon: Icons.miscellaneous_services_rounded,
                hint: 'e.g. Barangay Clearance',
                required: true,
              ),
              const SizedBox(height: 10),

              _AdminFormField(
                label: 'Estimated Duration',
                controller: _serviceDurationCtrl,
                icon: Icons.timer_outlined,
                hint: 'e.g. 15 mins, 30 mins',
              ),

              const SizedBox(height: 20),

              // ══════════════════════════════════════════════════
              //  RESIDENT DETAILS — dynamic fields
              // ══════════════════════════════════════════════════
              _DynamicFieldSection(
                sectionLabel: 'Resident Details',
                addButtonLabel: 'Add Field',
                infoText:
                'Add fields for the resident\'s personal information '
                    '(e.g. Full Name, Contact No, Address). Toggle "Required" '
                    'to mark fields as mandatory.',
                emptyHint:
                'No resident fields added yet.\nTap "Add Field" to define what info to collect.',
                fields: _residentFields,
                onAdd: _addResidentField,
                onRemove: _removeResidentField,
                onToggleRequired: (i, val) =>
                    setState(() => _residentFields[i].isRequired = val),
              ),

              const SizedBox(height: 20),

              // ══════════════════════════════════════════════════
              //  SERVICE REQUIREMENTS — dynamic fields
              // ══════════════════════════════════════════════════
              _DynamicFieldSection(
                sectionLabel: 'Service Requirements',
                addButtonLabel: 'Add Field',
                infoText:
                'Add fields for information the resident must provide '
                    '(e.g. Valid ID, Proof of Residency). Toggle "Required" '
                    'to mark fields as mandatory.',
                emptyHint:
                'No requirements added yet.\nTap "Add Field" to define what info is needed.',
                fields: _requirements,
                onAdd: _addRequirement,
                onRemove: _removeRequirement,
                onToggleRequired: (i, val) =>
                    setState(() => _requirements[i].isRequired = val),
              ),

              const SizedBox(height: 20),

              // ══════════════════════════════════════════════════
              //  ADMIN NOTES
              // ══════════════════════════════════════════════════
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
                  style:
                  const TextStyle(fontSize: 13, color: _kText),
                  decoration: const InputDecoration(
                    hintText: 'Internal remarks (optional)…',
                    hintStyle:
                    TextStyle(color: _kText3, fontSize: 12),
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
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(
                      Icons.calendar_today_rounded,
                      size: 18),
                  label: const Text(
                    'Create Appointment',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
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
//  DYNAMIC FIELD SECTION — shared widget for both Resident Details
//  and Service Requirements, keeps things DRY
// ============================================================================
class _DynamicFieldSection extends StatelessWidget {
  final String sectionLabel;
  final String addButtonLabel;
  final String infoText;
  final String emptyHint;
  final List<_ReqField> fields;
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
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kAccentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kAccentBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 13, color: _kAccent),
                    const SizedBox(width: 4),
                    Text(
                      addButtonLabel,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kAccent),
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
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: _kAccent),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  infoText,
                  style: const TextStyle(
                      fontSize: 11, color: _kText2, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (fields.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
                vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.playlist_add_rounded,
                      color: _kText3, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    emptyHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, color: _kText3, height: 1.6),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(fields.length, (i) {
            return _RequirementFieldCard(
              key: ObjectKey(fields[i]),
              field: fields[i],
              index: i + 1,
              onRemove: () => onRemove(i),
              onToggleRequired: (val) => onToggleRequired(i, val),
            );
          }),
      ],
    );
  }
}

// ─── Requirement Field Card ───────────────────────────────────────────────────
class _RequirementFieldCard extends StatefulWidget {
  final _ReqField field;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<bool> onToggleRequired;

  const _RequirementFieldCard({
    super.key,
    required this.field,
    required this.index,
    required this.onRemove,
    required this.onToggleRequired,
  });

  @override
  State<_RequirementFieldCard> createState() =>
      _RequirementFieldCardState();
}

class _RequirementFieldCardState
    extends State<_RequirementFieldCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color:
          widget.field.isRequired ? _kAccentBorder : _kBorder,
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
          // ── Card Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
            decoration: BoxDecoration(
              color: widget.field.isRequired
                  ? _kSurface2
                  : const Color(0xFFFAFAFA),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12)),
              border: const Border(
                  bottom: BorderSide(color: _kBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: widget.field.isRequired
                        ? _kAccent
                        : _kBorder,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
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
                      color: widget.field.isRequired
                          ? _kAccent
                          : _kText2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Required toggle
                GestureDetector(
                  onTap: () {
                    widget.onToggleRequired(
                        !widget.field.isRequired);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.field.isRequired
                          ? _kRedBg
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: widget.field.isRequired
                              ? _kRedBorder
                              : _kBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.field.isRequired
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 11,
                          color: widget.field.isRequired
                              ? _kRed
                              : _kText3,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.field.isRequired
                              ? 'Required'
                              : 'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.field.isRequired
                                ? _kRed
                                : _kText3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Remove button
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _kRedBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kRedBorder),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 12, color: _kRed),
                  ),
                ),
              ],
            ),
          ),

          // ── Field Inputs ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      ? 'Value or description (required) …'
                      : 'Value or description (optional) …',
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
                right: 2),
            child: Icon(icon, size: 14, color: _kText3),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              onChanged: onChanged,
              style:
              const TextStyle(fontSize: 12, color: _kText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                const TextStyle(color: _kText3, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
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
  final TextInputType? keyboard;
  final bool required;
  final int maxLines;

  const _AdminFormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboard,
    this.required = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kText2)),
            if (required)
              const Text(' *',
                  style: TextStyle(color: _kRed, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboard,
          style: const TextStyle(fontSize: 13, color: _kText),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty)
              ? '$label is required'
              : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            const TextStyle(color: _kText3, fontSize: 13),
            prefixIcon:
            Icon(icon, size: 17, color: _kText3),
            filled: true,
            fillColor: _kSurface,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: maxLines > 1 ? 14 : 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _kBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _kBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: _kAccent, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: _kRed, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                    color: _kRed, width: 1.5)),
            errorStyle: const TextStyle(
                fontSize: 11, color: _kRed),
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
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kText)),
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
              offset: const Offset(0, 2)),
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
            width: 68,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: _kText3,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                  fontSize: 12,
                  color: _kText2,
                  fontWeight: FontWeight.w500),
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

// ─── Utility ─────────────────────────────────────────────────────────────────
String _dayNum(String date) {
  try {
    return DateTime.parse(date).day.toString();
  } catch (_) {
    return '—';
  }
}

String _monthShort(String date) {
  const m = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];
  try {
    return m[DateTime.parse(date).month - 1];
  } catch (_) {
    return '';
  }
}

String _isoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<bool?> _confirm(
    BuildContext context, String title, String body) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(body,
          style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel',
              style: TextStyle(color: _kText3)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm',
              style: TextStyle(
                  color: _kRed, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}