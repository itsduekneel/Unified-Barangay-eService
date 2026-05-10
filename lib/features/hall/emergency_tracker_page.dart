import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ube/core/utils/route_utils.dart';

final supabase = Supabase.instance.client;

// ─── Theme ───────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFF5F4FA);
const _kSurface = Color(0xFFFFFFFF);
const _kSurface2 = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);
const _kAccent = Color(0xFF8B2CF5);
const _kAccent2 = Color(0xFF6B1BD4);
const _kText = Color(0xFF1E0447);
const _kText2 = Color(0xFF360C78);
const _kText3 = Color(0xFF6B7280);

const _kRed = Color(0xFFDC2626);
const _kRedBg = Color(0xFFFEF2F2);
const _kRedBorder = Color(0xFFFCA5A5);
const _kOrange = Color(0xFFEA580C);
const _kOrangeBg = Color(0xFFFFF7ED);
const _kOrangeBorder = Color(0xFFFDBA74);
const _kGreen = Color(0xFF16A34A);
const _kGreenBg = Color(0xFFF0FDF4);
const _kGreenBorder = Color(0xFF86EFAC);
const _kYellow = Color(0xFFD97706);
const _kYellowBg = Color(0xFFFFFBEB);
const _kAccentBg = Color(0xFFF5F0FF);
const _kAccentBorder = Color(0xFFEBE0FF);

// ─── OSM ─────────────────────────────────────────────────────────────────────
const _kOsmTile = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _kOsmCacheFolder = 'ube_osm_cache';

// ─── Default map center (Los Baños, Laguna) ───────────────────────────────────
const _kDefaultLat = 14.1668;
const _kDefaultLng = 121.2420;

// SharedPreferences keys for persisting last location
const _kPrefLastLat = 'last_loc_lat';
const _kPrefLastLng = 'last_loc_lng';

// ─── Category Color Presets ───────────────────────────────────────────────────
class _CatColorPreset {
  final String key;
  final Color fg;
  final Color bg;
  final Color border;
  const _CatColorPreset({
    required this.key,
    required this.fg,
    required this.bg,
    required this.border,
  });
}

const _colorPresets = [
  _CatColorPreset(key: 'red', fg: _kRed, bg: _kRedBg, border: _kRedBorder),
  _CatColorPreset(
    key: 'orange',
    fg: _kOrange,
    bg: _kOrangeBg,
    border: _kOrangeBorder,
  ),
  _CatColorPreset(
    key: 'yellow',
    fg: _kYellow,
    bg: _kYellowBg,
    border: Color(0xFFFDE68A),
  ),
  _CatColorPreset(
    key: 'blue',
    fg: Color(0xFF1D4ED8),
    bg: Color(0xFFEFF6FF),
    border: Color(0xFFBFDBFE),
  ),
  _CatColorPreset(
    key: 'green',
    fg: _kGreen,
    bg: _kGreenBg,
    border: _kGreenBorder,
  ),
  _CatColorPreset(
    key: 'purple',
    fg: _kAccent,
    bg: _kAccentBg,
    border: _kAccentBorder,
  ),
  _CatColorPreset(
    key: 'gray',
    fg: Color(0xFF4B5563),
    bg: Color(0xFFF9FAFB),
    border: Color(0xFFE5E7EB),
  ),
];

_CatColorPreset _presetByKey(String key) => _colorPresets.firstWhere(
  (p) => p.key == key,
  orElse: () => _colorPresets[0],
);

// ─── Icon Presets ─────────────────────────────────────────────────────────────
class _IconOption {
  final String label;
  final IconData icon;
  const _IconOption(this.label, this.icon);
}

const _iconOptions = [
  _IconOption('Medical', Icons.monitor_heart_outlined),
  _IconOption('Fire', Icons.local_fire_department_outlined),
  _IconOption('Flood', Icons.water_outlined),
  _IconOption('Break-in', Icons.lock_open_outlined),
  _IconOption('Car Crash', Icons.car_crash_outlined),
  _IconOption('Warning', Icons.warning_amber_outlined),
  _IconOption('Shield', Icons.shield_outlined),
  _IconOption('Phone', Icons.phone_outlined),
  _IconOption('Home', Icons.home_outlined),
  _IconOption('Storm', Icons.thunderstorm_outlined),
  _IconOption('Biohazard', Icons.biotech_outlined),
  _IconOption('Ambulance', Icons.local_hospital_outlined),
  _IconOption('Earthquake', Icons.crisis_alert_outlined),
  _IconOption('SOS', Icons.sos_outlined),
  _IconOption('Help', Icons.help_outline_rounded),
];

// ─── EmergencyCategory Model ─────────────────────────────────────────────────
enum EmergencyLevel { low, medium, high, critical }

class EmergencyCategory {
  final String id;
  String name;
  IconData icon;
  String colorKey;
  EmergencyLevel severity;
  String description;
  String instructions;
  bool active;

  EmergencyCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorKey,
    required this.severity,
    this.description = '',
    this.instructions = '',
    this.active = true,
  });
}

// ─── Global Category List ─────────────────────────────────────────────────────
final List<EmergencyCategory> appCategories = [
  EmergencyCategory(
    id: '1',
    name: 'Medical Emergency',
    icon: Icons.monitor_heart_outlined,
    colorKey: 'red',
    severity: EmergencyLevel.critical,
    description: 'Cardiac, trauma, unconscious person',
    instructions: 'Call 911. Do not move the patient.',
  ),
  EmergencyCategory(
    id: '2',
    name: 'Fire',
    icon: Icons.local_fire_department_outlined,
    colorKey: 'orange',
    severity: EmergencyLevel.critical,
    description: 'Structure fire, wildfire, smoke',
    instructions: 'Evacuate the area. Close all doors.',
  ),
  EmergencyCategory(
    id: '3',
    name: 'Flooding',
    icon: Icons.water_outlined,
    colorKey: 'blue',
    severity: EmergencyLevel.high,
    description: 'Flash flood, rising water levels',
    instructions: 'Move to higher ground immediately.',
  ),
  EmergencyCategory(
    id: '4',
    name: 'Break-in',
    icon: Icons.lock_open_outlined,
    colorKey: 'yellow',
    severity: EmergencyLevel.high,
    description: 'Intrusion, theft in progress',
    instructions: 'Do not confront. Stay hidden and call police.',
  ),
  EmergencyCategory(
    id: '5',
    name: 'Accident',
    icon: Icons.car_crash_outlined,
    colorKey: 'orange',
    severity: EmergencyLevel.medium,
    description: 'Road collision, vehicle crash',
    instructions: 'Secure the scene. Do not move injured persons.',
  ),
  EmergencyCategory(
    id: '6',
    name: 'SOS Alert',
    icon: Icons.warning_amber_outlined,
    colorKey: 'red',
    severity: EmergencyLevel.medium,
    description: 'Any emergency not listed above',
    instructions: 'Provide as much detail as possible.',
  ),
];

int _catIdCounter = 7;
String _nextCatId() => '${_catIdCounter++}';

// ─── EmergencyItem Model ──────────────────────────────────────────────────────
class EmergencyItem {
  final String id;
  final String type;
  final EmergencyLevel level;
  final String location;
  final String reportedBy;
  final String dateTime;
  final String description;
  final String? responder;
  int step; // 0=Pending,1=Assigned,2=Responding,3=Resolved
  final double mapLat;
  final double mapLng;

  EmergencyItem({
    required this.id,
    required this.type,
    required this.level,
    required this.location,
    required this.reportedBy,
    required this.dateTime,
    required this.description,
    this.responder,
    required this.step,
    required this.mapLat,
    required this.mapLng,
  });

  factory EmergencyItem.fromMap(Map<String, dynamic> map) {
    return EmergencyItem(
      id: map['id'].toString(),
      type: map['type'] ?? 'Emergency',
      level: EmergencyLevel.values.firstWhere(
        (e) => e.name == map['level'],
        orElse: () => EmergencyLevel.high,
      ),
      location: map['location'] ?? 'Unknown',
      reportedBy: map['reported_by'] ?? 'Anonymous',
      dateTime: map['created_at'] != null
          ? DateFormat(
              'MMM dd, hh:mm a',
            ).format(DateTime.parse(map['created_at']))
          : 'Just now',
      description: map['description'] ?? '',
      responder: map['responder'],
      step: map['step'] ?? 0,
      mapLat: (map['map_lat'] as num?)?.toDouble() ?? 14.1668,
      mapLng: (map['map_lng'] as num?)?.toDouble() ?? 121.2420,
    );
  }
}

// ─── Step labels ─────────────────────────────────────────────────────────────
const _stepLabels = ['Pending', 'Assigned', 'Responding', 'Resolved'];

// ─── Helpers ──────────────────────────────────────────────────────────────────
Color _levelColor(EmergencyLevel l) => switch (l) {
  EmergencyLevel.low => _kGreen,
  EmergencyLevel.medium => _kYellow,
  EmergencyLevel.high => _kOrange,
  EmergencyLevel.critical => _kRed,
};

Color _levelBg(EmergencyLevel l) => switch (l) {
  EmergencyLevel.low => _kGreenBg,
  EmergencyLevel.medium => _kYellowBg,
  EmergencyLevel.high => _kOrangeBg,
  EmergencyLevel.critical => _kRedBg,
};

Color _levelBorder(EmergencyLevel l) => switch (l) {
  EmergencyLevel.low => _kGreenBorder,
  EmergencyLevel.medium => const Color(0x40EAB308),
  EmergencyLevel.high => _kOrangeBorder,
  EmergencyLevel.critical => _kRedBorder,
};

String _levelLabel(EmergencyLevel l) => switch (l) {
  EmergencyLevel.low => 'LOW',
  EmergencyLevel.medium => 'MEDIUM',
  EmergencyLevel.high => 'HIGH',
  EmergencyLevel.critical => 'CRITICAL',
};

IconData _typeIcon(String type) {
  final cat = appCategories.firstWhere(
    (c) => c.name == type,
    orElse: () => appCategories.first,
  );
  return cat.icon;
}

Color _typeColor(String type) {
  final cat = appCategories.firstWhere(
    (c) => c.name == type,
    orElse: () => appCategories.first,
  );
  return _presetByKey(cat.colorKey).fg;
}

const _severities = [
  (EmergencyLevel.low, '🟢', 'Low'),
  (EmergencyLevel.medium, '🟡', 'Medium'),
  (EmergencyLevel.high, '🟠', 'High'),
  (EmergencyLevel.critical, '🔴', 'Critical'),
];

// ============================================================================
//  MANAGE CATEGORIES PAGE
// ============================================================================
class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  void _openAdd() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormSheet(
        onSave: (cat) => setState(() => appCategories.add(cat)),
      ),
    );
  }

  void _openEdit(EmergencyCategory cat) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CategoryFormSheet(existing: cat, onSave: (_) => setState(() {})),
    );
  }

  void _confirmDelete(EmergencyCategory cat) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmSheet(categoryName: cat.name),
    );
    if (confirmed == true) {
      setState(() => appCategories.removeWhere((c) => c.id == cat.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = appCategories.where((c) => c.active).length;
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
          'Emergency Categories',
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
            child: TextButton.icon(
              onPressed: _openAdd,
              icon: const Icon(Icons.add_rounded, size: 18, color: _kAccent),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: _kAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: _kAccentBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: _kAccentBorder),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _SummaryPill(
                  '${appCategories.length} Total',
                  _kAccent,
                  _kAccentBg,
                  _kAccentBorder,
                ),
                const SizedBox(width: 8),
                _SummaryPill(
                  '$active Active',
                  _kGreen,
                  _kGreenBg,
                  _kGreenBorder,
                ),
                const SizedBox(width: 8),
                _SummaryPill(
                  '${appCategories.length - active} Disabled',
                  _kText3,
                  const Color(0xFFF9FAFB),
                  const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: appCategories.isEmpty
                ? const _EmptyCategories()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: appCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final cat = appCategories[i];
                      return _CategoryCard(
                        category: cat,
                        onEdit: () => _openEdit(cat),
                        onDelete: () => _confirmDelete(cat),
                        onToggle: () =>
                            setState(() => cat.active = !cat.active),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color fg, bg, border;
  const _SummaryPill(this.label, this.fg, this.bg, this.border);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final EmergencyCategory category;
  final VoidCallback onEdit, onDelete, onToggle;
  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final preset = _presetByKey(category.colorKey);
    final sevEntry = _severities.firstWhere(
      (s) => s.$1 == category.severity,
      orElse: () => _severities[2],
    );

    return Opacity(
      opacity: category.active ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: preset.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: preset.border),
                    ),
                    child: Icon(category.icon, color: preset.fg, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: preset.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: preset.border),
                          ),
                          child: Text(
                            '${sevEntry.$2}  ${sevEntry.$3}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: preset.fg,
                            ),
                          ),
                        ),
                        if (category.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _kText3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: category.active,
                    onChanged: (_) => onToggle(),
                    activeThumbColor: _kAccent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  _CardActionBtn(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onTap: onEdit,
                  ),
                  Container(
                    width: 0.5,
                    height: 18,
                    color: _kBorder,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  _CardActionBtn(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    onTap: onDelete,
                    danger: true,
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

class _CardActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _CardActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? _kRed : _kAccent;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

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
              Icons.category_outlined,
              color: _kAccent,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap Add to create your first\nemergency category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  CATEGORY FORM BOTTOM SHEET
// ============================================================================
class _CategoryFormSheet extends StatefulWidget {
  final EmergencyCategory? existing;
  final void Function(EmergencyCategory) onSave;
  const _CategoryFormSheet({this.existing, required this.onSave});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl, _descCtrl, _instCtrl;
  late IconData _selectedIcon;
  late String _selectedColorKey;
  late EmergencyLevel _selectedSeverity;
  bool _nameError = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _instCtrl = TextEditingController(text: e?.instructions ?? '');
    _selectedIcon = e?.icon ?? Icons.warning_amber_outlined;
    _selectedColorKey = e?.colorKey ?? 'red';
    _selectedSeverity = e?.severity ?? EmergencyLevel.high;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _instCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    if (_isEdit) {
      widget.existing!
        ..name = name
        ..icon = _selectedIcon
        ..colorKey = _selectedColorKey
        ..severity = _selectedSeverity
        ..description = _descCtrl.text.trim()
        ..instructions = _instCtrl.text.trim();
      widget.onSave(widget.existing!);
    } else {
      widget.onSave(
        EmergencyCategory(
          id: _nextCatId(),
          name: name,
          icon: _selectedIcon,
          colorKey: _selectedColorKey,
          severity: _selectedSeverity,
          description: _descCtrl.text.trim(),
          instructions: _instCtrl.text.trim(),
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presetByKey(_selectedColorKey);

    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: _kText2, size: 20),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _FormLabel('Category Name', required: true),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() => _nameError = false),
              style: const TextStyle(fontSize: 13, color: _kText),
              decoration: InputDecoration(
                hintText: 'e.g. Medical, Fire, Flood…',
                hintStyle: const TextStyle(color: _kText3, fontSize: 13),
                filled: true,
                fillColor: _kSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _nameError ? _kRed : _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _nameError ? _kRed : _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _nameError ? _kRed : _kAccent),
                ),
                errorText: _nameError ? 'Please enter a category name' : null,
              ),
            ),
            const SizedBox(height: 18),
            _FormLabel('Icon'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (_, i) {
                final opt = _iconOptions[i];
                final active = _selectedIcon == opt.icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = opt.icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: active ? preset.bg : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? preset.border : _kBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Icon(
                      opt.icon,
                      size: 20,
                      color: active ? preset.fg : _kText3,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            _FormLabel('Color'),
            const SizedBox(height: 8),
            Row(
              children: _colorPresets.map((p) {
                final active = _selectedColorKey == p.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedColorKey = p.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: p.fg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active ? _kText : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: active
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _FormLabel('Severity Level', required: true),
            const SizedBox(height: 8),
            Row(
              children: _severities.map((rec) {
                final (level, emoji, label) = rec;
                final active = _selectedSeverity == level;
                final fg = _levelColor(level);
                final bg = _levelBg(level);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSeverity = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? bg : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? fg : _kBorder,
                          width: active ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: active ? fg : _kText3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _FormLabel('Short Description'),
            const SizedBox(height: 6),
            _StyledTextField(
              controller: _descCtrl,
              hint: 'Briefly describe this emergency type…',
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _FormLabel('Responder Instructions'),
            const SizedBox(height: 6),
            _StyledTextField(
              controller: _instCtrl,
              hint: 'What should responders do first?',
              maxLines: 3,
            ),
            const SizedBox(height: 28),
            // Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kSurface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: preset.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: preset.border),
                    ),
                    child: Icon(_selectedIcon, color: preset.fg, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameCtrl.text.isNotEmpty
                              ? _nameCtrl.text
                              : 'Category name…',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _nameCtrl.text.isNotEmpty ? _kText : _kText3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Preview',
                          style: TextStyle(fontSize: 10, color: _kText3),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: preset.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: preset.border),
                    ),
                    child: Text(
                      _levelLabel(_selectedSeverity),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: preset.fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                onPressed: _save,
                icon: Icon(
                  _isEdit ? Icons.check_rounded : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(
                  _isEdit ? 'Save Changes' : 'Add Category',
                  style: const TextStyle(
                    fontSize: 14,
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

class _DeleteConfirmSheet extends StatelessWidget {
  final String categoryName;
  const _DeleteConfirmSheet({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _kRedBg,
              shape: BoxShape.circle,
              border: Border.all(color: _kRedBorder),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: _kRed,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Delete "$categoryName"?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Residents will no longer see this category\nin the emergency report form.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _kText3, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _kBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _kText2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FormLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kText2,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(color: _kRed, fontSize: 12)),
        ],
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: _kText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _kText3, fontSize: 13),
        filled: true,
        fillColor: _kSurface,
        contentPadding: const EdgeInsets.all(14),
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
          borderSide: const BorderSide(color: _kAccent),
        ),
      ),
    );
  }
}

// ============================================================================
//  EMERGENCY TRACKER PAGE
// ============================================================================
class EmergencyTrackerPage extends StatefulWidget {
  const EmergencyTrackerPage({super.key});

  @override
  State<EmergencyTrackerPage> createState() => _EmergencyTrackerPageState();
}

class _EmergencyTrackerPageState extends State<EmergencyTrackerPage>
    with TickerProviderStateMixin {
  String _filterLevel = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  List<EmergencyItem> _applyFilters(List<EmergencyItem> items) {
    return items.where((e) {
      final matchLevel = _filterLevel == 'all' || e.level.name == _filterLevel;
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          e.type.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q) ||
          e.reportedBy.toLowerCase().contains(q);
      return matchLevel && matchSearch;
    }).toList();
  }

  void _advanceStep(EmergencyItem e) async {
    if (e.step < 3) {
      await supabase
          .from('emergency_incidents')
          .update({'step': e.step + 1})
          .eq('id', e.id);
    }
  }

  void _showDetail(EmergencyItem e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => _DetailSheet(
          item: e,
          onAdvance: e.step < 3
              ? () async {
                  await supabase
                      .from('emergency_incidents')
                      .update({'step': e.step + 1})
                      .eq('id', e.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('emergency_incidents')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allItems = (snapshot.data ?? [])
            .map((m) => EmergencyItem.fromMap(m))
            .toList();
        final filtered = _applyFilters(allItems);
        final live = filtered.where((e) => e.step < 3).toList();
        final resolved = filtered.where((e) => e.step == 3).toList();

        final activeCount = allItems.where((e) => e.step < 3).length;
        final critCount = allItems
            .where((e) => e.level == EmergencyLevel.critical)
            .length;
        final resCount = allItems.where((e) => e.step == 3).length;

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
              'Emergency Tracker',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: _kAccent, size: 20),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    instantRoute(const ManageCategoriesPage()),
                  );
                },
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          _StatCard('Active', activeCount, _kRed),
                          const SizedBox(width: 8),
                          _StatCard('Critical', critCount, _kOrange),
                          const SizedBox(width: 8),
                          _StatCard('Resolved', resCount, _kGreen),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InlineMapSection(
                      items: filtered,
                      pulseCtrl: _pulseCtrl,
                      onPinTap: _showDetail,
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(color: _kText, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Search type, location, reporter…',
                            hintStyle: TextStyle(color: _kText3, fontSize: 13),
                            prefixIcon: Icon(
                              Icons.search,
                              color: _kText3,
                              size: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _FilterChip(
                            'All',
                            'all',
                            _filterLevel,
                            (v) => setState(() => _filterLevel = v),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            'Critical',
                            'critical',
                            _filterLevel,
                            (v) => setState(() => _filterLevel = v),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            'High',
                            'high',
                            _filterLevel,
                            (v) => setState(() => _filterLevel = v),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            'Medium',
                            'medium',
                            _filterLevel,
                            (v) => setState(() => _filterLevel = v),
                          ),
                          const SizedBox(width: 6),
                          _FilterChip(
                            'Low',
                            'low',
                            _filterLevel,
                            (v) => setState(() => _filterLevel = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      title: 'Live Incidents',
                      count:
                          '${live.length} alert${live.length == 1 ? '' : 's'}',
                      countColor: _kRed,
                      countBg: _kRedBg,
                      countBorder: _kRedBorder,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _IncidentCard(
                      item: live[i],
                      onTap: () => _showDetail(live[i]),
                      onAdvance: () => _advanceStep(live[i]),
                    ),
                  ),
                  childCount: live.length,
                ),
              ),
              if (live.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No active incidents',
                        style: TextStyle(color: _kText3, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _SectionHeader(
                      title: 'Resolved Today',
                      count: '${resolved.length} resolved',
                      countColor: _kGreen,
                      countBg: _kGreenBg,
                      countBorder: _kGreenBorder,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _ResolvedCard(
                      item: resolved[i],
                      onTap: () => _showDetail(resolved[i]),
                    ),
                  ),
                  childCount: resolved.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: _kText3)),
            const SizedBox(height: 8),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
//  INLINE MAP SECTION  (200px preview with real OSM tiles)
// ============================================================================
class _InlineMapSection extends StatefulWidget {
  final List<EmergencyItem> items;
  final AnimationController pulseCtrl;
  final void Function(EmergencyItem) onPinTap;

  const _InlineMapSection({
    required this.items,
    required this.pulseCtrl,
    required this.onPinTap,
  });

  @override
  State<_InlineMapSection> createState() => _InlineMapSectionState();
}

class _InlineMapSectionState extends State<_InlineMapSection> {
  final _mapCtrl = MapController();
  bool _cacheReady = false;

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  Future<void> _initCache() async {
    try {
      final tmp = await getTemporaryDirectory();
      final dir = Directory(
        '${tmp.path}${Platform.pathSeparator}$_kOsmCacheFolder',
      );
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (_) {}
    if (mounted) setState(() => _cacheReady = true);
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: _cacheReady
              ? FlutterMap(
                  mapController: _mapCtrl,
                  options: const MapOptions(
                    initialCenter: LatLng(_kDefaultLat, _kDefaultLng),
                    initialZoom: 14,
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _kOsmTile,
                      tileProvider: CancellableNetworkTileProvider(),
                      userAgentPackageName: 'com.barangay.ube',
                      maxNativeZoom: 19,
                      keepBuffer: 4,
                    ),
                    MarkerLayer(
                      markers: widget.items.map((item) {
                        return Marker(
                          point: LatLng(item.mapLat, item.mapLng),
                          width: 36,
                          height: 44,
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                            onTap: () => widget.onPinTap(item),
                            child: _MiniPin(
                              color: _levelColor(item.level),
                              icon: _typeIcon(item.type),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    RichAttributionWidget(
                      alignment: AttributionAlignment.bottomLeft,
                      popupBackgroundColor: Colors.white.withOpacity(0.9),
                      attributions: [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                )
              : Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _kAccent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
        ),
        // Fullscreen button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              instantRoute(EmergencyMapPage(items: widget.items)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fullscreen_rounded, size: 14, color: _kAccent),
                  SizedBox(width: 4),
                  Text(
                    'Fullscreen',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _kAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Legend
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegDot(Color(0xFFEF4444), 'Active'),
                SizedBox(width: 10),
                _LegDot(Color(0xFFF97316), 'Responding'),
                SizedBox(width: 10),
                _LegDot(Color(0xFF22C55E), 'Resolved'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Mini Pin ─────────────────────────────────────────────────────────────────
class _MiniPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _MiniPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.35), blurRadius: 6),
            ],
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        CustomPaint(size: const Size(8, 5), painter: _DropTailPainter(color)),
      ],
    );
  }
}

// ─── Drop tail painter — uses dart:ui Path via prefix to avoid latlong2 clash ─
class _DropTailPainter extends CustomPainter {
  final Color c;
  const _DropTailPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      ui.Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      ui.Paint()..color = c,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LegDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: _kText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, count;
  final Color countColor, countBg, countBorder;
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.countColor,
    required this.countBg,
    required this.countBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _kText3,
              letterSpacing: .1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: countBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: countBorder),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: countColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, current;
  final void Function(String) onTap;
  const _FilterChip(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _kAccent : _kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : _kText3,
          ),
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final EmergencyItem item;
  final VoidCallback onTap, onAdvance;
  const _IncidentCard({
    required this.item,
    required this.onTap,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final lc = _levelColor(item.level);
    final lb = _levelBg(item.level);
    final lbr = _levelBorder(item.level);
    final isCrit = item.level == EmergencyLevel.critical;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isCrit ? _kRedBorder : _kBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: lb,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon(item.type), color: lc, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.reportedBy,
                          style: const TextStyle(fontSize: 11, color: _kText3),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: lb,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: lbr),
                    ),
                    child: Text(
                      _levelLabel(item.level),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: lc,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: _kText3,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.location,
                      style: const TextStyle(fontSize: 11, color: _kText3),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time, size: 13, color: _kText3),
                  const SizedBox(width: 4),
                  Text(
                    item.dateTime,
                    style: const TextStyle(fontSize: 11, color: _kText3),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
              ),
              child: _Stepper(currentStep: item.step),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  _ActionBtn(
                    label: 'Manage',
                    icon: Icons.remove_red_eye_outlined,
                    primary: true,
                    onTap: onTap,
                  ),
                  const SizedBox(width: 6),
                  _ActionBtn(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 6),
                  _ActionBtn(
                    label: 'Assign',
                    icon: Icons.person_add_alt_1_outlined,
                    onTap: () {},
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

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    this.primary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: primary ? _kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary ? _kAccent : _kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: primary ? Colors.white : _kText2),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primary ? Colors.white : _kText2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int currentStep;
  final bool large;
  const _Stepper({required this.currentStep, this.large = false});

  @override
  Widget build(BuildContext context) {
    final sz = large ? 26.0 : 20.0;
    final fontSize = large ? 8.5 : 7.5;

    return Row(
      children: List.generate(_stepLabels.length, (i) {
        final isDone = i <= currentStep;
        final isCurrent = i == currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: sz,
                      height: sz,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? _kAccent : _kSurface2,
                        border: isDone ? null : Border.all(color: _kBorder),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: _kAccent.withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        i < currentStep ? Icons.check : Icons.circle,
                        size: isDone ? 10 : 6,
                        color: isDone ? Colors.white : _kText3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepLabels[i],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: isDone ? _kAccent2 : _kText3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (i < _stepLabels.length - 1)
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: i < currentStep ? _kAccent : _kBorder,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _ResolvedCard extends StatelessWidget {
  final EmergencyItem item;
  final VoidCallback onTap;
  const _ResolvedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kGreenBorder),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: _kGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.location} · ${item.dateTime}',
                    style: const TextStyle(fontSize: 11, color: _kText3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGreenBorder),
              ),
              child: const Text(
                'RESOLVED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _kGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final EmergencyItem item;
  final VoidCallback? onAdvance;
  const _DetailSheet({required this.item, this.onAdvance});

  @override
  Widget build(BuildContext context) {
    final lc = _levelColor(item.level);
    final lb = _levelBg(item.level);
    final lbr = _levelBorder(item.level);

    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: lb,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon(item.type), color: lc, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: _kText2, size: 20),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: lb,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: lbr),
            ),
            child: Text(
              _levelLabel(item.level),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: lc,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(Icons.person_outline, 'Reporter', item.reportedBy),
          _DetailRow(Icons.location_on_outlined, 'Location', item.location),
          _DetailRow(Icons.access_time, 'Time', item.dateTime),
          _DetailRow(Icons.description_outlined, 'Details', item.description),
          if (item.responder != null)
            _DetailRow(Icons.shield_outlined, 'Responder', item.responder!),
          const SizedBox(height: 14),
          const Text(
            'Response Progress',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kText3,
              letterSpacing: .07,
            ),
          ),
          const SizedBox(height: 12),
          _Stepper(currentStep: item.step, large: true),
          const SizedBox(height: 20),
          if (onAdvance != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: onAdvance,
                child: Text(
                  'Advance to "${_stepLabels[item.step + 1]}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kGreenBorder),
              ),
              child: const Text(
                '✓  Emergency Resolved',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kGreen, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _kText3),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kText3,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: _kText2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  FULLSCREEN MAP PAGE
// ============================================================================
class EmergencyMapPage extends StatefulWidget {
  final List<EmergencyItem> items;
  const EmergencyMapPage({super.key, required this.items});

  @override
  State<EmergencyMapPage> createState() => _EmergencyMapPageState();
}

class _EmergencyMapPageState extends State<EmergencyMapPage>
    with TickerProviderStateMixin {
  final _mapCtrl = MapController();

  // ── Location state ────────────────────────────────────────────────────────
  LatLng _center = const LatLng(_kDefaultLat, _kDefaultLng);
  LatLng? _deviceLocation; // live GPS fix
  LatLng? _lastKnown; // last good fix (in-memory this session)
  bool _locating = false;
  bool _locationDenied = false;
  bool _trackingDevice = false;

  // ── Cached across sessions via shared_preferences ─────────────────────────
  static LatLng? _sessionCache; // survives page pushes within a session

  // ── Tile cache ────────────────────────────────────────────────────────────
  bool _cacheReady = false;

  // ── UI ────────────────────────────────────────────────────────────────────
  EmergencyItem? _selected;
  bool _activeOnly = false;

  // ── Animations ────────────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  AnimationController? _moveCtrl;

  @override
  void initState() {
    super.initState();
    _initPulse();
    _initCacheDir();
    _initLocation();
  }

  void _initPulse() {
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.55,
      end: 1.45,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Future<void> _initCacheDir() async {
    try {
      final tmp = await getTemporaryDirectory();
      final dir = Directory(
        '${tmp.path}${Platform.pathSeparator}$_kOsmCacheFolder',
      );
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (_) {}
    if (mounted) setState(() => _cacheReady = true);
  }

  // ── Location init: device → last-known → default ──────────────────────────
  Future<void> _initLocation() async {
    setState(() => _locating = true);

    // 1. Snap to last-known immediately while GPS warms up
    final persisted = _sessionCache ?? await _loadPersistedLocation();
    if (persisted != null && mounted) {
      setState(() {
        _lastKnown = persisted;
        _sessionCache = persisted;
        _center = persisted;
      });
      _mapCtrl.move(persisted, 15.5);
    }

    // 2. Try to get live GPS
    final pos = await _resolvePosition();
    if (!mounted) return;

    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      await _persistLocation(ll);
      _sessionCache = ll;
      setState(() {
        _deviceLocation = ll;
        _lastKnown = ll;
        _center = ll;
        _trackingDevice = true;
        _locating = false;
      });
      _animateTo(ll, 16.5);
    } else {
      setState(() => _locating = false);
      // GPS failed — stay on last-known if we have it, else stay on default
      if (_lastKnown == null) {
        setState(() => _locationDenied = true);
      }
    }
  }

  Future<void> _goToMyLocation() async {
    if (_locating) return;

    // Already have live fix — just re-center
    if (_deviceLocation != null) {
      setState(() => _trackingDevice = true);
      _animateTo(_deviceLocation!, 16.5);
      return;
    }

    // Show last-known while re-fetching
    if (_lastKnown != null) _animateTo(_lastKnown!, 15.5);

    setState(() {
      _locating = true;
      _locationDenied = false;
    });
    final pos = await _resolvePosition();
    if (!mounted) return;

    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      await _persistLocation(ll);
      _sessionCache = ll;
      setState(() {
        _deviceLocation = ll;
        _lastKnown = ll;
        _trackingDevice = true;
        _locating = false;
      });
      _animateTo(ll, 16.5);
    } else {
      setState(() => _locating = false);
      if (_lastKnown == null) setState(() => _locationDenied = true);
    }
  }

  // ── Geolocator helper ─────────────────────────────────────────────────────
  Future<Position?> _resolvePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Persist last location via shared_preferences ──────────────────────────
  Future<void> _persistLocation(LatLng ll) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kPrefLastLat, ll.latitude);
      await prefs.setDouble(_kPrefLastLng, ll.longitude);
    } catch (_) {}
  }

  Future<LatLng?> _loadPersistedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_kPrefLastLat);
      final lng = prefs.getDouble(_kPrefLastLng);
      if (lat != null && lng != null) return LatLng(lat, lng);
    } catch (_) {}
    return null;
  }

  // ── Smooth camera animation ───────────────────────────────────────────────
  void _animateTo(LatLng target, double zoom) {
    _moveCtrl?.dispose();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 560),
    );
    final latT = Tween<double>(
      begin: _mapCtrl.camera.center.latitude,
      end: target.latitude,
    );
    final lngT = Tween<double>(
      begin: _mapCtrl.camera.center.longitude,
      end: target.longitude,
    );
    final zoomT = Tween<double>(begin: _mapCtrl.camera.zoom, end: zoom);
    final curve = CurvedAnimation(
      parent: _moveCtrl!,
      curve: Curves.easeInOutCubic,
    );
    _moveCtrl!
      ..addListener(
        () => _mapCtrl.move(
          LatLng(latT.evaluate(curve), lngT.evaluate(curve)),
          zoomT.evaluate(curve),
        ),
      )
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _moveCtrl?.dispose();
      })
      ..forward();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _pulseCtrl.dispose();
    _moveCtrl?.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: Stack(
          children: [
            // 1. Map
            if (_cacheReady) _buildMap(),
            if (!_cacheReady)
              Container(
                color: _kBg,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: _kAccent,
                    strokeWidth: 2.5,
                  ),
                ),
              ),

            // 2. Top gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: top + 72,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Top bar
            Positioned(
              top: top + 10,
              left: 12,
              right: 12,
              child: _buildTopBar(),
            ),

            // 4. Filter chips
            Positioned(top: top + 64, left: 12, child: _buildFilters()),

            // 5. FABs
            Positioned(
              right: 14,
              bottom: _selected != null ? 240 : 38,
              child: _buildFabs(),
            ),

            // 6. Pin sheet
            AnimatedPositioned(
              duration: const Duration(milliseconds: 290),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: _selected != null ? 0 : -300,
              child: _buildPinSheet(),
            ),

            // 7. Location denied banner
            if (_locationDenied)
              Positioned(
                top: top + 116,
                left: 12,
                right: 12,
                child: _LocationDeniedBanner(
                  onDismiss: () => setState(() => _locationDenied = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('emergency_incidents').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        final allItems = (snapshot.data ?? [])
            .map((m) => EmergencyItem.fromMap(m))
            .toList();
        final visible = _activeOnly
            ? allItems.where((e) => e.step < 3).toList()
            : allItems;

        return FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _lastKnown != null ? 15.5 : 14.0,
            minZoom: 4,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (_, _) {
              if (_selected != null) setState(() => _selected = null);
            },
            onPositionChanged: (_, hasGesture) {
              if (hasGesture && _trackingDevice)
                setState(() => _trackingDevice = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _kOsmTile,
              tileProvider: CancellableNetworkTileProvider(),
              userAgentPackageName: 'com.barangay.ube',
              maxNativeZoom: 19,
              keepBuffer: 6,
              panBuffer: 2,
            ),
            MarkerLayer(
              rotate: true,
              markers: visible.map((item) {
                final isSel = _selected?.id == item.id;
                return Marker(
                  point: LatLng(item.mapLat, item.mapLng),
                  width: isSel ? 58 : 44,
                  height: isSel ? 68 : 54,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () =>
                            _selected = _selected?.id == item.id ? null : item,
                      );
                      if (_selected != null)
                        _animateTo(LatLng(item.mapLat, item.mapLng), 16.5);
                    },
                    child: AnimatedScale(
                      scale: isSel ? 1.10 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: _FullPin(
                        color: _levelColor(item.level),
                        icon: _typeIcon(item.type),
                        selected: isSel,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Device location dot
            if (_deviceLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _deviceLocation!,
                    width: 52,
                    height: 52,
                    child: _DeviceMarker(pulse: _pulseAnim),
                  ),
                ],
              ),
            // Last-known location marker (ghost dot, only shown if GPS not yet acquired)
            if (_lastKnown != null && _deviceLocation == null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _lastKnown!,
                    width: 40,
                    height: 40,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _kAccent.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              popupBackgroundColor: Colors.white.withOpacity(0.92),
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    final activeCount = widget.items.where((e) => e.step < 3).length;
    return Row(
      children: [
        _GlassCircle(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17,
            color: _kText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GlassPill(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Flexible(
                  child: Text(
                    'Emergency Map',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _kRedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$activeCount Active',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _kRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _GlassCircle(
          onTap: _showLegend,
          child: const Icon(Icons.layers_outlined, size: 20, color: _kText),
        ),
      ],
    );
  }

  Widget _buildFilters() => Row(
    children: [
      _MapFilterPill(
        label: 'All',
        active: !_activeOnly,
        onTap: () => setState(() => _activeOnly = false),
      ),
      const SizedBox(width: 6),
      _MapFilterPill(
        label: 'Active Only',
        active: _activeOnly,
        onTap: () => setState(() => _activeOnly = true),
      ),
    ],
  );

  Widget _buildFabs() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _RoundFab(
        icon: Icons.add,
        onTap: () => _mapCtrl.move(
          _mapCtrl.camera.center,
          (_mapCtrl.camera.zoom + 1).clamp(4.0, 19.0),
        ),
      ),
      const SizedBox(height: 8),
      _RoundFab(
        icon: Icons.remove,
        onTap: () => _mapCtrl.move(
          _mapCtrl.camera.center,
          (_mapCtrl.camera.zoom - 1).clamp(4.0, 19.0),
        ),
      ),
      const SizedBox(height: 14),
      _RoundFab(
        large: true,
        icon: _locating
            ? Icons.hourglass_top_rounded
            : _trackingDevice
            ? Icons.my_location_rounded
            : Icons.location_searching_rounded,
        color: _trackingDevice ? _kAccent : _kText3,
        onTap: _goToMyLocation,
      ),
    ],
  );

  Widget _buildPinSheet() {
    final item = _selected;
    if (item == null) return const SizedBox.shrink();

    final lc = _levelColor(item.level);
    final lb = _levelBg(item.level);
    final lbr = _levelBorder(item.level);

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: lb,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: lbr),
                      ),
                      child: Icon(_typeIcon(item.type), color: lc, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.type,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _kText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 11,
                                color: _kText3,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  item.location,
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
                    GestureDetector(
                      onTap: () => setState(() => _selected = null),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: _kText3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: lb,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lbr),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.step == 3
                            ? Icons.check_circle_outline
                            : Icons.timelapse_rounded,
                        size: 15,
                        color: lc,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Status: ${_stepLabels[item.step]}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: lc,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: i <= item.step ? lc : lc.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 13, color: _kText3),
                    const SizedBox(width: 4),
                    Text(
                      item.reportedBy,
                      style: const TextStyle(fontSize: 11, color: _kText3),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time, size: 13, color: _kText3),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.dateTime,
                        style: const TextStyle(fontSize: 11, color: _kText3),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SheetActionBtn(
                        label: 'Manage',
                        icon: Icons.shield_outlined,
                        filled: true,
                        color: _kAccent,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SheetActionBtn(
                        label: 'Details',
                        icon: Icons.article_outlined,
                        filled: false,
                        color: _kText2,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLegend() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Map Legend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kText,
              ),
            ),
            const SizedBox(height: 16),
            ...([
              (_kRed, 'Critical', Icons.crisis_alert_rounded),
              (_kOrange, 'High', Icons.warning_rounded),
              (_kYellow, 'Medium', Icons.info_outline_rounded),
              (_kGreen, 'Low', Icons.check_circle_outline),
            ].map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: e.$1.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(e.$3, size: 15, color: e.$1),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${e.$2} severity',
                      style: const TextStyle(fontSize: 13, color: _kText2),
                    ),
                  ],
                ),
              ),
            )),
            const Divider(height: 24, color: _kBorder),
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _kAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Your live location (pulsing)',
                  style: TextStyle(fontSize: 13, color: _kText2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _kAccent.withOpacity(0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Last known location (ghost dot)',
                  style: TextStyle(fontSize: 13, color: _kText2),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }
}

// ─── Full pin ─────────────────────────────────────────────────────────────────
class _FullPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool selected;
  const _FullPin({
    required this.color,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final sz = selected ? 50.0 : 38.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: sz,
          height: sz,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: selected ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? 0.50 : 0.28),
                blurRadius: selected ? 18 : 8,
                spreadRadius: selected ? 2 : 0,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: selected ? 26 : 19),
        ),
        CustomPaint(size: const Size(10, 7), painter: _DropTailPainter(color)),
      ],
    );
  }
}

// ─── Device marker ────────────────────────────────────────────────────────────
class _DeviceMarker extends StatelessWidget {
  final Animation<double> pulse;
  const _DeviceMarker({required this.pulse});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (_, child) => Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44 * pulse.value,
          height: 44 * pulse.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kAccent.withOpacity(0.13 / pulse.value),
          ),
        ),
        child!,
      ],
    ),
    child: Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: _kAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: _kAccent.withOpacity(0.45), blurRadius: 10),
        ],
      ),
    ),
  );
}

// ─── Glass widgets ────────────────────────────────────────────────────────────
class _GlassCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassCircle({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        shape: BoxShape.circle,
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Center(child: child),
    ),
  );
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.90),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _kBorder),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
      ],
    ),
    child: child,
  );
}

class _MapFilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _MapFilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _kAccent : Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _kAccent : _kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : _kText3,
        ),
      ),
    ),
  );
}

class _RoundFab extends StatelessWidget {
  final IconData icon;
  final bool large;
  final Color color;
  final VoidCallback onTap;
  const _RoundFab({
    required this.icon,
    required this.onTap,
    this.large = false,
    this.color = _kText3,
  });

  @override
  Widget build(BuildContext context) {
    final sz = large ? 50.0 : 40.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: sz,
        height: sz,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: large ? color.withOpacity(0.30) : _kBorder,
            width: large ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: large ? 24 : 20, color: color),
      ),
    );
  }
}

class _SheetActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final Color color;
  final VoidCallback onTap;
  const _SheetActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: filled ? color : color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: filled ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _LocationDeniedBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _LocationDeniedBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _kRedBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kRedBorder),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.location_off_outlined, size: 16, color: _kRed),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Location access denied — showing last known area.',
            style: TextStyle(fontSize: 11, color: _kRed),
          ),
        ),
        GestureDetector(
          onTap: onDismiss,
          child: const Icon(Icons.close, size: 15, color: _kRed),
        ),
      ],
    ),
  );
}
