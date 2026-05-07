import 'package:flutter/material.dart';
import 'package:ube/features/appointment_request_page.dart';
import 'package:ube/features/emergency_page.dart';
import 'package:ube/features/user_management.dart';
import 'package:ube/features/services_page.dart';
import 'package:ube/widgets/quickactions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. TOP SECTION (Banner, Header, and Floating Card)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Purple Background Banner
                Container(
                  height: 250,
                  decoration: const BoxDecoration(color: Color(0xFF8B2CF5)),
                ),

                // Greeting and Date
                const Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: _HeaderSection(),
                ),

                // Floating Resident Card
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: _ResidentCard(
                    title: "Active Resident",
                    residentId: "ID: UBE-2024-0012345",
                    onViewProfile: () {
                      // Add your view profile logic here
                      debugPrint("View Profile Clicked");
                    },
                  ),
                ),
              ],
            ),

            // 2. BOTTOM SECTION (Quick Actions)
            // Added margin-top of 40 to account for the floating card overlay
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: _buildQuickActions(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Extracted Quick Actions to keep the main build method clean
  Widget _buildQuickActions(BuildContext context) {
    return QuickActionsContainer(
      actions: [
        QuickActionItem(
          title: 'User Management',
          icon: Icons.add_home_work_rounded,
          onTap: () =>
              Navigator.push(context, _instantRoute(const UserManagement())),
        ),
        QuickActionItem(
          title: 'Emergency',
          icon: Icons.emergency,
          onTap: () => Navigator.push(
            context,
            _instantRoute(const EmergencyPage()), // Added const here
          ),
        ),
        QuickActionItem(
          title: 'Appointment',
          icon: Icons.calendar_today_rounded,
          onTap: () => Navigator.push(
            context,
            _instantRoute(const AppointmentRequestPage()),
          ),
        ),
        QuickActionItem(
          title: 'View All',
          icon: Icons.grid_view_rounded,
          onTap: () =>
              Navigator.push(context, _instantRoute(const ViewAllPage())),
        ),
      ],
    );
  }
}

// ============================================================================
// MODULAR WIDGETS (Extracted for better performance and readability)
// ============================================================================

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  // Helper lists kept static so they don't recreate on every build
  static const _days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  static const _months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;

    // Determine greeting
    final String greeting;
    if (hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour == 12) {
      greeting = 'Good Noon,';
    } else if (hour < 18) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    final String formattedDate =
        "${_days[now.weekday - 1]} · ${_months[now.month - 1]} ${now.day}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const Text(
          'Username',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ResidentCard extends StatelessWidget {
  final String title;
  final String residentId;
  final VoidCallback onViewProfile;

  const _ResidentCard({
    required this.title,
    required this.residentId,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B2CF5), Color(0xFF6D28D9)],
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),

            // Text Details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    residentId,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // View Button
            SizedBox(
              height: 30,
              child: OutlinedButton(
                onPressed: onViewProfile,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0xFF8B2CF5), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("View", style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GLOBAL UTILITIES
// ============================================================================

/// Instantly routes to a new page without an animation
Route _instantRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return page;
    },
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}
