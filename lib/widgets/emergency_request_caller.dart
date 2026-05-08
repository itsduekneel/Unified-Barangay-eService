import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/features/emergency_request_page.dart';

final supabase = Supabase.instance.client;

const _kPrimary = Color(0xFF8B2CF5);
const _kPrimaryDark = Color(0xFF3B1278);
const _kPrimaryMid = Color(0xFFC4B5FD);
const _kPrimaryLight = Color(0xFFEDE9FE);
const _kSurface = Color(0xFFF4F0FB);
const _kBorder = Color(0xFFE9D5FF);

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      appBar: AppBar(
        title: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 50, 25, 20),
          child: EmergencyRequestCaller(),
        ),
      ),
    );
  }
}

class EmergencyRequestCaller extends StatefulWidget {
  const EmergencyRequestCaller({super.key});

  @override
  State<EmergencyRequestCaller> createState() => _EmergencyRequestCallerState();
}

class _EmergencyRequestCallerState extends State<EmergencyRequestCaller> {
  EmergencyType? _selectedType;
  bool _isSubmitting = false;

  final List<EmergencyType> _types = [
    EmergencyType(
      label: 'Medical',
      sub: 'Injury · Illness',
      icon: Icons.monitor_heart_outlined,
      color: _kPrimary,
      bg: _kPrimaryLight,
    ),
    EmergencyType(
      label: 'Fire',
      sub: 'Fire · Smoke',
      icon: const IconData(0xe29c, fontFamily: 'MaterialIcons'), // Icons.local_fire_department_outlined
      color: const Color(0xFFF59E0B),
      bg: const Color(0xFFFFF7ED),
    ),
    EmergencyType(
      label: 'Security',
      sub: 'Theft · Danger',
      icon: Icons.shield_outlined,
      color: const Color(0xFFEF4444),
      bg: const Color(0xFFFEF2F2),
    ),
    EmergencyType(
      label: 'Flood',
      sub: 'Water · Storm',
      icon: Icons.water_outlined,
      color: const Color(0xFF22C55E),
      bg: const Color(0xFFF0FDF4),
    ),
  ];

  Future<void> _handleEmergency() async {
    if (_selectedType == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Get Location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        debugPrint('Location error: $e');
      }

      // 2. Push to Supabase
      final response = await supabase.from('emergency_incidents').insert({
        'type': _selectedType!.label,
        'level': _selectedType!.label == 'Medical' || _selectedType!.label == 'Fire' ? 'critical' : 'high',
        'location': 'Current Location',
        'reported_by': 'Resident User', // Should ideally come from Auth
        'description': 'Emergency alert activated via app.',
        'step': 0,
        'map_lat': position?.latitude ?? 14.1668,
        'map_lng': position?.longitude ?? 121.2420,
      }).select().single();

      if (!mounted) return;

      // 3. Navigate to Request Page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              EmergencyRequestPage(
                incidentId: response['id'],
                emergencyLabel: _selectedType!.label,
                emergencySub: _selectedType!.sub,
              ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send alert: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _selectedType != null && !_isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select emergency type',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kPrimary,
          ),
        ),
        const SizedBox(height: 10),

        /// GRID
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: _types.map((type) {
            final selected = _selectedType == type;

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEEECFD) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? const Color(0xFF8B2CF5) : const Color(0xFFE4E2F7),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (!selected)
                      const BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      type.icon,
                      color: selected ? const Color(0xFF8B2CF5) : const Color(0xFF9490B0),
                      size: 22,
                    ),
                    const Spacer(),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? const Color(0xFF8B2CF5) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.sub,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9490B0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        /// PREVIEW
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder, width: 0.5),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isReady || _isSubmitting ? _selectedType?.bg ?? const Color(0xFFF3F0FB) : const Color(0xFFF3F0FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isReady || _isSubmitting ? _selectedType?.icon ?? Icons.info_outline_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: isReady || _isSubmitting ? _selectedType?.color ?? _kPrimaryMid : _kPrimaryMid,
                ),
              ),
              const SizedBox(width: 10),

              _isSubmitting
                  ? const Text('Sending alert...', style: TextStyle(fontSize: 12, color: _kPrimary))
                  : isReady
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_selectedType!.label} emergency',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kPrimaryDark,
                              ),
                            ),
                            const Text(
                              'Responder: Tanod',
                              style: TextStyle(fontSize: 11, color: _kPrimary),
                            ),
                          ],
                        )
                      : const Text(
                          'Select a type to continue...',
                          style: TextStyle(fontSize: 12, color: Color(0xFFA8A8B0)),
                        ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        const EmergencyRequestGuidelines(),
        const SizedBox(height: 12),

        /// SLIDE BUTTON
        SmoothSlideButton(
          enabled: isReady,
          onActivate: _handleEmergency,
          emergencyRed: const Color(0xFFEF4444),
          successGreen: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

class EmergencyType {
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final Color bg;

  const EmergencyType({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

class EmergencyRequestGuidelines extends StatelessWidget {
  const EmergencyRequestGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ IMPORTANT FIX
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 10),

          Text(
            '1. Slide to activate emergency alert',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 6),

          Text(
            '2. Share your real-time location',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 6),

          Text(
            '3. Nearest responders get notified',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SMOOTH SLIDE BUTTON
// ─────────────────────────────────────────
class SmoothSlideButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onActivate;
  final Color emergencyRed;
  final Color successGreen;

  const SmoothSlideButton({
    super.key,
    required this.enabled,
    required this.onActivate,
    required this.emergencyRed,
    required this.successGreen,
  });

  @override
  State<SmoothSlideButton> createState() => _SmoothSlideButtonState();
}

class _SmoothSlideButtonState extends State<SmoothSlideButton> {
  double _dragPercent = 0;
  bool _activated = false;

  @override
  void didUpdateWidget(SmoothSlideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && oldWidget.enabled) {
      setState(() {
        _dragPercent = 0;
        _activated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double sliderHeight = 55;
    const double handleWidth = 55;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSlide = constraints.maxWidth - handleWidth;
        final bool nearEnd = _dragPercent > 0.9;

        return AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onHorizontalDragUpdate: widget.enabled && !_activated
                ? (details) {
                    setState(() {
                      _dragPercent =
                          (_dragPercent + details.delta.dx / maxSlide).clamp(
                            0.0,
                            1.0,
                          );
                    });
                  }
                : null,
            onHorizontalDragEnd: widget.enabled
                ? (_) {
                    final shouldActivate = _dragPercent >= 1.0;

                    if (shouldActivate && !_activated) {
                      widget.onActivate();
                    }

                    // ALWAYS RESET (smooth animation)
                    setState(() {
                      _activated = false;
                      _dragPercent = 0;
                    });
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: sliderHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: nearEnd ? Colors.green.shade50 : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      !widget.enabled
                          ? 'Select a type first'
                          : nearEnd
                          ? 'Release to Send Alert'
                          : 'Slide to Activate Emergency Alert',
                      style: TextStyle(
                        color: nearEnd
                            ? widget.successGreen
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  AnimatedPositioned(
                    duration: _dragPercent == 0
                        ? const Duration(milliseconds: 250)
                        : Duration.zero,
                    curve: Curves.easeOut,
                    left: _dragPercent * maxSlide,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: handleWidth,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          widget.emergencyRed,
                          widget.successGreen,
                          _dragPercent,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        nearEnd
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
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
}
