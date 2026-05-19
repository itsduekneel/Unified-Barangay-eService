import 'package:flutter/material.dart';
import 'package:ube/features/appointment_request_page.dart';

import 'package:ube/features/emergency_page.dart';
import 'package:ube/features/user_management.dart';
import 'package:ube/features/services_page.dart';
import 'package:ube/widgets/quickactions.dart';
import 'package:ube/core/utils/route_utils.dart';
import 'package:provider/provider.dart';
import 'package:ube/view_models/user_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().fetchCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.currentUser;

    // Mas robust na check para sa Name at Role
    // Kung walang data o empty string, gagamit ng default values
    final String firstName =
        (user?.firstName != null && user!.firstName.isNotEmpty)
        ? user.firstName
        : 'Username';

    final String role = (user?.role != null && user!.role!.isNotEmpty)
        ? user.role!
        : 'User';

    final String userId = (user != null && user.id.isNotEmpty)
        ? (user.id.length > 8
              ? user.id.substring(0, 8).toUpperCase()
              : user.id.toUpperCase())
        : '—';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<UserViewModel>().fetchCurrentUserProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8B2CF5), Color(0xFF6D28D9)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 20,
                    child: _HeaderSection(userName: firstName),
                  ),
                  Positioned(
                    bottom: -25,
                    left: 20,
                    right: 20,
                    child: _ResidentCard(
                      title: role,
                      residentId: "ID: $userId",
                    ),
                  ),
                ],
              ),
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
              Navigator.push(context, instantRoute(const UserManagement())),
        ),
        QuickActionItem(
          title: 'Emergency',
          icon: Icons.emergency,
          onTap: () => Navigator.push(
            context,
            instantRoute(const EmergencyPage()), // Added const here
          ),
        ),
        QuickActionItem(
          title: 'Appointment',
          icon: Icons.calendar_today_rounded,
          onTap: () =>
              Navigator.push(context, instantRoute(const ResidentAppointmentRequestPage())),
        ),
        QuickActionItem(
          title: 'View All',
          icon: Icons.grid_view_rounded,
          onTap: () =>
              Navigator.push(context, instantRoute(const ViewAllPage())),
        ),
      ],
    );
  }
}

// ============================================================================
// MODULAR WIDGETS (Extracted for better performance and readability)
// ============================================================================

class _HeaderSection extends StatelessWidget {
  final String userName;
  const _HeaderSection({required this.userName});

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
        Text(
          userName,
          style: const TextStyle(
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

  const _ResidentCard({required this.title, required this.residentId});

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
          ],
        ),
      ),
    );
  }
}
