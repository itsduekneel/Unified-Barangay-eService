import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ube/features/emergency_request_page.dart';
import 'package:ube/authentication/app_colors.dart';

final supabase = Supabase.instance.client;

const _kDefaultLat = 14.1668;
const _kDefaultLng = 121.2420;

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
      color: AppColors.red,
      bg: AppColors.redBg,
    ),
    EmergencyType(
      label: 'Fire',
      sub: 'Fire · Smoke',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.orange,
      bg: AppColors.orangeBg,
    ),
    EmergencyType(
      label: 'Security',
      sub: 'Theft · Danger',
      icon: Icons.shield_outlined,
      color: AppColors.primary,
      bg: AppColors.primaryLight,
    ),
    EmergencyType(
      label: 'Flood',
      sub: 'Water · Storm',
      icon: Icons.water_outlined,
      color: AppColors.blue,
      bg: AppColors.blueBg,
    ),
  ];

  Future<void> _handleEmergency() async {
    if (_selectedType == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // ── 1. Kumuha ng position — last known muna (instant), fallback sa default
      Position? position;

      try {
        if (await Geolocator.isLocationServiceEnabled()) {
          var perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }

          if (perm == LocationPermission.always ||
              perm == LocationPermission.whileInUse) {
            // Fast path — walang GPS spin-up, instant
            position = await Geolocator.getLastKnownPosition();
          }
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }

      // ── 2. I-insert sa Supabase gamit ang best available location
      final response = await supabase
          .from('emergency_incidents')
          .insert({
            'type': _selectedType!.label,
            'level':
                (_selectedType!.label == 'Medical' ||
                    _selectedType!.label == 'Fire')
                ? 'critical'
                : 'high',
            'location': 'Current Location',
            'reported_by': supabase.auth.currentUser?.id ?? 'Anonymous',
            'description': 'Emergency alert activated via app.',
            'step': 0,
            'map_lat': position?.latitude ?? _kDefaultLat,
            'map_lng': position?.longitude ?? _kDefaultLng,
          })
          .select()
          .single();

      if (!mounted) return;

      final incidentId = response['id'] as String;

      // ── 3. Pumunta sa request page agad — hindi naghihintay sa accurate fix
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => EmergencyRequestPage(
            incidentId: incidentId,
            emergencyLabel: _selectedType!.label,
            emergencySub: _selectedType!.sub,
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );

      // ── 4. I-update ang map_lat/map_lng sa background pag dumating accurate fix
      //    Hindi na naghihintay ang user — nasa request page na siya
      _updateLocationInBackground(incidentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send alert: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _updateLocationInBackground(String incidentId) {
    Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        )
        .then((pos) async {
          // I-update ang Supabase — ang EmergencyRequestPage stream
          // ay awtomatikong makakakita ng bagong lat/lng
          await supabase
              .from('emergency_incidents')
              .update({'map_lat': pos.latitude, 'map_lng': pos.longitude})
              .eq('id', incidentId);
        })
        .catchError((e) {
          debugPrint('Background location update failed: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _selectedType != null && !_isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Select Emergency Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? type.bg : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? type.color : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      type.icon,
                      color: selected ? type.color : AppColors.textGrey,
                      size: 24,
                    ),
                    const Spacer(),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: selected ? type.color : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.sub,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? type.color.withValues(alpha: 0.8)
                            : AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isReady || _isSubmitting
                      ? _selectedType?.bg ?? AppColors.bgColor
                      : AppColors.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isReady || _isSubmitting
                      ? _selectedType?.icon ?? Icons.info_outline_rounded
                      : Icons.info_outline_rounded,
                  size: 20,
                  color: isReady || _isSubmitting
                      ? _selectedType?.color ?? AppColors.textGrey
                      : AppColors.textGrey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isSubmitting
                    ? const Text(
                        'Sending urgent alert...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : isReady
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedType!.label} Alert Ready',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Text(
                            'Slide the button below to confirm',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Select an emergency type to continue',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const EmergencyRequestGuidelines(),
        const SizedBox(height: 24),

        SmoothSlideButton(
          enabled: isReady,
          onActivate: _handleEmergency,
          emergencyRed: AppColors.red,
          successGreen: AppColors.green,
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'How it works',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GuidelineItem(
            icon: Icons.swipe_right_rounded,
            text: 'Slide to activate emergency alert',
          ),
          _GuidelineItem(
            icon: Icons.location_on_rounded,
            text: 'Your real-time location will be shared',
          ),
          _GuidelineItem(
            icon: Icons.notification_important_rounded,
            text: 'Authorized responders will be notified',
          ),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _GuidelineItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMedium),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    const double sliderHeight = 60;
    const double handleWidth = 60;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxSlide = constraints.maxWidth - handleWidth;
        final bool nearEnd = _dragPercent > 0.9;

        return AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.5,
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
                    if (_dragPercent >= 1.0 && !_activated) {
                      widget.onActivate();
                    }
                    setState(() {
                      _activated = false;
                      _dragPercent = 0;
                    });
                  }
                : null,
            child: Container(
              height: sliderHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: nearEnd
                    ? AppColors.greenBg
                    : AppColors.border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      !widget.enabled
                          ? 'Select emergency type'
                          : nearEnd
                          ? 'Release to confirm alert'
                          : 'Slide to activate alert',
                      style: TextStyle(
                        color: nearEnd ? AppColors.green : AppColors.textGrey,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
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
                    child: Container(
                      width: handleWidth,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          widget.emergencyRed,
                          widget.successGreen,
                          _dragPercent,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(2, 0),
                          ),
                        ],
                      ),
                      child: Icon(
                        nearEnd
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 22,
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
