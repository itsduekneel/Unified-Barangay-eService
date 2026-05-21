import 'dart:convert';
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
const _kTeal = Color(0xFF0891B2);
const _kTealBg = Color(0xFFECFEFF);
const _kTealBorder = Color(0xFFA5F3FC);

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
  'processing': _StatusCfg(
    'Processing',
    _kBlue,
    _kBlueBg,
    _kBlueBorder,
    Icons.autorenew_rounded,
  ),
  'completed': _StatusCfg(
    'Completed',
    _kGreen,
    _kGreenBg,
    _kGreenBorder,
    Icons.check_circle_outline_rounded,
  ),
  'released': _StatusCfg(
    'Released',
    _kTeal,
    _kTealBg,
    _kTealBorder,
    Icons.move_to_inbox_rounded,
  ),
  'rejected': _StatusCfg(
    'Rejected',
    _kRed,
    _kRedBg,
    _kRedBorder,
    Icons.cancel_outlined,
  ),
};

_StatusCfg _sCfg(String s) => _statusMap[s] ?? _statusMap['pending']!;

const _kStatuses = [
  'pending',
  'processing',
  'completed',
  'released',
  'rejected',
];
const _kStatusTabs = [
  'all',
  'pending',
  'processing',
  'completed',
  'released',
  'rejected',
];
const _kTabLabels = [
  'All',
  'Pending',
  'Processing',
  'Done',
  'Released',
  'Rejected',
];

// ─── Transaction Type Config ───────────────────────────────────────────────────
class _TypeCfg {
  final String label;
  final IconData icon;
  final Color color, bg, border;
  const _TypeCfg(this.label, this.icon, this.color, this.bg, this.border);
}

const _typeMap = {
  'clearance': _TypeCfg(
    'Clearance',
    Icons.verified_outlined,
    _kGreen,
    _kGreenBg,
    _kGreenBorder,
  ),
  'certificate': _TypeCfg(
    'Certificate',
    Icons.workspace_premium_outlined,
    _kBlue,
    _kBlueBg,
    _kBlueBorder,
  ),
  'permit': _TypeCfg(
    'Permit',
    Icons.approval_outlined,
    _kOrange,
    _kOrangeBg,
    _kOrangeBorder,
  ),
  'indigency': _TypeCfg(
    'Indigency',
    Icons.volunteer_activism_outlined,
    _kAccent,
    _kAccentBg,
    _kAccentBorder,
  ),
  'id': _TypeCfg(
    'Barangay ID',
    Icons.badge_outlined,
    _kTeal,
    _kTealBg,
    _kTealBorder,
  ),
  'complaint': _TypeCfg(
    'Complaint',
    Icons.report_outlined,
    _kRed,
    _kRedBg,
    _kRedBorder,
  ),
  'other': _TypeCfg(
    'Other',
    Icons.help_outline_rounded,
    _kGray,
    _kGrayBg,
    _kGrayBorder,
  ),
};

_TypeCfg _tCfg(String? t) => _typeMap[t] ?? _typeMap['other']!;

const _kTypes = [
  'clearance',
  'certificate',
  'permit',
  'indigency',
  'id',
  'complaint',
  'other',
];

// ─── Transaction Model ─────────────────────────────────────────────────────────
class _Txn {
  final String id;
  final String serviceType;
  final String serviceName;
  final String status;
  final String? referenceNo;
  final String? barangayId;
  final String? barangayName;
  final String? purpose;
  final String? notes;
  final String? adminNotes;
  final String? fee;
  final List<Map<String, dynamic>> residentInfo;
  final String createdAt;
  final String? completedAt;
  final String? releasedAt;

  _Txn({
    required this.id,
    required this.serviceType,
    required this.serviceName,
    required this.status,
    this.referenceNo,
    this.barangayId,
    this.barangayName,
    this.purpose,
    this.notes,
    this.adminNotes,
    this.fee,
    this.residentInfo = const [],
    required this.createdAt,
    this.completedAt,
    this.releasedAt,
  });

  static List<Map<String, dynamic>> _parseList(dynamic raw) {
    if (raw == null) return [];
    try {
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      if (raw is String) {
        final d = jsonDecode(raw);
        if (d is List) {
          return d.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  factory _Txn.fromMap(Map<String, dynamic> m) => _Txn(
    id: m['id'].toString(),
    serviceType: m['service_type'] ?? 'other',
    serviceName: m['service_name'] ?? '',
    status: m['status'] ?? 'pending',
    referenceNo: m['reference_no'],
    barangayId: m['barangay_id']?.toString(),
    barangayName: (m['barangays'] as Map<String, dynamic>?)?['name'] as String?,
    purpose: m['purpose'],
    notes: m['notes'],
    adminNotes: m['admin_notes'],
    fee: m['fee'],
    residentInfo: _parseList(m['resident_info']),
    createdAt: m['created_at'] != null
        ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
        : '',
    completedAt: m['completed_at'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['completed_at']))
        : null,
    releasedAt: m['released_at'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['released_at']))
        : null,
  );

  String get residentName {
    if (residentInfo.isEmpty) return 'Unknown';
    final match = residentInfo.firstWhere(
      (f) => [
        'name',
        'full',
      ].any((k) => (f['label'] ?? '').toString().toLowerCase().contains(k)),
      orElse: () => residentInfo.first,
    );
    final v = match['value']?.toString() ?? '';
    return v.isEmpty ? 'Unknown' : v;
  }

  _TypeCfg get typeCfg => _tCfg(serviceType);
  _StatusCfg get sCfg => _sCfg(status);
}

// ══════════════════════════════════════════════════════════════════════════════
//  ADMIN SERVICE TRANSACTIONS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class AdminServiceTransactionsPage extends StatefulWidget {
  const AdminServiceTransactionsPage({super.key});

  @override
  State<AdminServiceTransactionsPage> createState() =>
      _AdminServiceTransactionsPageState();
}

class _AdminServiceTransactionsPageState
    extends State<AdminServiceTransactionsPage>
    with SingleTickerProviderStateMixin {
  String _search = '';
  String? _selBarangayId;
  String? _selType;
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _kStatusTabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _filterStatus => _kStatusTabs[_tabCtrl.index];

  List<_Txn> _filter(List<_Txn> all) {
    return all.where((t) {
      final matchStatus = _filterStatus == 'all' || t.status == _filterStatus;
      final matchBrgy =
          _selBarangayId == null || t.barangayId == _selBarangayId;
      final matchType = _selType == null || t.serviceType == _selType;
      final q = _search.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          t.residentName.toLowerCase().contains(q) ||
          t.serviceName.toLowerCase().contains(q) ||
          (t.referenceNo?.toLowerCase().contains(q) ?? false) ||
          (t.barangayName?.toLowerCase().contains(q) ?? false) ||
          (t.purpose?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchBrgy && matchType && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('service_transactions')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _sb.from('barangays').select('id, name'),
          builder: (context, brgySnap) {
            final brgyMap = <String, String>{
              for (final b in (brgySnap.data ?? []))
                b['id'].toString(): b['name'] as String,
            };

            final all = (snapshot.data ?? []).map((m) {
              final enriched = Map<String, dynamic>.from(m);
              enriched['barangays'] = {
                'name': brgyMap[m['barangay_id']?.toString()],
              };
              return _Txn.fromMap(enriched);
            }).toList();

            final filtered = _filter(all);

            final counts = {
              for (final s in _kStatusTabs)
                s: s == 'all'
                    ? all.length
                    : all.where((t) => t.status == s).length,
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
                  'Service Transactions',
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
                      icon: Icons.tune_rounded,
                      label: 'Filter',
                      active: _selType != null || _selBarangayId != null,
                      onTap: () => _showFilterSheet(brgyMap),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // ── Summary pills ────────────────────────────────────
                  _buildSummary(counts),

                  // ── Search bar ───────────────────────────────────────
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
                        decoration: InputDecoration(
                          hintText: 'Search resident, service, reference…',
                          hintStyle: const TextStyle(
                            color: _kText3,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: _kText3,
                            size: 18,
                          ),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: _kText3,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Active filter chips ──────────────────────────────
                  if (_selBarangayId != null || _selType != null)
                    _buildActiveFilterChips(brgyMap),

                  // ── Status tabs ──────────────────────────────────────
                  _buildTabs(counts),

                  // ── List ─────────────────────────────────────────────
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) => _TxnCard(
                              txn: filtered[i],
                              onTap: () => Navigator.push(
                                context,
                                instantRoute(_TxnDetailPage(txn: filtered[i])),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
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
            '${counts['processing']}',
            'Processing',
            _kBlue,
            _kBlueBg,
            _kBlueBorder,
          ),
          const SizedBox(width: 8),
          _StatPill(
            '${counts['completed']}',
            'Done',
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

  Widget _buildActiveFilterChips(Map<String, String> brgyMap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 13, color: _kAccent),
          const SizedBox(width: 6),
          if (_selBarangayId != null)
            _ActiveChip(
              label: brgyMap[_selBarangayId] ?? 'Barangay',
              icon: Icons.location_on_outlined,
              onRemove: () => setState(() => _selBarangayId = null),
            ),
          if (_selType != null) ...[
            if (_selBarangayId != null) const SizedBox(width: 6),
            _ActiveChip(
              label: _tCfg(_selType).label,
              icon: _tCfg(_selType).icon,
              onRemove: () => setState(() => _selType = null),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              _selBarangayId = null;
              _selType = null;
            }),
            child: const Text(
              'Clear all',
              style: TextStyle(
                fontSize: 11,
                color: _kAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
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
        tabs: List.generate(_kTabLabels.length, (i) {
          final key = _kStatusTabs[i];
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_kTabLabels[i]),
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

  void _showFilterSheet(Map<String, String> brgyMap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: _kSurface,
      builder: (_) => _FilterSheet(
        brgyMap: brgyMap,
        selectedBarangayId: _selBarangayId,
        selectedType: _selType,
        onApply: (brgyId, type) {
          setState(() {
            _selBarangayId = brgyId;
            _selType = type;
          });
          Navigator.pop(context);
        },
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

// ─── Active Filter Chip ────────────────────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;
  const _ActiveChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kAccentBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccentBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _kAccent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kAccent,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 12, color: _kAccent),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Card (mirrors _ApptCard) ────────────────────────────────────
class _TxnCard extends StatelessWidget {
  final _Txn txn;
  final VoidCallback onTap;
  const _TxnCard({required this.txn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = txn.typeCfg;
    final status = txn.sCfg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
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
                  // ── Type icon ─────────────────────────────────────
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: type.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(type.icon, color: type.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service name
                        Text(
                          txn.serviceName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        // Type label
                        Text(
                          type.label,
                          style: const TextStyle(fontSize: 11, color: _kText3),
                        ),
                        const SizedBox(height: 5),
                        // Row 1 — resident + barangay
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            _IconText(
                              Icons.person_outline_rounded,
                              txn.residentName,
                              11,
                            ),
                            if (txn.barangayName != null &&
                                txn.barangayName!.isNotEmpty)
                              _IconText(
                                Icons.location_on_outlined,
                                txn.barangayName!,
                                11,
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Row 2 — reference + fee
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            if (txn.referenceNo != null)
                              _IconText(
                                Icons.sell_outlined,
                                txn.referenceNo!,
                                11,
                              ),
                            if (txn.fee != null && txn.fee!.isNotEmpty)
                              _IconText(Icons.payments_outlined, txn.fee!, 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Status badge
                        _TxnStatusBadge(cfg: status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Barangay tag
                  if (txn.barangayName != null && txn.barangayName!.isNotEmpty)
                    _InlineTag(
                      Icons.location_city_outlined,
                      txn.barangayName!,
                      _kAccent,
                      _kAccentBg,
                      _kAccentBorder,
                    ),
                  const Spacer(),
                  Text(
                    txn.createdAt,
                    style: const TextStyle(fontSize: 9, color: _kText3),
                  ),
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

// ─── Icon Text ─────────────────────────────────────────────────────────────────
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;
  const _IconText(this.icon, this.text, this.size);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: size, color: _kText3),
      const SizedBox(width: 3),
      Text(
        text,
        style: TextStyle(fontSize: size, color: _kText3),
      ),
    ],
  );
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _TxnStatusBadge extends StatelessWidget {
  final _StatusCfg cfg;
  const _TxnStatusBadge({required this.cfg});

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
          Text(
            cfg.label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: cfg.fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Inline Tag ────────────────────────────────────────────────────────────────
class _InlineTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fg, bg, border;
  const _InlineTag(this.icon, this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action ──────────────────────────────────────────────────────────────
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
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.25)),
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
              Icons.receipt_long_outlined,
              color: _kAccent,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No transactions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            filter == 'all'
                ? 'No service transactions yet.'
                : 'No $filter transactions found.',
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
  final bool active;
  final VoidCallback onTap;
  const _PillBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _kAccent : _kAccentBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kAccentBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : _kAccent),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _kAccent,
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

// ══════════════════════════════════════════════════════════════════════════════
//  FILTER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final Map<String, String> brgyMap;
  final String? selectedBarangayId;
  final String? selectedType;
  final void Function(String? brgyId, String? type) onApply;

  const _FilterSheet({
    required this.brgyMap,
    required this.selectedBarangayId,
    required this.selectedType,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _brgyId;
  String? _type;

  @override
  void initState() {
    super.initState();
    _brgyId = widget.selectedBarangayId;
    _type = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: SizedBox(
                width: 40,
                child: Divider(thickness: 3, color: _kBorder),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kText,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _brgyId = null;
                    _type = null;
                  }),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 12,
                      color: _kAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Service Type ─────────────────────────────────────────
            const _SectionLabel(label: 'Service Type'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: _kTypes.map((t) {
                final cfg = _tCfg(t);
                final active = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = active ? null : t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active ? cfg.color : cfg.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? cfg.color : cfg.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cfg.icon,
                          size: 12,
                          color: active ? Colors.white : cfg.color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cfg.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : cfg.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // ── Barangay ─────────────────────────────────────────────
            const _SectionLabel(label: 'Barangay'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _brgyId,
                  hint: const Text(
                    'All Barangays',
                    style: TextStyle(color: _kText3, fontSize: 13),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _kText3,
                    size: 20,
                  ),
                  style: const TextStyle(fontSize: 13, color: _kText),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        '— All Barangays —',
                        style: TextStyle(color: _kText3),
                      ),
                    ),
                    ...widget.brgyMap.entries.map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _brgyId = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Apply ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () => widget.onApply(_brgyId, _type),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  TRANSACTION DETAIL PAGE  (mirrors _ApptDetailPage)
// ══════════════════════════════════════════════════════════════════════════════
class _TxnDetailPage extends StatefulWidget {
  final _Txn txn;
  const _TxnDetailPage({required this.txn});

  @override
  State<_TxnDetailPage> createState() => _TxnDetailPageState();
}

class _TxnDetailPageState extends State<_TxnDetailPage> {
  late String _status;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.txn.status;
    _notesCtrl.text = widget.txn.adminNotes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final now = DateTime.now().toIso8601String();
    final updates = <String, dynamic>{
      'status': _status,
      'admin_notes': _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      'updated_at': now,
    };
    if (_status == 'completed' && widget.txn.completedAt == null) {
      updates['completed_at'] = now;
    }
    if (_status == 'released' && widget.txn.releasedAt == null) {
      updates['released_at'] = now;
    }
    await _sb
        .from('service_transactions')
        .update(updates)
        .eq('id', widget.txn.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await _confirm(
      context,
      'Delete this transaction?',
      'This action cannot be undone.',
    );
    if (ok != true) return;
    await _sb.from('service_transactions').delete().eq('id', widget.txn.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.txn;
    final type = t.typeCfg;
    final sCfg = _sCfg(_status);

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
          'Transaction Detail',
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
            // ── Header card ──────────────────────────────────────────
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: type.color.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(type.icon, color: type.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.serviceName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        if (t.referenceNo != null)
                          Text(
                            t.referenceNo!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kText3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Current status badge
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Transaction Info ─────────────────────────────────────
            const _SectionLabel(label: 'Transaction Info'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(Icons.category_outlined, 'Type', type.label),
                  _DividerLine(),
                  _DetailRow(
                    Icons.location_city_outlined,
                    'Barangay',
                    t.barangayName ?? '—',
                  ),
                  _DividerLine(),
                  _DetailRow(
                    Icons.payments_outlined,
                    'Fee',
                    t.fee?.isNotEmpty == true ? t.fee! : '—',
                  ),
                  _DividerLine(),
                  _DetailRow(
                    Icons.info_outline_rounded,
                    'Purpose',
                    t.purpose?.isNotEmpty == true ? t.purpose! : '—',
                  ),
                  _DividerLine(),
                  _DetailRow(
                    Icons.calendar_today_rounded,
                    'Filed',
                    t.createdAt,
                  ),
                  if (t.completedAt != null) ...[
                    _DividerLine(),
                    _DetailRow(
                      Icons.check_circle_outline_rounded,
                      'Completed',
                      t.completedAt!,
                    ),
                  ],
                  if (t.releasedAt != null) ...[
                    _DividerLine(),
                    _DetailRow(
                      Icons.move_to_inbox_rounded,
                      'Released',
                      t.releasedAt!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Resident Info ────────────────────────────────────────
            const _SectionLabel(label: 'Resident Information'),
            const SizedBox(height: 8),
            _DetailCard(
              child: t.residentInfo.isNotEmpty
                  ? Column(
                      children: [
                        for (int i = 0; i < t.residentInfo.length; i++) ...[
                          if (i > 0) _DividerLine(),
                          _ResidentDetailRow(info: t.residentInfo[i]),
                        ],
                      ],
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No resident information provided.',
                        style: TextStyle(fontSize: 12, color: _kText3),
                      ),
                    ),
            ),

            // ── Remarks ──────────────────────────────────────────────
            if (t.notes != null && t.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const _SectionLabel(label: 'Remarks from Resident'),
              const SizedBox(height: 8),
              _DetailCard(
                child: Text(
                  t.notes!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kText2,
                    height: 1.6,
                  ),
                ),
              ),
            ],

            // ── Update Status ────────────────────────────────────────
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

            // ── Admin Notes ──────────────────────────────────────────
            const SizedBox(height: 18),
            const _SectionLabel(label: 'Admin Notes'),
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

            // ── Save ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  disabledBackgroundColor: _kAccent.withValues(alpha: 0.45),
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

// ─── Resident Detail Row ───────────────────────────────────────────────────────
class _ResidentDetailRow extends StatelessWidget {
  final Map<String, dynamic> info;
  const _ResidentDetailRow({required this.info});

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

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED COMPONENTS
// ══════════════════════════════════════════════════════════════════════════════

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
            color: Colors.black.withValues(alpha: 0.04),
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
