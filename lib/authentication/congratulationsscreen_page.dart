import 'package:flutter/material.dart';

import 'app_colors.dart';

// ─── CONGRATULATIONS SCREEN ───────────────────────────────────────────────────

class CongratulationsScreen extends StatelessWidget {
  final String firstName;

  const CongratulationsScreen({super.key, required this.firstName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Hero Section ───────────────────────────────────────────
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A1DD6),
                    Color(0xFF8B2CF5),
                    Color(0xFFAA5FF7),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Layered rings + checkmark
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 148,
                          height: 148,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.13),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Congratulations! 🎉',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your account is all set,\n$firstName. Welcome aboard!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                          color: Colors.white.withOpacity(0.80),
                          height: 1.55,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Section ─────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
              child: Column(
                children: [
                  // Stats row
                  const Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          icon: Icons.verified_rounded,
                          color: Color(0xFF34C759),
                          label: 'Verified',
                          value: 'Account',
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _StatChip(
                          icon: Icons.lock_rounded,
                          color: AppColors.primary,
                          label: 'Secured',
                          value: 'Profile',
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _StatChip(
                          icon: Icons.bolt_rounded,
                          color: Color(0xFFFF9500),
                          label: 'Ready',
                          value: 'To Use',
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Text(
                    'Start exploring all the features\navailable in your new account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.6,
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Get started button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to dashboard/home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STAT CHIP ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
