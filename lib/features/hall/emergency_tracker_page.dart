// ============================================================================
// emergency_tracker_page.dart
// Merged & Improved Emergency Tracker — with Category Management
// ============================================================================

import 'package:flutter/material.dart';

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

// ─── Global Category List (shared state) ─────────────────────────────────────
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
}

// ─── Mock Data ────────────────────────────────────────────────────────────────
final _mockData = [
  EmergencyItem(
    id: '1',
    type: 'Medical Emergency',
    level: EmergencyLevel.critical,
    location: 'Santa Cruz, Blk 3',
    reportedBy: 'Maria Santos',
    dateTime: 'Today, 09:12 AM',
    description: 'Elderly resident collapsed. CPR ongoing by bystanders.',
    responder: 'Team Alpha',
    step: 2,
    mapLat: 0.35,
    mapLng: 0.55,
  ),
  EmergencyItem(
    id: '2',
    type: 'Fire',
    level: EmergencyLevel.high,
    location: 'Bagumbayan, Near market',
    reportedBy: 'Jose Reyes',
    dateTime: 'Today, 08:47 AM',
    description: 'Small fire in food stall, spreading to adjacent stalls.',
    responder: 'BFP Unit 4',
    step: 1,
    mapLat: 0.60,
    mapLng: 0.35,
  ),
  EmergencyItem(
    id: '3',
    type: 'Break-in',
    level: EmergencyLevel.medium,
    location: 'Mabini St, Corner Rizal',
    reportedBy: 'Leni Cruz',
    dateTime: 'Today, 07:30 AM',
    description: 'Suspect broke rear window. Homeowner safe, suspect fled.',
    responder: null,
    step: 0,
    mapLat: 0.25,
    mapLng: 0.70,
  ),
  EmergencyItem(
    id: '4',
    type: 'Flooding',
    level: EmergencyLevel.high,
    location: 'Sampaguita, low-lying area',
    reportedBy: 'Eduardo Lim',
    dateTime: 'Today, 06:15 AM',
    description: 'Flash flood, knee-deep water. 3 families stranded.',
    responder: 'DRRM Team',
    step: 2,
    mapLat: 0.70,
    mapLng: 0.60,
  ),
  EmergencyItem(
    id: '5',
    type: 'SOS Alert',
    level: EmergencyLevel.low,
    location: 'Kalayaan Blvd, near church',
    reportedBy: 'Ana Villanueva',
    dateTime: 'Yesterday, 11:55 PM',
    description: 'Vehicle breakdown on main road. No injury reported.',
    responder: 'Tanod Patrol',
    step: 3,
    mapLat: 0.45,
    mapLng: 0.25,
  ),
];

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

// ─── Severity helpers ─────────────────────────────────────────────────────────
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
  // ── Open Add form ──────────────────────────────────────────────────────────
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

  // ── Open Edit form ─────────────────────────────────────────────────────────
  void _openEdit(EmergencyCategory cat) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _CategoryFormSheet(existing: cat, onSave: (_) => setState(() {})),
    );
  }

  // ── Delete confirmation ────────────────────────────────────────────────────
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
          // ── Summary strip ──────────────────────────────────────────────
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
          // ── Category list ──────────────────────────────────────────────
          Expanded(
            child: appCategories.isEmpty
                ? const _EmptyCategories()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: appCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
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

// ─── Summary Pill ─────────────────────────────────────────────────────────────
class _SummaryPill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final Color border;
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

// ─── Category Card ────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final EmergencyCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
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
            // ── Main row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
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
                  // Info
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
                        // Severity badge
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
                  // Toggle
                  Switch(
                    value: category.active,
                    onChanged: (_) => onToggle(),
                    activeColor: _kAccent,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            // ── Action row ───────────────────────────────────────────────
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

// ─── Empty State ──────────────────────────────────────────────────────────────
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
//  CATEGORY FORM BOTTOM SHEET  (Add / Edit)
// ============================================================================
class _CategoryFormSheet extends StatefulWidget {
  final EmergencyCategory? existing;
  final void Function(EmergencyCategory) onSave;
  const _CategoryFormSheet({this.existing, required this.onSave});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _instCtrl;
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
      // Mutate existing
      widget.existing!
        ..name = name
        ..icon = _selectedIcon
        ..colorKey = _selectedColorKey
        ..severity = _selectedSeverity
        ..description = _descCtrl.text.trim()
        ..instructions = _instCtrl.text.trim();
      widget.onSave(widget.existing!);
    } else {
      final cat = EmergencyCategory(
        id: _nextCatId(),
        name: name,
        icon: _selectedIcon,
        colorKey: _selectedColorKey,
        severity: _selectedSeverity,
        description: _descCtrl.text.trim(),
        instructions: _instCtrl.text.trim(),
      );
      widget.onSave(cat);
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
            // Handle
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
            // Header
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

            // ── Category Name ──────────────────────────────────────────
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

            // ── Icon Picker ────────────────────────────────────────────
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

            // ── Color Picker ───────────────────────────────────────────
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

            // ── Severity ───────────────────────────────────────────────
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

            // ── Description ────────────────────────────────────────────
            _FormLabel('Short Description'),
            const SizedBox(height: 6),
            _StyledTextField(
              controller: _descCtrl,
              hint: 'Briefly describe this emergency type…',
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            // ── Responder Instructions ─────────────────────────────────
            _FormLabel('Responder Instructions'),
            const SizedBox(height: 6),
            _StyledTextField(
              controller: _instCtrl,
              hint: 'What should responders do first?',
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // ── Preview strip ──────────────────────────────────────────
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
                        Text(
                          'Preview',
                          style: const TextStyle(fontSize: 10, color: _kText3),
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

            // ── Submit ─────────────────────────────────────────────────
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

// ─── Delete Confirm Sheet ─────────────────────────────────────────────────────
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

// ─── Reusable Form Widgets ────────────────────────────────────────────────────
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
//  EMERGENCY TRACKER PAGE  (original — with category button added)
// ============================================================================
class EmergencyTrackerPage extends StatefulWidget {
  const EmergencyTrackerPage({super.key});

  @override
  State<EmergencyTrackerPage> createState() => _EmergencyTrackerPageState();
}

class _EmergencyTrackerPageState extends State<EmergencyTrackerPage>
    with TickerProviderStateMixin {
  final List<EmergencyItem> _items = _mockData;
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

  List<EmergencyItem> get _filtered => _items.where((e) {
    final matchLevel = _filterLevel == 'all' || e.level.name == _filterLevel;
    final q = _searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        e.type.toLowerCase().contains(q) ||
        e.location.toLowerCase().contains(q) ||
        e.reportedBy.toLowerCase().contains(q);
    return matchLevel && matchSearch;
  }).toList();

  List<EmergencyItem> get _live => _filtered.where((e) => e.step < 3).toList();
  List<EmergencyItem> get _resolved =>
      _filtered.where((e) => e.step == 3).toList();

  void _advanceStep(EmergencyItem e) {
    if (e.step < 3) setState(() => e.step++);
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
              ? () {
                  setState(() => e.step++);
                  setSheet(() {});
                }
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final live = _live;
    final resolved = _resolved;
    final activeCount = _items.where((e) => e.step < 3).length;
    final critCount = _items
        .where((e) => e.level == EmergencyLevel.critical)
        .length;
    final resCount = _items.where((e) => e.step == 3).length;

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
        // ── Manage Categories button ───────────────────────────────────
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: _kAccent, size: 20),
            onPressed: () async {
              await Navigator.push(
                context,
                _instantRoute(const ManageCategoriesPage()),
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
                _MapSection(
                  items: _filtered,
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
                      decoration: InputDecoration(
                        hintText: 'Search type, location, reporter…',
                        hintStyle: const TextStyle(
                          color: _kText3,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _kText3,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
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
                  count: '${live.length} alert${live.length == 1 ? '' : 's'}',
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

// ─── Map Section ──────────────────────────────────────────────────────────────
class _MapSection extends StatelessWidget {
  final List<EmergencyItem> items;
  final AnimationController pulseCtrl;
  final void Function(EmergencyItem) onPinTap;
  const _MapSection({
    required this.items,
    required this.pulseCtrl,
    required this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Color(0xFF9CA3AF)),
              SizedBox(height: 8),
              Text(
                'Map goes here',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Fullscreen',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegDot(const Color(0xFFEF4444), 'Active'),
                const SizedBox(width: 10),
                _LegDot(const Color(0xFFF97316), 'Responding'),
                const SizedBox(width: 10),
                _LegDot(const Color(0xFF22C55E), 'Resolved'),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
            color: Color(0xFF1E0447),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String count;
  final Color countColor;
  final Color countBg;
  final Color countBorder;
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

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
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

// ─── Incident Card ────────────────────────────────────────────────────────────
class _IncidentCard extends StatelessWidget {
  final EmergencyItem item;
  final VoidCallback onTap;
  final VoidCallback onAdvance;
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

// ─── Action Button ────────────────────────────────────────────────────────────
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

// ─── Stepper ──────────────────────────────────────────────────────────────────
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

// ─── Resolved Card ────────────────────────────────────────────────────────────
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

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
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
  final String label;
  final String value;
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

Route _instantRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, _, _) => page,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);
