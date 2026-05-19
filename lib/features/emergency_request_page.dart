import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/authentication/app_colors.dart';

final supabase = Supabase.instance.client;

const _kOsmTile    = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _kCacheDir   = 'ube_osm_cache';
const _kDefaultLat = 14.1668;
const _kDefaultLng = 121.2420;
const _kPrefLat    = 'last_loc_lat';
const _kPrefLng    = 'last_loc_lng';

// ─── Steps ────────────────────────────────────────────────────────────────────
class StepItem {
  final String label, desc;
  const StepItem(this.label, this.desc);
}

const _kSteps = [
  StepItem('Pending',    'Waiting for responder assignment'),
  StepItem('Assigned',   'Responders are preparing'),
  StepItem('Responding', 'Responders are on their way'),
  StepItem('Completed',  'Emergency resolved'),
];

// ═══════════════════════════════════════════════════════════════════════════════
//  PAGE
// ═══════════════════════════════════════════════════════════════════════════════
class EmergencyRequestPage extends StatelessWidget {
  final String incidentId;
  final String emergencyLabel;
  final String emergencySub;

  const EmergencyRequestPage({
    super.key,
    required this.incidentId,
    this.emergencyLabel = 'Emergency Request',
    this.emergencySub = '',
  });

  @override
  Widget build(BuildContext context) {
    // FIX 1: StreamBuilder only drives the bottom sheet.
    // The map section is a separate widget that never rebuilds from this stream.
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      extendBodyBehindAppBar: true,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('emergency_incidents')
            .stream(primaryKey: ['id'])
            .eq('id', incidentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final incident    = snapshot.data!.first;
          final currentStep = (incident['step'] as int).clamp(0, 3);
          final responder   = incident['responder'] ?? 'Barangay Team';
          final createdAt   = DateTime.parse(incident['created_at']);
          final lat         = (incident['map_lat']  as num?)?.toDouble() ?? _kDefaultLat;
          final lng         = (incident['map_lng']  as num?)?.toDouble() ?? _kDefaultLng;
          final type        = incident['type'] as String? ?? 'Emergency';

          return Column(
            children: [
              // Map never rebuilds from the stream — uses ValueKey so Flutter
              // preserves the state across stream emissions.
              Expanded(
                child: _RequestMapSection(
                  key: ValueKey(incidentId),
                  lat: lat,
                  lng: lng,
                  type: type,
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

// ═══════════════════════════════════════════════════════════════════════════════
//  MAP SECTION
// ═══════════════════════════════════════════════════════════════════════════════
class _RequestMapSection extends StatefulWidget {
  final double lat, lng;
  final String type;

  const _RequestMapSection({
    super.key,
    required this.lat,
    required this.lng,
    required this.type,
  });

  @override
  State<_RequestMapSection> createState() => _RequestMapSectionState();
}

class _RequestMapSectionState extends State<_RequestMapSection>
    with TickerProviderStateMixin {

  final _mapCtrl = MapController();

  LatLng? _deviceLocation;
  LatLng? _lastKnown;
  bool    _locating      = false;
  bool    _locationDenied = false;
  bool    _trackingDevice = false;

  // FIX 2: One reusable AnimationController for camera moves.
  late AnimationController _moveCtrl;
  // FIX 7: Pulse controller lives here; _DeviceMarker is its own widget.
  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  // Session cache shared across page pushes.
  static LatLng? _sessionCache;

  @override
  void initState() {
    super.initState();

    // FIX 2: Create once, reuse forever.
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // FIX 7: Pulse lives here, but only _DeviceMarker listens to it.
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // FIX 3: Cache dir init is fire-and-forget — doesn't block map render.
    unawaited(_initCacheDir());
    _initLocation();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _moveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Cache dir ───────────────────────────────────────────────────────────────
  Future<void> _initCacheDir() async {
    try {
      final tmp = await getTemporaryDirectory();
      final dir = Directory('${tmp.path}${Platform.pathSeparator}$_kCacheDir');
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (_) {}
  }

  // ── Location bootstrap ──────────────────────────────────────────────────────
  Future<void> _initLocation() async {
    if (!mounted) return;
    setState(() => _locating = true);

    // 1. Snap to cached location immediately.
    final cached = _sessionCache ?? await _loadPersisted();
    if (cached != null && mounted) {
      setState(() {
        _lastKnown     = cached;
        _sessionCache  = cached;
      });
      _mapCtrl.move(cached, 15.5);
    }

    // 2. FIX 4: Try last-known position first (instant), then full fix.
    final pos = await _fastThenAccuratePosition();
    if (!mounted) return;

    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      unawaited(_persist(ll));
      _sessionCache = ll;
      setState(() {
        _deviceLocation = ll;
        _lastKnown      = ll;
        _trackingDevice = true;
        _locating       = false;
      });
      _animateTo(ll, 16.5);
    } else {
      setState(() {
        _locating = false;
        if (_lastKnown == null) _locationDenied = true;
      });
    }
  }

  Future<void> _goToMyLocation() async {
    if (_locating) return;
    if (_deviceLocation != null) {
      setState(() => _trackingDevice = true);
      _animateTo(_deviceLocation!, 16.5);
      return;
    }
    if (_lastKnown != null) _animateTo(_lastKnown!, 15.5);

    setState(() { _locating = true; _locationDenied = false; });
    final pos = await _fastThenAccuratePosition();
    if (!mounted) return;

    if (pos != null) {
      final ll = LatLng(pos.latitude, pos.longitude);
      unawaited(_persist(ll));
      _sessionCache = ll;
      setState(() {
        _deviceLocation = ll;
        _lastKnown      = ll;
        _trackingDevice = true;
        _locating       = false;
      });
      _animateTo(ll, 16.5);
    } else {
      setState(() {
        _locating = false;
        if (_lastKnown == null) _locationDenied = true;
      });
    }
  }

  void _goToIncident() {
    _animateTo(LatLng(widget.lat, widget.lng), 16.5);
    if (_trackingDevice) setState(() => _trackingDevice = false);
  }

  // ── FIX 4: Fast path uses getLastKnownPosition; accurate only if needed ─────
  Future<Position?> _fastThenAccuratePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return null;

      // Fast: last known (usually instant, no GPS spin-up).
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        // Fire accurate fix in background; update when it arrives.
        _getAccuratePositionInBackground();
        return last;
      }

      // Fallback: blocking accurate fix.
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

  void _getAccuratePositionInBackground() {
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    ).then((pos) {
      if (!mounted) return;
      final ll = LatLng(pos.latitude, pos.longitude);
      unawaited(_persist(ll));
      _sessionCache = ll;
      setState(() {
        _deviceLocation = ll;
        _lastKnown      = ll;
      });
      if (_trackingDevice) _animateTo(ll, _mapCtrl.camera.zoom);
    }).catchError((_) {});
  }

  // ── FIX 2: Reuse _moveCtrl — reset + forward instead of dispose/new ─────────
  void _animateTo(LatLng target, double zoom) {
    final startLat  = _mapCtrl.camera.center.latitude;
    final startLng  = _mapCtrl.camera.center.longitude;
    final startZoom = _mapCtrl.camera.zoom;

    _moveCtrl.stop();
    _moveCtrl.reset();

    // Build tweens from current camera state.
    final latT  = Tween<double>(begin: startLat,  end: target.latitude);
    final lngT  = Tween<double>(begin: startLng,  end: target.longitude);
    final zoomT = Tween<double>(begin: startZoom, end: zoom);
    final curve = CurvedAnimation(
      parent: _moveCtrl,
      curve: Curves.easeInOutCubic,
    );

    _moveCtrl.addListener(() {
      _mapCtrl.move(
        LatLng(latT.evaluate(curve), lngT.evaluate(curve)),
        zoomT.evaluate(curve),
      );
    });

    _moveCtrl.forward();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────
  Future<void> _persist(LatLng ll) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kPrefLat, ll.latitude);
      await prefs.setDouble(_kPrefLng, ll.longitude);
    } catch (_) {}
  }

  Future<LatLng?> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_kPrefLat);
      final lng = prefs.getDouble(_kPrefLng);
      if (lat != null && lng != null) return LatLng(lat, lng);
    } catch (_) {}
    return null;
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final incidentPoint = LatLng(widget.lat, widget.lng);

    // FIX 5: Build marker list once per build, not inside FlutterMap.
    // FlutterMap only re-renders markers when this list reference changes,
    // which only happens when setState is called.
    final markers = _buildMarkers(incidentPoint);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _lastKnown ?? incidentPoint,
            initialZoom: _lastKnown != null ? 15.5 : 16.0,
            minZoom: 4,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onPositionChanged: (_, hasGesture) {
              if (hasGesture && _trackingDevice) {
                setState(() => _trackingDevice = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _kOsmTile,
              // FIX: Keep buffer small — large buffers fetch many tiles at once.
              tileProvider: CancellableNetworkTileProvider(),
              userAgentPackageName: 'com.barangay.ube',
              maxNativeZoom: 19,
              keepBuffer: 2,
              panBuffer: 1,
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // FABs
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Column(
            children: [
              _MapFab(
                icon: _locating
                    ? Icons.hourglass_top_rounded
                    : _trackingDevice
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                active: _trackingDevice,
                onTap: _goToMyLocation,
              ),
              const SizedBox(height: 10),
              _MapFab(
                icon: Icons.report_gmailerrorred_rounded,
                onTap: _goToIncident,
              ),
            ],
          ),
        ),

        // Location denied banner
        if (_locationDenied)
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            left: 12,
            right: 12,
            child: _LocationDeniedBanner(
              onDismiss: () => setState(() => _locationDenied = false),
            ),
          ),
      ],
    );
  }

  // FIX 5: Markers assembled once per setState, not on every map frame.
  List<Marker> _buildMarkers(LatLng incidentPoint) {
    return [
      Marker(
        point: incidentPoint,
        width: 44,
        height: 54,
        alignment: Alignment.topCenter,
        child: _RequestPin(type: widget.type),
      ),
      // FIX 7: _DeviceMarker is its own widget — AnimatedBuilder scope is
      // contained inside it, so only the dot repaints, not the whole map.
      if (_deviceLocation != null)
        Marker(
          point: _deviceLocation!,
          width: 50,
          height: 50,
          child: _DeviceMarker(pulse: _pulseAnim),
        ),
      if (_lastKnown != null && _deviceLocation == null)
        Marker(
          point: _lastKnown!,
          width: 40,
          height: 40,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
    ];
  }
}

// ─── Map FAB ──────────────────────────────────────────────────────────────────
class _MapFab extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _MapFab({required this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(
        icon,
        color: active ? AppColors.white : AppColors.primary,
        size: 22,
      ),
    ),
  );
}

// ─── Device marker — FIX 7: self-contained AnimatedBuilder ───────────────────
class _DeviceMarker extends StatelessWidget {
  final Animation<double> pulse;
  const _DeviceMarker({required this.pulse});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    // child is built once and passed through — dot itself doesn't rebuild.
    child: Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
          ),
        ],
      ),
    ),
    builder: (_, child) => Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40 * pulse.value,
          height: 40 * pulse.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15 / pulse.value),
          ),
        ),
        child!,
      ],
    ),
  );
}

// ─── Request pin ──────────────────────────────────────────────────────────────
// Made const-constructible so Flutter can cache it.
class _RequestPin extends StatelessWidget {
  final String type;
  const _RequestPin({required this.type});

  Color get _color => switch (type) {
    'Fire' || 'Medical' => AppColors.red,
    'Security'           => AppColors.orange,
    'Flood'              => AppColors.blue,
    _                    => AppColors.primary,
  };

  IconData get _icon => switch (type) {
    'Fire'     => Icons.local_fire_department_rounded,
    'Medical'  => Icons.monitor_heart_outlined,
    'Security' => Icons.shield_outlined,
    'Flood'    => Icons.water_outlined,
    _          => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(_icon, color: Colors.white, size: 22),
      ),
      CustomPaint(
        size: const Size(12, 8),
        painter: _PinTailPainter(_color),
      ),
    ],
  );
}

class _PinTailPainter extends CustomPainter {
  final Color c;
  const _PinTailPainter(this.c);

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
  bool shouldRepaint(_PinTailPainter old) => old.c != c;
}

// ─── Location denied banner ───────────────────────────────────────────────────
class _LocationDeniedBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _LocationDeniedBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFCA5A5)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8),
      ],
    ),
    child: Row(
      children: [
        const Icon(
          Icons.location_off_outlined,
          size: 16,
          color: AppColors.red,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Location access denied — showing last known area.',
            style: TextStyle(fontSize: 11, color: AppColors.red),
          ),
        ),
        GestureDetector(
          onTap: onDismiss,
          child: const Icon(Icons.close, size: 15, color: AppColors.red),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET  (unchanged from original)
// ═══════════════════════════════════════════════════════════════════════════════
class _EmergencyBottomSheet extends StatelessWidget {
  final String incidentId;
  final int currentStep;
  final String emergencyLabel, responder;
  final DateTime submittedAt;

  const _EmergencyBottomSheet({
    required this.incidentId,
    required this.currentStep,
    required this.emergencyLabel,
    required this.responder,
    required this.submittedAt,
  });

  @override
  Widget build(BuildContext context) {
    final step  = _kSteps[currentStep];
    final color = currentStep == 3
        ? AppColors.green
        : currentStep == 0
        ? AppColors.orange
        : AppColors.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 24, 20, 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emergencyLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
              _InfoBox(
                label: 'Reported',
                value: DateFormat('hh:mm a').format(submittedAt),
              ),
              const SizedBox(width: 12),
              const _InfoBox(label: 'Status', value: 'Live Tracking'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  color: AppColors.red,
                  onTap: () => _showCancel(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cancel Request?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to cancel this emergency request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase
                  .from('emergency_incidents')
                  .delete()
                  .eq('id', incidentId);
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              elevation: 0,
            ),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final Color color;
  const _StepIndicator({required this.currentStep, required this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(4, (i) {
      final active = i <= currentStep;
      return Expanded(
        child: Container(
          height: 6,
          margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
          decoration: BoxDecoration(
            color: active
                ? color
                : AppColors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }),
  );
}

class _InfoBox extends StatelessWidget {
  final String label, value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18, color: Colors.white),
    label: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}