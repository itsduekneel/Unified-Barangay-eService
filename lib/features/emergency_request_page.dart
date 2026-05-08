import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// ─── OSM ─────────────────────────────────────────────────────────────────────
const _kOsmTile = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _kOsmCacheFolder = 'ube_osm_cache';
const _kDefaultLat = 14.1668;
const _kDefaultLng = 121.2420;

// ─── Theme ────────────────────────────────────────────────────────────────────
class _T {
  static const purple = Color(0xFF8B2CF5);
  static const purpleLight = Color(0xFFEDE9FE);
  static const purpleSoft = Color(0xFFFAF8FF);
  static const purpleBorder = Color(0xFFE9D5FF);

  // Step-aware status colors
  static Color statusColor(int step) => switch (step) {
    0 => const Color(0xFFF59E0B), // amber  – Pending
    1 => const Color(0xFF3B82F6), // blue   – Assigned
    2 => const Color(0xFFF97316), // orange – Responding
    _ => const Color(0xFF22C55E), // green  – Completed
  };
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class StepItem {
  final String label;
  final String desc;
  const StepItem(this.label, this.desc);
}

const _kSteps = [
  StepItem('Pending', 'Waiting for admin to approve'),
  StepItem('Assigned', 'Responder team are preparing'),
  StepItem('Responding', 'Responder team is on the way'),
  StepItem('Completed', 'Responder operation successful'),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class EmergencyRequestPage extends StatelessWidget {
  final String incidentId;
  final String emergencyLabel;
  final String emergencySub;

  const EmergencyRequestPage({
    super.key,
    required this.incidentId,
    this.emergencyLabel = 'Emergency Request',
    this.emergencySub = 'No details provided',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('emergency_incidents')
            .stream(primaryKey: ['id'])
            .eq('id', incidentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final incident = snapshot.data!.first;
          final currentStep = (incident['step'] as int).clamp(0, 3);
          final responder = incident['responder'] ?? 'Tanod';
          final createdAt = DateTime.parse(incident['created_at']);

          return Column(
            children: [
              Expanded(
                child: _RequestMapSection(
                  lat: incident['map_lat']?.toDouble() ?? 14.1668,
                  lng: incident['map_lng']?.toDouble() ?? 121.2420,
                  type: incident['type'] ?? 'Emergency',
                ),
              ),
              _EmergencyBottomSheet(
                incidentId: incidentId,
                steps: _kSteps,
                currentStep: currentStep,
                emergencyLabel: incident['type'] ?? emergencyLabel,
                emergencySub: emergencySub,
                responder: responder,
                submittedAt: createdAt,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Map Section ─────────────────────────────────────────────────────────────

class _RequestMapSection extends StatefulWidget {
  final double lat;
  final double lng;
  final String type;

  const _RequestMapSection({required this.lat, required this.lng, required this.type});

  @override
  State<_RequestMapSection> createState() => _RequestMapSectionState();
}

class _RequestMapSectionState extends State<_RequestMapSection> with TickerProviderStateMixin {
  final _mapCtrl = MapController();
  bool _cacheReady = false;
  LatLng? _deviceLocation;
  bool _trackingDevice = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<Position>? _locSub;

  @override
  void initState() {
    super.initState();
    _initPulse();
    _initCache();
    _initLocationTracking();
  }

  void _initPulse() {
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.55, end: 1.45)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  Future<void> _initCache() async {
    try {
      final tmp = await getTemporaryDirectory();
      final dir = Directory('${tmp.path}${Platform.pathSeparator}$_kOsmCacheFolder');
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (_) {}
    if (mounted) setState(() => _cacheReady = true);
  }

  void _initLocationTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _locSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        if (mounted) {
          final ll = LatLng(pos.latitude, pos.longitude);
          setState(() => _deviceLocation = ll);
          if (_trackingDevice) {
            _mapCtrl.move(ll, _mapCtrl.camera.zoom);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _pulseCtrl.dispose();
    _locSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cacheReady) {
      return const Center(child: CircularProgressIndicator(color: _T.purple));
    }

    final incidentPoint = LatLng(widget.lat, widget.lng);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: incidentPoint,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            onPositionChanged: (_, hasGesture) {
              if (hasGesture && _trackingDevice) {
                setState(() => _trackingDevice = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _kOsmTile,
              tileProvider: CancellableNetworkTileProvider(),
              userAgentPackageName: 'com.barangay.ube',
              maxNativeZoom: 19,
            ),
            // Incident Marker
            MarkerLayer(
              markers: [
                Marker(
                  point: incidentPoint,
                  width: 44,
                  height: 54,
                  alignment: Alignment.topCenter,
                  child: _RequestPin(type: widget.type),
                ),
              ],
            ),
            // Live Device Marker (Pulsing)
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
          ],
        ),
        // Controls
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Column(
            children: [
              _MapFab(
                icon: Icons.my_location,
                active: _trackingDevice,
                onTap: () {
                  setState(() => _trackingDevice = true);
                  if (_deviceLocation != null) {
                    _mapCtrl.move(_deviceLocation!, 16);
                  }
                },
              ),
              const SizedBox(height: 8),
              _MapFab(
                icon: Icons.report_gmailerrorred_rounded,
                onTap: () => _mapCtrl.move(incidentPoint, 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _MapFab({required this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? _T.purple : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
          border: Border.all(color: _T.purpleBorder, width: 0.5),
        ),
        child: Icon(icon, color: active ? Colors.white : _T.purple, size: 20),
      ),
    );
  }
}

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
              color: _T.purple.withOpacity(0.13 / pulse.value)),
        ),
        child!,
      ],
    ),
    child: Container(
      width: 16, height: 16,
      decoration: BoxDecoration(
        color: _T.purple,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [BoxShadow(color: _T.purple.withOpacity(0.4), blurRadius: 8)],
      ),
    ),
  );
}

class _RequestPin extends StatelessWidget {
  final String type;
  const _RequestPin({required this.type});

  Color get _color => switch (type) {
    'Fire' => const Color(0xFFEF4444),
    'Medical' => const Color(0xFFEF4444),
    'Security' => const Color(0xFFF59E0B),
    'Flood' => const Color(0xFF3B82F6),
    _ => _T.purple,
  };

  IconData get _icon => switch (type) {
    'Fire' => Icons.local_fire_department_outlined,
    'Medical' => Icons.monitor_heart_outlined,
    'Security' => Icons.shield_outlined,
    'Flood' => Icons.water_outlined,
    _ => Icons.warning_amber_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(_icon, color: Colors.white, size: 20),
        ),
        CustomPaint(
          size: const Size(10, 7),
          painter: _DropTailPainter(_color),
        ),
      ],
    );
  }
}

class _DropTailPainter extends CustomPainter {
  final Color c;
  _DropTailPainter(this.c);
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

// ─── Bottom sheet ─────────────────────────────────────────────────────────────

class _EmergencyBottomSheet extends StatelessWidget {
  final String incidentId;
  final List<StepItem> steps;
  final int currentStep;
  final String emergencyLabel;
  final String emergencySub;
  final String responder;
  final DateTime submittedAt;

  const _EmergencyBottomSheet({
    required this.incidentId,
    required this.steps,
    required this.currentStep,
    required this.emergencyLabel,
    required this.emergencySub,
    required this.responder,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EmergencyCard(
                  steps: steps,
                  currentStep: currentStep,
                  emergencyLabel: emergencyLabel,
                  emergencySub: emergencySub,
                  responder: responder,
                  submittedAt: submittedAt,
                ),
                const SizedBox(height: 12),
                _ActionButtonsRow(incidentId: incidentId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _EmergencyCard extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;
  final String emergencyLabel;
  final String emergencySub;
  final String responder;
  final DateTime submittedAt;

  const _EmergencyCard({
    required this.steps,
    required this.currentStep,
    required this.emergencyLabel,
    required this.emergencySub,
    required this.responder,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep.clamp(0, steps.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emergencyLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    emergencySub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(label: step.label, step: currentStep),
          ],
        ),
        const SizedBox(height: 14),
        _StepProgressBar(totalSteps: steps.length, currentStep: currentStep),
        const SizedBox(height: 6),
        // Step description below bar
        Text(
          step.desc,
          style: TextStyle(
            fontSize: 11,
            color: _T.statusColor(currentStep),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _InfoRow(submittedAt: submittedAt, responder: responder),
      ],
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final int step;

  const _StatusBadge({required this.label, required this.step});

  @override
  Widget build(BuildContext context) {
    final color = _T.statusColor(step);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const _StepProgressBar({required this.totalSteps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: active ? _T.statusColor(currentStep) : _T.purpleLight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Info chips row ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final DateTime submittedAt;
  final String responder;
  const _InfoRow({required this.submittedAt, required this.responder});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InfoChip(label: 'Responder', value: responder),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _InfoChip(
              label: 'Submitted',
              value: DateFormat('MMM dd, yyyy\nhh:mm a').format(submittedAt),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: const _InfoChip(label: 'Distance', value: '0.8 km'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: _T.purpleSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.purpleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _T.purple,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  final String incidentId;
  const _ActionButtonsRow({required this.incidentId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _ActionButton(
            icon: Icons.call_rounded,
            label: 'Call',
            variant: _ButtonVariant.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            variant: _ButtonVariant.outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.close_rounded,
            label: 'Cancel',
            variant: _ButtonVariant.destructive,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cancel Request?'),
                  content: const Text('Are you sure you want to cancel this emergency request?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
                  ],
                ),
              );
              if (confirmed == true) {
                await supabase.from('emergency_incidents').delete().eq('id', incidentId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }
}

enum _ButtonVariant { primary, outline, destructive }

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final _ButtonVariant variant;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.variant,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(24));
    const vPad = EdgeInsets.symmetric(vertical: 13);

    return switch (variant) {
      _ButtonVariant.primary => ElevatedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _T.purple,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
      _ButtonVariant.outline => OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: _T.purple),
        label: Text(
          label,
          style: const TextStyle(color: _T.purple, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _T.purple),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
      _ButtonVariant.destructive => OutlinedButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16, color: Colors.red.shade600),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade400),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: vPad,
        ),
      ),
    };
  }
}
