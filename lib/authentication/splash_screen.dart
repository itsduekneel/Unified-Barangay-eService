import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'widgets/landscape_painter.dart';

// ─── WELCOME LOADING SCREEN ──────────────────────────────────────────────────

class WelcomeLoadingScreen extends StatefulWidget {
  final Widget nextScreen;

  const WelcomeLoadingScreen({super.key, required this.nextScreen});

  @override
  State<WelcomeLoadingScreen> createState() => _WelcomeLoadingScreenState();
}

class _WelcomeLoadingScreenState extends State<WelcomeLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start splash after first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSplash());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _pulseController.dispose();
    super.dispose();
  }

  // ── Splash logic ───────────────────────────────────────────────────────────

  Future<void> _startSplash() async {
    // Rule 3: Check internet FIRST before starting the timer
    final hasNet = await _hasInternet();
    if (!mounted) return;

    if (!hasNet) {
      // Show dialog — retry will call _startSplash() again
      await _showNoInternetDialog();
      return;
    }

    // Rule 2: Wait 6 seconds then navigate
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => widget.nextScreen));
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showNoInternetDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NoInternetDialog(
        onRetry: () {
          Navigator.of(context).pop();
          _startSplash(); // retry from scratch
        },
        onExit: () => SystemNavigator.pop(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Landscape occupies the bottom 35% of the screen
    final landscapeHeight = screenHeight * 0.35;
    // Upper content area is the remaining 65%
    final contentHeight = screenHeight - landscapeHeight;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          // ── Landscape pinned to bottom, full width ───────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LandscapeBackground(height: landscapeHeight),
          ),

          // ── Upper content: icon + text centered ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: contentHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: const _IconWithRings(),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Unified Barangay eService',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Connecting People, building together",
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ],
            ),
          ),

          // ── Spinner at boundary between content and landscape ────────────
          Positioned(
            top: contentHeight - 10,
            left: 0,
            right: 0,
            child: const Center(
              child: SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  color: Color(0xFF8B2CF5),
                  strokeWidth: 3.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── NO INTERNET DIALOG ───────────────────────────────────────────────────────

class _NoInternetDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _NoInternetDialog({required this.onRetry, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Internet Connection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your Wi-Fi or mobile data\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            // Try Again
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Exit
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: onExit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Exit', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ICON WITH CONCENTRIC RINGS ──────────────────────────────────────────────

class _IconWithRings extends StatelessWidget {
  const _IconWithRings();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring 3 – outermost
          _Ring(size: 210, opacity: 0.07),
          // Ring 2
          _Ring(size: 160, opacity: 0.11),
          // Ring 1 – innermost
          _Ring(size: 116, opacity: 0.16),

          // Floating dots
          const _Dot(top: 42, left: 48, size: 7),
          const _Dot(top: 65, right: 30, size: 5),
          const _Dot(bottom: 52, left: 32, size: 5),
          const _Dot(bottom: 38, right: 54, size: 8),

          // App icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset('assets/app_icon.png', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RING ─────────────────────────────────────────────────────────────────────

class _Ring extends StatelessWidget {
  final double size;
  final double opacity;
  const _Ring({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── DOT ──────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;

  const _Dot({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
    );
  }
}
