import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../widgets/quick_action_card.dart';
import '../../emergency/screens/emergency_request_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Header Section ───────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Good Morning,',
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            user?.firstName ?? 'Resident',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // ─── Floating Resident Card ──────────────────────────────────
                Positioned(
                  bottom: -35,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.role.name.toUpperCase() ?? 'RESIDENT',
                                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                              ),
                              const Text(
                                'Verified Community Member',
                                style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // ─── Quick Actions Grid ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Services',
                    style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      QuickActionCard(
                        title: 'Documents',
                        icon: Icons.description_rounded,
                        color: AppColors.info,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Emergency',
                        icon: Icons.emergency_rounded,
                        color: AppColors.error,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EmergencyRequestScreen()),
                        ),
                      ),
                      QuickActionCard(
                        title: 'Appointment',
                        icon: Icons.event_note_rounded,
                        color: AppColors.warning,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Incident',
                        icon: Icons.report_problem_rounded,
                        color: AppColors.primary,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
