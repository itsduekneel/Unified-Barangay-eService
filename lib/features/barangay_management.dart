import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../core/utils/route_utils.dart';

final _sb = Supabase.instance.client;

// ─── Design Tokens ─────────────────────────────────────────────────────────────
const _kBg           = Color(0xFFF5F4FA);
const _kSurface      = Color(0xFFFFFFFF);
const _kSurface2     = Color(0xFFF5F0FF);
const _kBorder       = Color(0xFFEBE0FF);
const _kAccent       = Color(0xFF8B2CF5);
const _kText         = Color(0xFF1E0447);
const _kText2        = Color(0xFF360C78);
const _kText3        = Color(0xFF6B7280);
const _kGreen        = Color(0xFF16A34A);
const _kGreenBg      = Color(0xFFDCFCE7);
const _kGreenBorder  = Color(0xFF86EFAC);
const _kRed          = Color(0xFFDC2626);
const _kRedBg        = Color(0xFFFEF2F2);
const _kRedBorder    = Color(0xFFFCA5A5);
const _kBlue         = Color(0xFF1D4ED8);
const _kBlueBg       = Color(0xFFEFF6FF);
const _kBlueBorder   = Color(0xFFBFDBFE);
const _kAccentBg     = Color(0xFFF5F0FF);
const _kAccentBorder = Color(0xFFEBE0FF);
const _kGray         = Color(0xFF6B7280);
const _kGrayBg       = Color(0xFFF3F4F6);
const _kGrayBorder   = Color(0xFFD1D5DB);

// ─── Icon Options ──────────────────────────────────────────────────────────────
class _IconOpt {
  final String key;
  final IconData icon;
  const _IconOpt(this.key, this.icon);
}

const _kIconOptions = [
  _IconOpt('location',    Icons.location_on_outlined),
  _IconOpt('home',        Icons.home_outlined),
  _IconOpt('people',      Icons.people_outline_rounded),
  _IconOpt('shield',      Icons.shield_outlined),
  _IconOpt('star',        Icons.star_outline_rounded),
  _IconOpt('building',    Icons.apartment_outlined),
  _IconOpt('flag',        Icons.flag_outlined),
  _IconOpt('info',        Icons.info_outline_rounded),
  _IconOpt('phone',       Icons.phone_outlined),
  _IconOpt('map',         Icons.map_outlined),
  _IconOpt('badge',       Icons.badge_outlined),
  _IconOpt('nature',      Icons.park_outlined),
  _IconOpt('water',       Icons.water_outlined),
  _IconOpt('other',       Icons.help_outline_rounded),
];

IconData _iconByKey(String key) =>
    _kIconOptions.firstWhere((o) => o.key == key, orElse: () => _kIconOptions.last).icon;

// ─── Color Options ─────────────────────────────────────────────────────────────
const _kColorOptions = [
  Color(0xFF8B2CF5),
  Color(0xFF1D4ED8),
  Color(0xFF16A34A),
  Color(0xFFEA580C),
  Color(0xFFDB2777),
  Color(0xFF0891B2),
  Color(0xFF6B7280),
];

// ─── Barangay Model ────────────────────────────────────────────────────────────
class _Barangay {
  final String id;
  final String name;
  final String? captain;
  final String? contactNo;
  final String? email;
  final String? address;
  final String? zone;
  final int?    population;
  final String? notes;
  final String? iconKey;
  final String? colorHex;
  final bool    isActive;
  final String  createdAt;
  final String? updatedAt;

  const _Barangay({
    required this.id,
    required this.name,
    this.captain,
    this.contactNo,
    this.email,
    this.address,
    this.zone,
    this.population,
    this.notes,
    this.iconKey,
    this.colorHex,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory _Barangay.fromMap(Map<String, dynamic> m) => _Barangay(
    id:         m['id'].toString(),
    name:       m['name'] ?? '',
    captain:    m['captain'],
    contactNo:  m['contact_no'],
    email:      m['email'],
    address:    m['address'],
    zone:       m['zone'],
    population: m['population'] is int ? m['population'] : null,
    notes:      m['notes'],
    iconKey:    m['icon_key'],
    colorHex:   m['color_hex'],
    isActive:   m['is_active'] ?? true,
    createdAt:  m['created_at'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['created_at']))
        : '',
    updatedAt: m['updated_at'] != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['updated_at']))
        : null,
  );

  IconData get displayIcon =>
      iconKey != null && iconKey!.isNotEmpty ? _iconByKey(iconKey!) : Icons.location_on_outlined;

  Color get displayColor {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try { return Color(int.parse(colorHex!.replaceFirst('#', '0xFF'))); } catch (_) {}
    }
    return _kAccent;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  BARANGAY MANAGEMENT PAGE  (list)
// ══════════════════════════════════════════════════════════════════════════════
class BarangayManagementPage extends StatefulWidget {
  const BarangayManagementPage({super.key});

  @override
  State<BarangayManagementPage> createState() => _BarangayManagementPageState();
}

class _BarangayManagementPageState extends State<BarangayManagementPage>
    with SingleTickerProviderStateMixin {
  String _search = '';
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;
  final _tabs = ['all', 'active', 'inactive'];

  String get _filterStatus => _tabs[_tabCtrl.index];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
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

  List<_Barangay> _filter(List<_Barangay> all) {
    return all.where((b) {
      final matchStatus = switch (_filterStatus) {
        'active'   => b.isActive,
        'inactive' => !b.isActive,
        _          => true,
      };
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          b.name.toLowerCase().contains(q) ||
          (b.captain?.toLowerCase().contains(q) ?? false) ||
          (b.zone?.toLowerCase().contains(q) ?? false) ||
          (b.address?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('barangays')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true),
      builder: (context, snapshot) {
        final all      = (snapshot.data ?? []).map(_Barangay.fromMap).toList();
        final filtered = _filter(all);
        final counts   = {
          'all':      all.length,
          'active':   all.where((b) => b.isActive).length,
          'inactive': all.where((b) => !b.isActive).length,
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
              'Barangay Management',
              style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _PillBtn(
                  icon: Icons.add_rounded,
                  label: 'Add',
                  onTap: () => Navigator.push(
                    context,
                    instantRoute(const _CreateBarangayPage()),
                  ),
                ),
              ),
            ],
          ),

          // ── Full body in SingleChildScrollView ──────────────────────────
          body: RefreshIndicator(
            color: _kAccent,
            onRefresh: () async {},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Stat Pills ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        _StatPill('${counts['all']}',      'Total',    _kAccent, _kAccentBg, _kAccentBorder),
                        const SizedBox(width: 8),
                        _StatPill('${counts['active']}',   'Active',   _kGreen,  _kGreenBg,  _kGreenBorder),
                        const SizedBox(width: 8),
                        _StatPill('${counts['inactive']}', 'Inactive', _kGray,   _kGrayBg,   _kGrayBorder),
                      ],
                    ),
                  ),

                  // ── Search ──────────────────────────────────────────────
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
                          hintText: 'Search name, captain, zone…',
                          hintStyle: const TextStyle(color: _kText3, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: _kText3, size: 18),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16, color: _kText3),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),

                  // ── Tabs ────────────────────────────────────────────────
                  _buildTabs(counts),

                  // ── Content ─────────────────────────────────────────────
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
                    const SizedBox(
                      height: 320,
                      child: Center(child: CircularProgressIndicator(color: _kAccent)),
                    )
                  else if (filtered.isEmpty)
                    SizedBox(height: 320, child: _EmptyState(filter: _filterStatus))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _BarangayCard(
                        barangay: filtered[i],
                        onTap: () => Navigator.push(
                          context,
                          instantRoute(_BarangayDetailPage(barangay: filtered[i])),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'Active', 'Inactive'];
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
          final isSelected = _tabCtrl.index == i;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(labels[i]),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? _kAccentBg : _kGrayBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${counts[_tabs[i]]}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? _kAccent : _kText3,
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

// ─── Barangay Card ─────────────────────────────────────────────────────────────
class _BarangayCard extends StatelessWidget {
  final _Barangay barangay;
  final VoidCallback onTap;
  const _BarangayCard({required this.barangay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = barangay.displayColor;
    final icon  = barangay.displayIcon;

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
                  // Icon box
                  Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barangay.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kText),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        if (barangay.captain != null && barangay.captain!.isNotEmpty)
                          _IconText(Icons.person_outline_rounded, 'Kap. ${barangay.captain!}', 11),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            if (barangay.zone != null && barangay.zone!.isNotEmpty)
                              _IconText(Icons.map_outlined, barangay.zone!, 11),
                            if (barangay.contactNo != null && barangay.contactNo!.isNotEmpty)
                              _IconText(Icons.phone_outlined, barangay.contactNo!, 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _StatusBadge(isActive: barangay.isActive),
                            if (barangay.population != null) ...[
                              const SizedBox(width: 6),
                              _PopulationBadge(population: barangay.population!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _IconText(Icons.calendar_today_rounded, barangay.createdAt, 9),
                  const Spacer(),
                  _QuickBtn(
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

// ══════════════════════════════════════════════════════════════════════════════
//  BARANGAY DETAIL PAGE
// ══════════════════════════════════════════════════════════════════════════════
class _BarangayDetailPage extends StatefulWidget {
  final _Barangay barangay;
  const _BarangayDetailPage({required this.barangay});

  @override
  State<_BarangayDetailPage> createState() => _BarangayDetailPageState();
}

class _BarangayDetailPageState extends State<_BarangayDetailPage> {
  Future<void> _delete() async {
    final ok = await _confirm(context, 'Delete "${widget.barangay.name}"?', 'This action cannot be undone.');
    if (ok != true) return;
    await _sb.from('barangays').delete().eq('id', widget.barangay.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _toggleActive() async {
    final next = !widget.barangay.isActive;
    await _sb.from('barangays').update({
      'is_active':  next,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', widget.barangay.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final b     = widget.barangay;
    final color = b.displayColor;
    final icon  = b.displayIcon;

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
          'Barangay Detail',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: _kRed, size: 20),
            onPressed: _delete,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header Card ───────────────────────────────────────────────
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: color.withOpacity(0.28)),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
                        if (b.zone != null && b.zone!.isNotEmpty)
                          Text(b.zone!, style: const TextStyle(fontSize: 11, color: _kText3)),
                      ],
                    ),
                  ),
                  _StatusBadge(isActive: b.isActive),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Barangay Info ─────────────────────────────────────────────
            const _SectionLabel(label: 'Barangay Information'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailInfoRow(Icons.location_on_outlined,   'Name',       b.name),
                  _DividerLine(),
                  _DetailInfoRow(Icons.person_outline_rounded, 'Captain',    b.captain    ?? '—'),
                  _DividerLine(),
                  _DetailInfoRow(Icons.map_outlined,           'Zone',       b.zone       ?? '—'),
                  _DividerLine(),
                  _DetailInfoRow(Icons.home_outlined,          'Address',    b.address    ?? '—'),
                  _DividerLine(),
                  _DetailInfoRow(Icons.people_outline_rounded, 'Population',
                      b.population != null ? '${b.population} residents' : '—'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Contact Info ──────────────────────────────────────────────
            const _SectionLabel(label: 'Contact Information'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailInfoRow(Icons.phone_outlined,   'Contact No.', b.contactNo ?? '—'),
                  _DividerLine(),
                  _DetailInfoRow(Icons.email_outlined,   'Email',       b.email     ?? '—'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Notes ─────────────────────────────────────────────────────
            if (b.notes != null && b.notes!.isNotEmpty) ...[
              const _SectionLabel(label: 'Notes'),
              const SizedBox(height: 8),
              _DetailCard(
                child: Text(b.notes!, style: const TextStyle(fontSize: 13, color: _kText2, height: 1.5)),
              ),
              const SizedBox(height: 14),
            ],

            // ── Record Info ───────────────────────────────────────────────
            const _SectionLabel(label: 'Record Information'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailInfoRow(Icons.calendar_month_outlined, 'Created',      b.createdAt),
                  _DividerLine(),
                  _DetailInfoRow(Icons.update_outlined,         'Last Updated', b.updatedAt ?? '—'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Action Buttons ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleActive,
                    icon: Icon(
                      b.isActive ? Icons.do_not_disturb_rounded : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: b.isActive ? _kGray : _kGreen,
                    ),
                    label: Text(
                      b.isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: b.isActive ? _kGray : _kGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: b.isActive ? _kGrayBorder : _kGreenBorder),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      instantRoute(_EditBarangayPage(barangay: b)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                    label: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CREATE BARANGAY PAGE
// ══════════════════════════════════════════════════════════════════════════════
class _CreateBarangayPage extends StatefulWidget {
  const _CreateBarangayPage();

  @override
  State<_CreateBarangayPage> createState() => _CreateBarangayPageState();
}

class _CreateBarangayPageState extends State<_CreateBarangayPage> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _captainCtrl   = TextEditingController();
  final _zoneCtrl      = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _contactCtrl   = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _populationCtrl = TextEditingController();
  final _notesCtrl     = TextEditingController();
  bool _saving = false;

  String _selectedIconKey    = 'location';
  int    _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _captainCtrl.dispose();
    _zoneCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _populationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _sb.from('barangays').insert({
        'name':        _nameCtrl.text.trim(),
        'captain':     _captainCtrl.text.trim().isEmpty ? null : _captainCtrl.text.trim(),
        'zone':        _zoneCtrl.text.trim().isEmpty    ? null : _zoneCtrl.text.trim(),
        'address':     _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        'contact_no':  _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
        'email':       _emailCtrl.text.trim().isEmpty   ? null : _emailCtrl.text.trim(),
        'population':  _populationCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_populationCtrl.text.trim()),
        'notes':       _notesCtrl.text.trim().isEmpty   ? null : _notesCtrl.text.trim(),
        'icon_key':    _selectedIconKey,
        'color_hex':   _colorToHex(_kColorOptions[_selectedColorIndex]),
        'is_active':   true,
        'created_at':  DateTime.now().toIso8601String(),
        'updated_at':  DateTime.now().toIso8601String(),
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
        title: const Text(
          'New Barangay',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Basic Info ──────────────────────────────────────────────
              const _SectionLabel(label: 'Basic Information'),
              const SizedBox(height: 10),
              _FormField(
                label: 'Barangay Name',
                controller: _nameCtrl,
                icon: Icons.location_on_outlined,
                hint: 'e.g. Brgy. Batasan Hills',
                required: true,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Barangay Captain',
                controller: _captainCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'e.g. Juan Dela Cruz',
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Zone / District',
                controller: _zoneCtrl,
                icon: Icons.map_outlined,
                hint: 'e.g. Zone 1, North District',
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Address',
                controller: _addressCtrl,
                icon: Icons.home_outlined,
                hint: 'Full address of barangay hall',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // ── Contact ─────────────────────────────────────────────────
              const _SectionLabel(label: 'Contact Information'),
              const SizedBox(height: 10),
              _FormField(
                label: 'Contact Number',
                controller: _contactCtrl,
                icon: Icons.phone_outlined,
                hint: 'e.g. 09XX-XXX-XXXX',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Email Address',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                hint: 'e.g. brgy@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Population',
                controller: _populationCtrl,
                icon: Icons.people_outline_rounded,
                hint: 'Estimated number of residents',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // ── Icon & Color ─────────────────────────────────────────────
              const _SectionLabel(label: 'Icon & Color'),
              const SizedBox(height: 10),
              _IconColorPicker(
                selectedIconKey: _selectedIconKey,
                selectedColorIndex: _selectedColorIndex,
                onIconSelected:  (k) => setState(() => _selectedIconKey = k),
                onColorSelected: (i) => setState(() => _selectedColorIndex = i),
              ),
              const SizedBox(height: 20),

              // ── Notes ───────────────────────────────────────────────────
              const _SectionLabel(label: 'Notes (Optional)'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  style: const TextStyle(fontSize: 13, color: _kText),
                  decoration: const InputDecoration(
                    hintText: 'Additional notes about this barangay…',
                    hintStyle: TextStyle(color: _kText3, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                    counterStyle: TextStyle(color: _kText3, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Save Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: Text(
                    _saving ? 'Saving…' : 'Create Barangay',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

// ══════════════════════════════════════════════════════════════════════════════
//  EDIT BARANGAY PAGE
// ══════════════════════════════════════════════════════════════════════════════
class _EditBarangayPage extends StatefulWidget {
  final _Barangay barangay;
  const _EditBarangayPage({required this.barangay});

  @override
  State<_EditBarangayPage> createState() => _EditBarangayPageState();
}

class _EditBarangayPageState extends State<_EditBarangayPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _captainCtrl;
  late final TextEditingController _zoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _populationCtrl;
  late final TextEditingController _notesCtrl;
  late String _selectedIconKey;
  late int    _selectedColorIndex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.barangay;
    _nameCtrl       = TextEditingController(text: b.name);
    _captainCtrl    = TextEditingController(text: b.captain     ?? '');
    _zoneCtrl       = TextEditingController(text: b.zone        ?? '');
    _addressCtrl    = TextEditingController(text: b.address     ?? '');
    _contactCtrl    = TextEditingController(text: b.contactNo   ?? '');
    _emailCtrl      = TextEditingController(text: b.email       ?? '');
    _populationCtrl = TextEditingController(text: b.population?.toString() ?? '');
    _notesCtrl      = TextEditingController(text: b.notes       ?? '');
    _selectedIconKey    = b.iconKey ?? 'location';
    _selectedColorIndex = _findColorIndex(b.colorHex);
  }

  int _findColorIndex(String? hex) {
    if (hex == null) return 0;
    try {
      final c   = Color(int.parse(hex.replaceFirst('#', '0xFF')));
      final idx = _kColorOptions.indexOf(c);
      return idx >= 0 ? idx : 0;
    } catch (_) { return 0; }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _captainCtrl.dispose();
    _zoneCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _populationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _sb.from('barangays').update({
        'name':        _nameCtrl.text.trim(),
        'captain':     _captainCtrl.text.trim().isEmpty ? null : _captainCtrl.text.trim(),
        'zone':        _zoneCtrl.text.trim().isEmpty    ? null : _zoneCtrl.text.trim(),
        'address':     _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        'contact_no':  _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
        'email':       _emailCtrl.text.trim().isEmpty   ? null : _emailCtrl.text.trim(),
        'population':  _populationCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_populationCtrl.text.trim()),
        'notes':       _notesCtrl.text.trim().isEmpty   ? null : _notesCtrl.text.trim(),
        'icon_key':    _selectedIconKey,
        'color_hex':   _colorToHex(_kColorOptions[_selectedColorIndex]),
        'updated_at':  DateTime.now().toIso8601String(),
      }).eq('id', widget.barangay.id);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // back to list
      }
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
        title: const Text(
          'Edit Barangay',
          style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(label: 'Basic Information'),
              const SizedBox(height: 10),
              _FormField(
                label: 'Barangay Name',
                controller: _nameCtrl,
                icon: Icons.location_on_outlined,
                hint: 'e.g. Brgy. Batasan Hills',
                required: true,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Barangay Captain',
                controller: _captainCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'e.g. Juan Dela Cruz',
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Zone / District',
                controller: _zoneCtrl,
                icon: Icons.map_outlined,
                hint: 'e.g. Zone 1, North District',
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Address',
                controller: _addressCtrl,
                icon: Icons.home_outlined,
                hint: 'Full address of barangay hall',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              const _SectionLabel(label: 'Contact Information'),
              const SizedBox(height: 10),
              _FormField(
                label: 'Contact Number',
                controller: _contactCtrl,
                icon: Icons.phone_outlined,
                hint: 'e.g. 09XX-XXX-XXXX',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Email Address',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                hint: 'e.g. brgy@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _FormField(
                label: 'Population',
                controller: _populationCtrl,
                icon: Icons.people_outline_rounded,
                hint: 'Estimated number of residents',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              const _SectionLabel(label: 'Icon & Color'),
              const SizedBox(height: 10),
              _IconColorPicker(
                selectedIconKey: _selectedIconKey,
                selectedColorIndex: _selectedColorIndex,
                onIconSelected:  (k) => setState(() => _selectedIconKey = k),
                onColorSelected: (i) => setState(() => _selectedColorIndex = i),
              ),
              const SizedBox(height: 20),

              const _SectionLabel(label: 'Notes (Optional)'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  maxLength: 300,
                  style: const TextStyle(fontSize: 13, color: _kText),
                  decoration: const InputDecoration(
                    hintText: 'Additional notes about this barangay…',
                    hintStyle: TextStyle(color: _kText3, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                    counterStyle: TextStyle(color: _kText3, fontSize: 11),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    _saving ? 'Saving…' : 'Save Changes',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ─── Stat Pill ─────────────────────────────────────────────────────────────────
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

// ─── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? _kGreenBg : _kGrayBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? _kGreenBorder : _kGrayBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline_rounded : Icons.do_not_disturb_rounded,
            size: 10,
            color: isActive ? _kGreen : _kGray,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: isActive ? _kGreen : _kGray),
          ),
        ],
      ),
    );
  }
}

// ─── Population Badge ──────────────────────────────────────────────────────────
class _PopulationBadge extends StatelessWidget {
  final int population;
  const _PopulationBadge({required this.population});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _kBlueBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBlueBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline_rounded, size: 10, color: _kBlue),
          const SizedBox(width: 4),
          Text(
            '$population',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _kBlue),
          ),
        ],
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: _kText3),
        const SizedBox(width: 3),
        Flexible(
          child: Text(text, style: TextStyle(fontSize: size, color: _kText3), overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ─── Quick Button ──────────────────────────────────────────────────────────────
class _QuickBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;
  const _QuickBtn({required this.label, required this.icon, required this.color, required this.onTap, this.filled = false});

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

// ─── Pill Button ───────────────────────────────────────────────────────────────
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

// ─── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(color: _kAccent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _kText)),
      ],
    );
  }
}

// ─── Detail Card ───────────────────────────────────────────────────────────────
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

// ─── Detail Info Row ───────────────────────────────────────────────────────────
class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailInfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _kText3),
          const SizedBox(width: 8),
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12, color: _kText3, fontWeight: FontWeight.w600))),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 12, color: _kText2, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ─── Divider ───────────────────────────────────────────────────────────────────
class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: _kBorder);
}

// ─── Form Field ────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
            if (required) const Text(' *', style: TextStyle(color: _kRed, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: _kText),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
              : null,
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

// ─── Icon & Color Picker ───────────────────────────────────────────────────────
class _IconColorPicker extends StatelessWidget {
  final String selectedIconKey;
  final int selectedColorIndex;
  final void Function(String) onIconSelected;
  final void Function(int) onColorSelected;

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
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
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
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: active ? activeColor : _kBorder, width: active ? 1.5 : 1),
                  ),
                  child: Icon(opt.icon, size: 20, color: active ? activeColor : _kText3),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // Color row
          Row(
            children: _kColorOptions.map((color) {
              final active = color == activeColor;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onColorSelected(_kColorOptions.indexOf(color)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? _kText : Colors.transparent, width: 3),
                    ),
                    child: active ? const Icon(Icons.check_rounded, size: 13, color: Colors.white) : null,
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
            decoration: BoxDecoration(color: _kAccentBg, shape: BoxShape.circle, border: Border.all(color: _kAccentBorder)),
            child: const Icon(Icons.location_city_outlined, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('No barangays found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
          const SizedBox(height: 5),
          Text(
            filter == 'all' ? 'No barangays added yet.\nTap "Add" to create one.' : 'No $filter barangays found.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Dialog ────────────────────────────────────────────────────────────
Future<bool?> _confirm(BuildContext context, String title, String body) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(body, style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: _kText3)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm', style: TextStyle(color: _kRed, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}