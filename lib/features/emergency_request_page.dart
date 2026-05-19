import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final supabase = Supabase.instance.client;

const _kOsmTile = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _kOsmCacheFolder = 'ube_osm_cache';

class StepItem {
  final String label, desc;
  const StepItem(this.label, this.desc);
}

const _kSteps = [
  StepItem('Pending', 'Waiting for responder assignment'),
  StepItem('Assigned', 'Responders are preparing'),
  StepItem('Responding', 'Responders are on their way'),
  StepItem('Completed', 'Emergency resolved'),
];

class EmergencyRequestPage extends StatelessWidget {
  final String incidentId;
  final String emergencyLabel;
  final String emergencySub;

  const EmergencyRequestPage({super.key, required this.incidentId, this.emergencyLabel = 'Emergency Request', this.emergencySub = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      extendBodyBehindAppBar: true,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('emergency_incidents').stream(primaryKey: ['id']).eq('id', incidentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final incident   = snapshot.data!.first;
          final currentStep = (incident['step'] as int).clamp(0, 3);
          final responder   = incident['responder'] ?? 'Barangay Team';
          final createdAt   = DateTime.parse(incident['created_at']);

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
                currentStep: currentStep,
                emergencyLabel: incident['type'] ?? emergencyLabel,
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

class _RequestMapSection extends StatefulWidget {
  final double lat, lng;
  final String type;
  const _RequestMapSection({required this.lat, required this.lng, required this.type});

  @override
  State<_RequestMapSection> createState() => _RequestMapSectionState();
}

class _RequestMapSectionState extends State<_RequestMapSection> with TickerProviderStateMixin {
  final _mapCtrl = MapController();
  LatLng? _deviceLocation;
  bool _trackingDevice = true;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  StreamSubscription<Position>? _locSub;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.4).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _initLocation();
  }

  void _initLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _locSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        if (mounted) {
          final ll = LatLng(pos.latitude, pos.longitude);
          setState(() => _deviceLocation = ll);
          if (_trackingDevice) _mapCtrl.move(ll, _mapCtrl.camera.zoom);
        }
      });
    }
  }

  @override
  void dispose() {
    _mapCtrl.dispose(); _pulseCtrl.dispose(); _locSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentPoint = LatLng(widget.lat, widget.lng);
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: incidentPoint,
            initialZoom: 16,
            onPositionChanged: (_, hasGesture) { if (hasGesture) setState(() => _trackingDevice = false); },
          ),
          children: [
            TileLayer(
              urlTemplate: _kOsmTile,
              tileProvider: CancellableNetworkTileProvider(),
              userAgentPackageName: 'com.barangay.ube',
            ),
            MarkerLayer(markers: [
              Marker(point: incidentPoint, width: 44, height: 54, alignment: Alignment.topCenter, child: _RequestPin(type: widget.type)),
              if (_deviceLocation != null)
                Marker(point: _deviceLocation!, width: 50, height: 50, child: _DeviceMarker(pulse: _pulseAnim)),
            ]),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Column(
            children: [
              _MapFab(icon: Icons.my_location_rounded, active: _trackingDevice, onTap: () {
                setState(() => _trackingDevice = true);
                if (_deviceLocation != null) _mapCtrl.move(_deviceLocation!, 16);
              }),
              const SizedBox(height: 10),
              _MapFab(icon: Icons.report_gmailerrorred_rounded, onTap: () => _mapCtrl.move(incidentPoint, 16)),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: active ? AppColors.white : AppColors.primary, size: 22),
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
    builder: (_, __) => Stack(alignment: Alignment.center, children: [
      Container(width: 40 * pulse.value, height: 40 * pulse.value, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15 / pulse.value))),
      Container(width: 14, height: 14, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8)])),
    ]),
  );
}

class _RequestPin extends StatelessWidget {
  final String type;
  const _RequestPin({required this.type});

  Color get _color => switch (type) {
    'Fire' || 'Medical' => AppColors.red,
    'Security' => AppColors.orange,
    'Flood' => AppColors.blue,
    _ => AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: _color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: _color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]),
        child: Icon(switch (type) {
          'Fire' => Icons.local_fire_department_rounded,
          'Medical' => Icons.monitor_heart_outlined,
          'Security' => Icons.shield_outlined,
          'Flood' => Icons.water_outlined,
          _ => Icons.warning_amber_rounded,
        }, color: Colors.white, size: 22),
      ),
      CustomPaint(size: const Size(12, 8), painter: _PinTailPainter(_color)),
    ]);
  }
}

class _PinTailPainter extends CustomPainter {
  final Color c;
  _PinTailPainter(this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final p = ui.Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    canvas.drawPath(p, ui.Paint()..color = c);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _EmergencyBottomSheet extends StatelessWidget {
  final String incidentId;
  final int currentStep;
  final String emergencyLabel, responder;
  final DateTime submittedAt;

  const _EmergencyBottomSheet({required this.incidentId, required this.currentStep, required this.emergencyLabel, required this.responder, required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    final step = _kSteps[currentStep];
    final color = currentStep == 3 ? AppColors.green : (currentStep == 0 ? AppColors.orange : AppColors.primary);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28)), boxShadow: [BoxShadow(color: Color(0x10000000), blurRadius: 20, offset: Offset(0, -5))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emergencyLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(step.desc, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              _StatusBadge(label: step.label, color: color),
            ],
          ),
          const SizedBox(height: 24),
          _StepIndicator(currentStep: currentStep, color: color),
          const SizedBox(height: 24),
          Row(
            children: [
              _InfoBox(label: 'Responder', value: responder),
              const SizedBox(width: 12),
              _InfoBox(label: 'Reported', value: DateFormat('hh:mm a').format(submittedAt)),
              const SizedBox(width: 12),
              const _InfoBox(label: 'Status', value: 'Live Tracking'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _ActionBtn(icon: Icons.call_rounded, label: 'Call', color: AppColors.primary, onTap: () {})),
              const SizedBox(width: 12),
              Expanded(child: _ActionBtn(icon: Icons.close_rounded, label: 'Cancel', color: AppColors.red, onTap: () => _showCancel(context))),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancel(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Cancel Request?', style: TextStyle(fontWeight: FontWeight.w800)),
      content: const Text('Are you sure you want to cancel this emergency request?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No', style: TextStyle(color: AppColors.textGrey))),
        ElevatedButton(onPressed: () async {
          await supabase.from('emergency_incidents').delete().eq('id', incidentId);
          if (context.mounted) { Navigator.pop(ctx); Navigator.pop(context); }
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, elevation: 0), child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final Color color;
  const _StepIndicator({required this.currentStep, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final active = i <= currentStep;
    return Expanded(child: Container(height: 6, margin: EdgeInsets.only(right: i == 3 ? 0 : 8), decoration: BoxDecoration(color: active ? color : AppColors.border.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10))));
      }),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    );
  }
}
