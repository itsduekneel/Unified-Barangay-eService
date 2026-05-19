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
const _kOrange       = Color(0xFFEA580C);
const _kOrangeBg     = Color(0xFFFFF7ED);
const _kOrangeBorder = Color(0xFFFDBA74);
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

// ─── Activity Categories ───────────────────────────────────────────────────────
enum _ActivityCategory {
  all,
  health,
  environment,
  community,
  livelihood,
  peace,
  infrastructure,
  other,
}

extension _ActivityCategoryExt on _ActivityCategory {
  String get label => switch (this) {
    _ActivityCategory.all            => 'All',
    _ActivityCategory.health         => 'Health',
    _ActivityCategory.environment    => 'Environment',
    _ActivityCategory.community      => 'Community',
    _ActivityCategory.livelihood     => 'Livelihood',
    _ActivityCategory.peace          => 'Peace & Order',
    _ActivityCategory.infrastructure => 'Infrastructure',
    _ActivityCategory.other          => 'Other',
  };

  String get dbKey => switch (this) {
    _ActivityCategory.all            => 'all',
    _ActivityCategory.health         => 'health',
    _ActivityCategory.environment    => 'environment',
    _ActivityCategory.community      => 'community',
    _ActivityCategory.livelihood     => 'livelihood',
    _ActivityCategory.peace          => 'peace',
    _ActivityCategory.infrastructure => 'infrastructure',
    _ActivityCategory.other          => 'other',
  };

  IconData get icon => switch (this) {
    _ActivityCategory.all            => Icons.grid_view_rounded,
    _ActivityCategory.health         => Icons.favorite_border_rounded,
    _ActivityCategory.environment    => Icons.park_outlined,
    _ActivityCategory.community      => Icons.people_outline_rounded,
    _ActivityCategory.livelihood     => Icons.work_outline_rounded,
    _ActivityCategory.peace          => Icons.shield_outlined,
    _ActivityCategory.infrastructure => Icons.construction_outlined,
    _ActivityCategory.other          => Icons.more_horiz_rounded,
  };

  Color get color => switch (this) {
    _ActivityCategory.all            => _kAccent,
    _ActivityCategory.health         => const Color(0xFFDB2777),
    _ActivityCategory.environment    => _kGreen,
    _ActivityCategory.community      => _kAccent,
    _ActivityCategory.livelihood     => _kOrange,
    _ActivityCategory.peace          => _kBlue,
    _ActivityCategory.infrastructure => const Color(0xFF0891B2),
    _ActivityCategory.other          => _kGray,
  };

  Color get bgColor => switch (this) {
    _ActivityCategory.all            => _kAccentBg,
    _ActivityCategory.health         => const Color(0xFFFDF2F8),
    _ActivityCategory.environment    => _kGreenBg,
    _ActivityCategory.community      => _kAccentBg,
    _ActivityCategory.livelihood     => _kOrangeBg,
    _ActivityCategory.peace          => _kBlueBg,
    _ActivityCategory.infrastructure => const Color(0xFFECFEFF),
    _ActivityCategory.other          => _kGrayBg,
  };

  Color get borderColor => switch (this) {
    _ActivityCategory.all            => _kAccentBorder,
    _ActivityCategory.health         => const Color(0xFFFBCFE8),
    _ActivityCategory.environment    => _kGreenBorder,
    _ActivityCategory.community      => _kAccentBorder,
    _ActivityCategory.livelihood     => _kOrangeBorder,
    _ActivityCategory.peace          => _kBlueBorder,
    _ActivityCategory.infrastructure => const Color(0xFFA5F3FC),
    _ActivityCategory.other          => _kGrayBorder,
  };
}

// ─── Activity Status ───────────────────────────────────────────────────────────
enum _ActivityStatus { upcoming, ongoing, completed, cancelled }

extension _ActivityStatusExt on _ActivityStatus {
  String get label => switch (this) {
    _ActivityStatus.upcoming  => 'Upcoming',
    _ActivityStatus.ongoing   => 'Ongoing',
    _ActivityStatus.completed => 'Completed',
    _ActivityStatus.cancelled => 'Cancelled',
  };

  String get dbKey => switch (this) {
    _ActivityStatus.upcoming  => 'upcoming',
    _ActivityStatus.ongoing   => 'ongoing',
    _ActivityStatus.completed => 'completed',
    _ActivityStatus.cancelled => 'cancelled',
  };

  Color get color => switch (this) {
    _ActivityStatus.upcoming  => _kBlue,
    _ActivityStatus.ongoing   => _kGreen,
    _ActivityStatus.completed => _kGray,
    _ActivityStatus.cancelled => _kRed,
  };

  Color get bgColor => switch (this) {
    _ActivityStatus.upcoming  => _kBlueBg,
    _ActivityStatus.ongoing   => _kGreenBg,
    _ActivityStatus.completed => _kGrayBg,
    _ActivityStatus.cancelled => _kRedBg,
  };

  Color get borderColor => switch (this) {
    _ActivityStatus.upcoming  => _kBlueBorder,
    _ActivityStatus.ongoing   => _kGreenBorder,
    _ActivityStatus.completed => _kGrayBorder,
    _ActivityStatus.cancelled => _kRedBorder,
  };

  IconData get icon => switch (this) {
    _ActivityStatus.upcoming  => Icons.schedule_rounded,
    _ActivityStatus.ongoing   => Icons.play_circle_outline_rounded,
    _ActivityStatus.completed => Icons.check_circle_outline_rounded,
    _ActivityStatus.cancelled => Icons.cancel_outlined,
  };
}

_ActivityStatus _statusFromStr(String? s) => switch (s) {
  'ongoing'   => _ActivityStatus.ongoing,
  'completed' => _ActivityStatus.completed,
  'cancelled' => _ActivityStatus.cancelled,
  _           => _ActivityStatus.upcoming,
};

_ActivityCategory _categoryFromStr(String? s) => switch (s) {
  'health'         => _ActivityCategory.health,
  'environment'    => _ActivityCategory.environment,
  'community'      => _ActivityCategory.community,
  'livelihood'     => _ActivityCategory.livelihood,
  'peace'          => _ActivityCategory.peace,
  'infrastructure' => _ActivityCategory.infrastructure,
  _                => _ActivityCategory.other,
};

// ─── Activity Model ────────────────────────────────────────────────────────────
class _Activity {
  final String            id;
  final String            title;
  final String?           description;
  final String?           location;
  final String?           organizer;
  final DateTime?         startDate;
  final DateTime?         endDate;
  final _ActivityStatus   status;
  final _ActivityCategory category;
  final String?           barangayId;
  final String?           barangayName;
  final int?              targetParticipants;
  final int?              actualParticipants;
  final String?           budget;
  final String?           notes;
  final String            createdAt;
  final String?           updatedAt;

  const _Activity({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.organizer,
    this.startDate,
    this.endDate,
    required this.status,
    required this.category,
    this.barangayId,
    this.barangayName,
    this.targetParticipants,
    this.actualParticipants,
    this.budget,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory _Activity.fromMap(Map<String, dynamic> m) {
    final brgy = m['barangays'] as Map<String, dynamic>?;
    return _Activity(
      id:                 m['id'].toString(),
      title:              m['title'] ?? '',
      description:        m['description'],
      location:           m['location'],
      organizer:          m['organizer'],
      startDate:          m['start_date'] != null ? DateTime.tryParse(m['start_date']) : null,
      endDate:            m['end_date']   != null ? DateTime.tryParse(m['end_date'])   : null,
      status:             _statusFromStr(m['status']),
      category:           _categoryFromStr(m['category']),
      barangayId:         m['barangay_id']?.toString(),
      barangayName:       brgy?['name'] as String?,
      targetParticipants: m['target_participants'] is int ? m['target_participants'] : null,
      actualParticipants: m['actual_participants'] is int ? m['actual_participants'] : null,
      budget:             m['budget'],
      notes:              m['notes'],
      createdAt:          m['created_at'] != null
          ? DateFormat('MMM dd, hh:mm a').format(DateTime.parse(m['created_at']))
          : '',
      updatedAt: m['updated_at'] != null
          ? DateFormat('MMM dd, yyyy').format(DateTime.parse(m['updated_at']))
          : null,
    );
  }

  String get formattedDate {
    if (startDate == null) return '—';
    final fmt = DateFormat('MMM d, yyyy');
    if (endDate != null && !_isSameDay(startDate!, endDate!)) {
      return '${fmt.format(startDate!)} – ${fmt.format(endDate!)}';
    }
    return fmt.format(startDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ══════════════════════════════════════════════════════════════════════════════
//  BARANGAY ACTIVITIES PAGE  (list)
// ══════════════════════════════════════════════════════════════════════════════
class BarangayActivitiesPage extends StatefulWidget {
  const BarangayActivitiesPage({super.key});

  @override
  State<BarangayActivitiesPage> createState() => _BarangayActivitiesPageState();
}

class _BarangayActivitiesPageState extends State<BarangayActivitiesPage>
    with SingleTickerProviderStateMixin {
  String            _search      = '';
  _ActivityCategory _selCategory = _ActivityCategory.all;
  String?           _selBarangayId;
  final _searchCtrl = TextEditingController();

  late TabController _tabCtrl;
  final _statusTabs = ['all', 'upcoming', 'ongoing', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _statusTabs.length, vsync: this);
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

  String get _filterStatus => _statusTabs[_tabCtrl.index];

  List<_Activity> _filter(List<_Activity> all) {
    return all.where((a) {
      final matchStatus = _filterStatus == 'all' || a.status.dbKey == _filterStatus;
      final matchCat    = _selCategory == _ActivityCategory.all || a.category == _selCategory;
      final matchBrgy   = _selBarangayId == null || a.barangayId == _selBarangayId;
      final q           = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          (a.description?.toLowerCase().contains(q) ?? false) ||
          (a.location?.toLowerCase().contains(q) ?? false) ||
          (a.organizer?.toLowerCase().contains(q) ?? false) ||
          (a.barangayName?.toLowerCase().contains(q) ?? false);
      return matchStatus && matchCat && matchBrgy && matchSearch;
    }).toList()
      ..sort((a, b) {
        if (a.startDate == null && b.startDate == null) return 0;
        if (a.startDate == null) return 1;
        if (b.startDate == null) return -1;
        return b.startDate!.compareTo(a.startDate!);
      });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _sb
          .from('barangay_activities')
          .stream(primaryKey: ['id'])
          .order('start_date', ascending: false),
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
              enriched['barangays'] = {'name': brgyMap[m['barangay_id']?.toString()]};
              return _Activity.fromMap(enriched);
            }).toList();

            final filtered = _filter(all);

            final counts = {
              'all':       all.length,
              'upcoming':  all.where((a) => a.status == _ActivityStatus.upcoming).length,
              'ongoing':   all.where((a) => a.status == _ActivityStatus.ongoing).length,
              'completed': all.where((a) => a.status == _ActivityStatus.completed).length,
              'cancelled': all.where((a) => a.status == _ActivityStatus.cancelled).length,
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
                  'Barangay Activities',
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
                        instantRoute(const _CreateActivityPage()),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  // ── Summary pills ──────────────────────────────────────
                  _buildSummary(counts),

                  // ── Search + barangay filter ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
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
                                hintText: 'Search activities…',
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
                        const SizedBox(width: 8),
                        _FilterIconBtn(
                          icon: Icons.location_on_outlined,
                          active: _selBarangayId != null,
                          onTap: () => _showBarangayFilter(brgyMap),
                        ),
                      ],
                    ),
                  ),

                  // ── Category chips ─────────────────────────────────────
                  _buildCategoryChips(),

                  // ── Status tabs ────────────────────────────────────────
                  _buildTabs(counts),

                  // ── List ───────────────────────────────────────────────
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData
                        ? const Center(child: CircularProgressIndicator(color: _kAccent))
                        : filtered.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _ActivityCard(
                        activity: filtered[i],
                        onTap: () => Navigator.push(
                          context,
                          instantRoute(_ActivityDetailPage(activity: filtered[i])),
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
          _StatPill('${counts['upcoming']}',  'Upcoming',  _kBlue,   _kBlueBg,   _kBlueBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['ongoing']}',   'Ongoing',   _kGreen,  _kGreenBg,  _kGreenBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['completed']}', 'Done',      _kGray,   _kGrayBg,   _kGrayBorder),
          const SizedBox(width: 8),
          _StatPill('${counts['all']}',       'Total',     _kAccent, _kAccentBg, _kAccentBorder),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: _ActivityCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final cat      = _ActivityCategory.values[i];
          final selected = _selCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? cat.color : _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? cat.color : _kBorder, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 12, color: selected ? Colors.white : _kText3),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _kText3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs(Map<String, int> counts) {
    const labels = ['All', 'Upcoming', 'Ongoing', 'Done', 'Cancelled'];
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

  void _showBarangayFilter(Map<String, String> brgyMap) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: _kSurface,
      builder: (_) => _BarangayFilterSheet(
        brgyMap: brgyMap,
        selectedId: _selBarangayId,
        onSelected: (id) {
          setState(() => _selBarangayId = id);
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
            Text(count,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Activity Card (mirrors _ApptCard) ────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final _Activity    activity;
  final VoidCallback onTap;

  const _ActivityCard({required this.activity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat    = activity.category;
    final status = activity.status;

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
                  // Icon container
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
                        // Title
                        Text(
                          activity.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: _kText),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        // Category label
                        Text(
                          cat.label,
                          style: const TextStyle(fontSize: 11, color: _kText3),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        // Meta row 1 — organizer + barangay
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            if (activity.organizer != null && activity.organizer!.isNotEmpty)
                              _IconText(Icons.person_outline_rounded, activity.organizer!, 11),
                            if (activity.barangayName != null && activity.barangayName!.isNotEmpty)
                              _IconText(Icons.location_on_outlined, activity.barangayName!, 11),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Meta row 2 — date + location
                        Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children: [
                            _IconText(Icons.calendar_today_rounded, activity.formattedDate, 11),
                            if (activity.location != null && activity.location!.isNotEmpty)
                              _IconText(Icons.place_outlined, activity.location!, 11),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Status badge
                        _ActivityStatusBadge(status: status),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Participants bar (if available)
            if (activity.targetParticipants != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: _ParticipantsBar(
                  actual: activity.actualParticipants ?? 0,
                  target: activity.targetParticipants!,
                  color: cat.color,
                ),
              ),
            ],

            const Divider(height: 1, color: _kBorder),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  Text(activity.createdAt,
                      style: const TextStyle(fontSize: 9, color: _kText3)),
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

// ─── Activity Status Badge ────────────────────────────────────────────────────
class _ActivityStatusBadge extends StatelessWidget {
  final _ActivityStatus status;
  const _ActivityStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 10, color: status.color),
          const SizedBox(width: 4),
          Text(status.label,
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, color: status.color)),
        ],
      ),
    );
  }
}

// ─── Quick Action ─────────────────────────────────────────────────────────────
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
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: filled ? Colors.white : color)),
          ],
        ),
      ),
    );
  }
}

// ─── Participants Progress Bar ─────────────────────────────────────────────────
class _ParticipantsBar extends StatelessWidget {
  final int actual, target;
  final Color color;
  const _ParticipantsBar({required this.actual, required this.target, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = target > 0 ? (actual / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.people_outline_rounded, size: 11, color: _kText3),
              const SizedBox(width: 4),
              const Text('Participants',
                  style: TextStyle(fontSize: 10, color: _kText3, fontWeight: FontWeight.w600)),
            ]),
            Text('$actual / $target',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: _kGrayBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            child: const Icon(Icons.event_busy_rounded, color: _kAccent, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('No activities found',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
          const SizedBox(height: 5),
          const Text(
            'No activities match your filters.\nTap "New" to create one.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _kText3, height: 1.6),
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
            Text(label,
                style: const TextStyle(
                    color: _kAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Icon Button ───────────────────────────────────────────────────────
class _FilterIconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _FilterIconBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? _kAccentBg : _kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? _kAccent : _kBorder, width: active ? 1.5 : 1),
        ),
        child: Icon(icon, size: 18, color: active ? _kAccent : _kText3),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ACTIVITY DETAIL PAGE  (mirrors _ApptDetailPage)
// ══════════════════════════════════════════════════════════════════════════════
class _ActivityDetailPage extends StatefulWidget {
  final _Activity activity;
  const _ActivityDetailPage({required this.activity});

  @override
  State<_ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<_ActivityDetailPage> {
  late _ActivityStatus _status;
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.activity.status;
    _notesCtrl.text = widget.activity.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _sb.from('barangay_activities').update({
      'status':     _status.dbKey,
      'notes':      _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', widget.activity.id);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await _confirm(
        context, 'Delete "${widget.activity.title}"?', 'This action cannot be undone.');
    if (confirmed != true) return;
    await _sb.from('barangay_activities').delete().eq('id', widget.activity.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final a      = widget.activity;
    final cat    = a.category;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _kAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Activity Detail',
            style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
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

            // ── Header card ────────────────────────────────────────────
            _DetailCard(
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
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
                        Text(a.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700, color: _kText)),
                        if (a.barangayName != null && a.barangayName!.isNotEmpty)
                          Text(a.barangayName!,
                              style: const TextStyle(fontSize: 11, color: _kText3),
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _status.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _status.borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_status.icon, size: 11, color: _status.color),
                        const SizedBox(width: 4),
                        Text(_status.label,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _status.color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Schedule info ──────────────────────────────────────────
            const _SectionLabel(label: 'Schedule Info'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(Icons.calendar_today_rounded, 'Date',      a.formattedDate),
                  _DividerLine(),
                  _DetailRow(Icons.place_outlined,         'Location',  a.location ?? '—'),
                  _DividerLine(),
                  _DetailRow(Icons.person_outline_rounded, 'Organizer', a.organizer ?? '—'),
                  _DividerLine(),
                  _DetailRow(Icons.category_outlined,      'Category',  cat.label),
                  _DividerLine(),
                  _DetailRow(Icons.calendar_today_rounded, 'Filed',     a.createdAt),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Participants ───────────────────────────────────────────
            const _SectionLabel(label: 'Participants'),
            const SizedBox(height: 8),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(Icons.people_outline_rounded, 'Target',
                      a.targetParticipants != null ? '${a.targetParticipants}' : '—'),
                  _DividerLine(),
                  _DetailRow(Icons.how_to_reg_outlined, 'Actual',
                      a.actualParticipants != null ? '${a.actualParticipants}' : '—'),
                  if (a.targetParticipants != null && a.actualParticipants != null) ...[
                    _DividerLine(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _ParticipantsBar(
                        actual: a.actualParticipants!,
                        target: a.targetParticipants!,
                        color: cat.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Budget ─────────────────────────────────────────────────
            if (a.budget != null && a.budget!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const _SectionLabel(label: 'Budget'),
              const SizedBox(height: 8),
              _DetailCard(
                child: _DetailRow(Icons.payments_outlined, 'Budget', a.budget!),
              ),
            ],

            // ── Description ────────────────────────────────────────────
            if (a.description != null && a.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const _SectionLabel(label: 'Description'),
              const SizedBox(height: 8),
              _DetailCard(
                child: Text(a.description!,
                    style: const TextStyle(fontSize: 13, color: _kText2, height: 1.6)),
              ),
            ],

            // ── Update Status ──────────────────────────────────────────
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
              children: _ActivityStatus.values.map((s) {
                final active = _status == s;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: active ? s.bgColor : _kSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: active ? s.borderColor : _kBorder,
                          width: active ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 14, color: active ? s.color : _kText3),
                        const SizedBox(width: 6),
                        Text(s.label,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                                color: active ? s.color : _kText3)),
                        if (active) ...[
                          const SizedBox(width: 5),
                          Icon(Icons.check_circle_rounded, size: 11, color: s.color),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Admin Notes ────────────────────────────────────────────
            const SizedBox(height: 18),
            const _SectionLabel(label: 'Admin Notes'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder)),
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
            const SizedBox(height: 14),

            // ── Edit button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  instantRoute(_EditActivityPage(activity: a)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16, color: _kAccent),
                label: const Text('Edit Activity',
                    style: TextStyle(
                        fontSize: 13, color: _kAccent, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: _kAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Save button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  disabledBackgroundColor: _kAccent.withOpacity(0.45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CREATE ACTIVITY PAGE
// ══════════════════════════════════════════════════════════════════════════════
class _CreateActivityPage extends StatefulWidget {
  const _CreateActivityPage();

  @override
  State<_CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends State<_CreateActivityPage> {
  final _formKey       = GlobalKey<FormState>();
  final _titleCtrl     = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _locationCtrl  = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _budgetCtrl    = TextEditingController();
  final _targetCtrl    = TextEditingController();
  final _notesCtrl     = TextEditingController();

  DateTime?          _startDate;
  DateTime?          _endDate;
  _ActivityCategory  _category  = _ActivityCategory.community;
  _ActivityStatus    _status    = _ActivityStatus.upcoming;
  String?            _barangayId;
  bool               _saving    = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    _budgetCtrl.dispose();
    _targetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now    = DateTime.now();
    final init   = isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate:  DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kAccent)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _sb.from('barangay_activities').insert({
        'title':               _titleCtrl.text.trim(),
        'description':         _descCtrl.text.trim().isEmpty     ? null : _descCtrl.text.trim(),
        'location':            _locationCtrl.text.trim().isEmpty  ? null : _locationCtrl.text.trim(),
        'organizer':           _organizerCtrl.text.trim().isEmpty ? null : _organizerCtrl.text.trim(),
        'budget':              _budgetCtrl.text.trim().isEmpty    ? null : _budgetCtrl.text.trim(),
        'target_participants': _targetCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_targetCtrl.text.trim()),
        'notes':               _notesCtrl.text.trim().isEmpty     ? null : _notesCtrl.text.trim(),
        'start_date':          _startDate?.toIso8601String(),
        'end_date':            _endDate?.toIso8601String(),
        'category':            _category.dbKey,
        'status':              _status.dbKey,
        'barangay_id':         _barangayId,
        'created_at':          DateTime.now().toIso8601String(),
        'updated_at':          DateTime.now().toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed));
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
        title: const Text('New Activity',
            style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Basic Info ─────────────────────────────────────────
              const _SectionLabel(label: 'Basic Information'),
              const SizedBox(height: 10),
              _AdminFormField(
                label: 'Activity Title',
                controller: _titleCtrl,
                icon: Icons.event_note_rounded,
                hint: 'e.g. Barangay Health Mission',
                required: true,
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Description',
                controller: _descCtrl,
                icon: Icons.description_outlined,
                hint: 'Brief description of the activity…',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Organizer / In-charge',
                controller: _organizerCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'e.g. Barangay Health Committee',
              ),
              const SizedBox(height: 20),

              // ── Category & Status ──────────────────────────────────
              const _SectionLabel(label: 'Category & Status'),
              const SizedBox(height: 10),
              _CategoryStatusPicker(
                selectedCategory:  _category,
                selectedStatus:    _status,
                onCategoryChanged: (c) => setState(() => _category = c),
                onStatusChanged:   (s) => setState(() => _status   = s),
              ),
              const SizedBox(height: 20),

              // ── Schedule ───────────────────────────────────────────
              const _SectionLabel(label: 'Schedule'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerBtn(
                        label: 'Start Date', date: _startDate,
                        onTap: () => _pickDate(true)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DatePickerBtn(
                        label: 'End Date', date: _endDate,
                        onTap: () => _pickDate(false)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Location / Venue',
                controller: _locationCtrl,
                icon: Icons.place_outlined,
                hint: 'e.g. Barangay Hall, Main Street',
              ),
              const SizedBox(height: 20),

              // ── Barangay ───────────────────────────────────────────
              const _SectionLabel(label: 'Barangay'),
              const SizedBox(height: 10),
              _BarangayDropdown(
                selectedId: _barangayId,
                onChanged:  (id) => setState(() => _barangayId = id),
              ),
              const SizedBox(height: 20),

              // ── Participants & Budget ──────────────────────────────
              const _SectionLabel(label: 'Participants & Budget'),
              const SizedBox(height: 10),
              _AdminFormField(
                label: 'Target Participants',
                controller: _targetCtrl,
                icon: Icons.people_outline_rounded,
                hint: 'Expected number of attendees',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                label: 'Budget',
                controller: _budgetCtrl,
                icon: Icons.payments_outlined,
                hint: 'e.g. ₱10,000.00',
              ),
              const SizedBox(height: 20),

              // ── Notes ──────────────────────────────────────────────
              const _SectionLabel(label: 'Notes (Optional)'),
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
                  maxLength: 400,
                  style: const TextStyle(fontSize: 13, color: _kText),
                  decoration: const InputDecoration(
                    hintText: 'Additional notes…',
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text('Create Activity',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
//  EDIT ACTIVITY PAGE
// ══════════════════════════════════════════════════════════════════════════════
class _EditActivityPage extends StatefulWidget {
  final _Activity activity;
  const _EditActivityPage({required this.activity});

  @override
  State<_EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<_EditActivityPage> {
  final _formKey       = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _organizerCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _notesCtrl;

  late DateTime?          _startDate;
  late DateTime?          _endDate;
  late _ActivityCategory  _category;
  late _ActivityStatus    _status;
  late String?            _barangayId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a        = widget.activity;
    _titleCtrl     = TextEditingController(text: a.title);
    _descCtrl      = TextEditingController(text: a.description ?? '');
    _locationCtrl  = TextEditingController(text: a.location ?? '');
    _organizerCtrl = TextEditingController(text: a.organizer ?? '');
    _budgetCtrl    = TextEditingController(text: a.budget ?? '');
    _targetCtrl    = TextEditingController(
        text: a.targetParticipants != null ? '${a.targetParticipants}' : '');
    _notesCtrl     = TextEditingController(text: a.notes ?? '');
    _startDate     = a.startDate;
    _endDate       = a.endDate;
    _category      = a.category;
    _status        = a.status;
    _barangayId    = a.barangayId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    _budgetCtrl.dispose();
    _targetCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now    = DateTime.now();
    final init   = isStart ? (_startDate ?? now) : (_endDate ?? _startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020),
      lastDate:  DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kAccent)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) _endDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _sb.from('barangay_activities').update({
        'title':               _titleCtrl.text.trim(),
        'description':         _descCtrl.text.trim().isEmpty     ? null : _descCtrl.text.trim(),
        'location':            _locationCtrl.text.trim().isEmpty  ? null : _locationCtrl.text.trim(),
        'organizer':           _organizerCtrl.text.trim().isEmpty ? null : _organizerCtrl.text.trim(),
        'budget':              _budgetCtrl.text.trim().isEmpty    ? null : _budgetCtrl.text.trim(),
        'target_participants': _targetCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_targetCtrl.text.trim()),
        'notes':               _notesCtrl.text.trim().isEmpty     ? null : _notesCtrl.text.trim(),
        'start_date':          _startDate?.toIso8601String(),
        'end_date':            _endDate?.toIso8601String(),
        'category':            _category.dbKey,
        'status':              _status.dbKey,
        'barangay_id':         _barangayId,
        'updated_at':          DateTime.now().toIso8601String(),
      }).eq('id', widget.activity.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _kRed));
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
        title: const Text('Edit Activity',
            style: TextStyle(color: _kText, fontWeight: FontWeight.bold, fontSize: 15)),
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
              _AdminFormField(
                  label: 'Activity Title', controller: _titleCtrl,
                  icon: Icons.event_note_rounded,
                  hint: 'e.g. Barangay Health Mission', required: true),
              const SizedBox(height: 12),
              _AdminFormField(
                  label: 'Description', controller: _descCtrl,
                  icon: Icons.description_outlined,
                  hint: 'Brief description…', maxLines: 3),
              const SizedBox(height: 12),
              _AdminFormField(
                  label: 'Organizer / In-charge', controller: _organizerCtrl,
                  icon: Icons.person_outline_rounded,
                  hint: 'e.g. Barangay Health Committee'),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Category & Status'),
              const SizedBox(height: 10),
              _CategoryStatusPicker(
                selectedCategory:  _category,
                selectedStatus:    _status,
                onCategoryChanged: (c) => setState(() => _category = c),
                onStatusChanged:   (s) => setState(() => _status   = s),
              ),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Schedule'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _DatePickerBtn(
                      label: 'Start Date', date: _startDate,
                      onTap: () => _pickDate(true))),
                  const SizedBox(width: 10),
                  Expanded(child: _DatePickerBtn(
                      label: 'End Date', date: _endDate,
                      onTap: () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 12),
              _AdminFormField(
                  label: 'Location / Venue', controller: _locationCtrl,
                  icon: Icons.place_outlined,
                  hint: 'e.g. Barangay Hall'),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Barangay'),
              const SizedBox(height: 10),
              _BarangayDropdown(
                  selectedId: _barangayId,
                  onChanged: (id) => setState(() => _barangayId = id)),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Participants & Budget'),
              const SizedBox(height: 10),
              _AdminFormField(
                  label: 'Target Participants', controller: _targetCtrl,
                  icon: Icons.people_outline_rounded,
                  hint: 'Expected number of attendees',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _AdminFormField(
                  label: 'Budget', controller: _budgetCtrl,
                  icon: Icons.payments_outlined, hint: 'e.g. ₱10,000.00'),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Notes (Optional)'),
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
                    hintText: 'Additional notes…',
                    hintStyle: TextStyle(color: _kText3, fontSize: 13),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save Changes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
//  SHARED FORM WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ─── Admin Form Field (mirrors appointment's _AdminFormField) ──────────────────
class _AdminFormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool required;
  final int maxLines;
  final TextInputType keyboardType;

  const _AdminFormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.required     = false,
    this.maxLines     = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
              if (required)
                const Text(' *', style: TextStyle(color: _kRed, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
        ],
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
            contentPadding: EdgeInsets.symmetric(
                horizontal: 14, vertical: maxLines > 1 ? 14 : 13),
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

// ─── Category & Status Picker ──────────────────────────────────────────────────
class _CategoryStatusPicker extends StatelessWidget {
  final _ActivityCategory selectedCategory;
  final _ActivityStatus   selectedStatus;
  final void Function(_ActivityCategory) onCategoryChanged;
  final void Function(_ActivityStatus)   onStatusChanged;

  const _CategoryStatusPicker({
    required this.selectedCategory,
    required this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text('Category',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7, runSpacing: 7,
            children: _ActivityCategory.values
                .where((c) => c != _ActivityCategory.all)
                .map((c) {
              final active = c == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? c.color : c.bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? c.color : c.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 12, color: active ? Colors.white : c.color),
                      const SizedBox(width: 5),
                      Text(c.label,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: active ? Colors.white : c.color)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Status',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7, runSpacing: 7,
            children: _ActivityStatus.values.map((s) {
              final active = s == selectedStatus;
              return GestureDetector(
                onTap: () => onStatusChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? s.color : s.bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? s.color : s.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 12, color: active ? Colors.white : s.color),
                      const SizedBox(width: 5),
                      Text(s.label,
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: active ? Colors.white : s.color)),
                    ],
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

// ─── Date Picker Button ────────────────────────────────────────────────────────
class _DatePickerBtn extends StatelessWidget {
  final String    label;
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePickerBtn({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: hasDate ? _kAccent : _kBorder, width: hasDate ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: hasDate ? _kAccent : _kText3),
                const SizedBox(width: 8),
                Text(
                  hasDate ? DateFormat('MMM d, yyyy').format(date!) : 'Select date',
                  style: TextStyle(
                      fontSize: 12,
                      color: hasDate ? _kText : _kText3,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barangay Dropdown ────────────────────────────────────────────────────────
class _BarangayDropdown extends StatelessWidget {
  final String?             selectedId;
  final void Function(String?) onChanged;
  const _BarangayDropdown({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sb.from('barangays').select('id, name').eq('is_active', true),
      builder: (_, snap) {
        final items = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Barangay',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _kText2)),
            const SizedBox(height: 6),
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
                  value: selectedId,
                  hint: const Text('Select barangay',
                      style: TextStyle(color: _kText3, fontSize: 13)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _kText3, size: 20),
                  style: const TextStyle(fontSize: 13, color: _kText),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('— All Barangays —',
                            style: TextStyle(color: _kText3))),
                    ...items.map((b) => DropdownMenuItem<String>(
                        value: b['id'].toString(),
                        child: Text(b['name'] as String))),
                  ],
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Barangay Filter Bottom Sheet ─────────────────────────────────────────────
class _BarangayFilterSheet extends StatelessWidget {
  final Map<String, String> brgyMap;
  final String?             selectedId;
  final void Function(String?) onSelected;
  const _BarangayFilterSheet({
    required this.brgyMap,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = [null, ...brgyMap.keys];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
              child: SizedBox(width: 40, child: Divider(thickness: 3, color: _kBorder))),
          const SizedBox(height: 10),
          const Text('Filter by Barangay',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kText)),
          const SizedBox(height: 12),
          ...entries.map((id) {
            final label  = id == null ? 'All Barangays' : brgyMap[id]!;
            final active = selectedId == id;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                  id == null ? Icons.grid_view_rounded : Icons.location_on_outlined,
                  color: active ? _kAccent : _kText3, size: 18),
              title: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                      color: active ? _kAccent : _kText)),
              trailing: active
                  ? const Icon(Icons.check_rounded, color: _kAccent, size: 16)
                  : null,
              onTap: () => onSelected(id),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED COMPONENTS  (mirrors appointments)
// ══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3, height: 14,
            decoration:
            BoxDecoration(color: _kAccent, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kText)),
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
              offset: const Offset(0, 2))
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
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: _kText3, fontWeight: FontWeight.w600))),
          Expanded(
            child: Text(value.isEmpty ? '—' : value,
                style: const TextStyle(
                    fontSize: 12, color: _kText2, fontWeight: FontWeight.w500)),
          ),
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
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(body, style: const TextStyle(fontSize: 13)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _kText3))),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm',
                style: TextStyle(color: _kRed, fontWeight: FontWeight.bold))),
      ],
    ),
  );
}