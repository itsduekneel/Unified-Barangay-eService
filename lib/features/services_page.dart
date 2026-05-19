// ============================================================================
// lib/features/services_page.dart  — COMPLETE UPDATED FILE
// Extends the existing services page with all new module routes.
// Only the import block and _allItems list have been extended.
// All existing code is preserved exactly as-is.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/features/announcement_page.dart';
import 'package:ube/features/appointment_request_page.dart';
import 'package:ube/features/document_request_page.dart';
import 'package:ube/features/emergency_page.dart';
import 'package:ube/features/residents_household_page.dart';
import 'package:ube/features/rolebased_access_control_page.dart';
import 'package:ube/features/tracking_services_request_page.dart';
import 'package:ube/features/audit_log_page.dart';
import 'package:ube/features/hall/documentcreation_page.dart';

// ── NEW: Resident modules ────────────────────────────────────────────────────
import 'package:ube/features/incident_report_page.dart';
import 'package:ube/features/barangay_management.dart';
import 'package:ube/features/barangay_activities_page.dart';
import 'package:ube/features/barangay_service_transaction_page.dart';
import 'package:ube/features/task_page.dart';
import 'package:ube/features/attendance_admin.dart';


import 'package:ube/features/hall/rbac_management_page.dart';
import 'package:ube/features/hall/smart_queue_page.dart';
import 'package:ube/features/hall/appointment_management_page.dart';
import 'package:ube/features/hall/emergency_tracker_page.dart' as hall_emg;
import 'package:ube/features/hall/incident_tracking_page.dart';
import 'package:ube/features/hall/household_creation_page.dart';

import 'package:ube/core/utils/route_utils.dart';

/// ─────────────────────────────────────────
/// COLORS (unchanged)
/// ─────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF8B2CF5);
  static final iconBg = primary.withOpacity(0.08);
  static final iconBorder = primary.withOpacity(0.2);
}

/// ─────────────────────────────────────────
/// MODEL (unchanged)
/// ─────────────────────────────────────────
class IconItem {
  final String title;
  final IconData icon;
  final void Function(BuildContext context)? onTap;

  const IconItem(this.title, this.icon, {this.onTap});
}

/// ─────────────────────────────────────────
/// PAGE (unchanged structure)
/// ─────────────────────────────────────────
class ViewAllPage extends StatefulWidget {
  const ViewAllPage({super.key});

  @override
  State<ViewAllPage> createState() => _ViewAllPageState();
}

class _ViewAllPageState extends State<ViewAllPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// All service items — existing + new modules appended at the bottom
  final List<IconItem> _allItems = [
    // ── EXISTING ITEMS (unchanged) ──────────────────────────────────────────
    IconItem(
      'Document Request',
      Icons.folder,
      onTap: (context) {
        Navigator.push(context, instantRoute(const DocumentRequestsScreen()));
      },
    ),
    IconItem(
      'Emergency Request',
      Icons.emergency,
      onTap: (context) {
        Navigator.push(context, instantRoute(const EmergencyPage()));
      },
    ),
    IconItem(
      'Appointment Request',
      Icons.calendar_today_rounded,
      onTap: (context) {
        Navigator.push(
          context,
          instantRoute(const ResidentAppointmentRequestPage()),
        );
      },
    ),
    IconItem(
      'Appointment Tracker',
      Icons.calendar_today_rounded,
      onTap: (context) {
        Navigator.push(context, instantRoute(const AdminAppointmentPage()));
      },
    ),

    IconItem(
      'Residents Household',
      Icons.people_rounded,
      onTap: (context) {
        Navigator.push(context, instantRoute(const HouseholdScreen()));
      },
    ),
    IconItem(
      'Announcement',
      Icons.campaign_rounded,
      onTap: (context) {
        Navigator.push(context, instantRoute(const CreateAnnouncementScreen()));
      },
    ),
    IconItem(
      'Role-Based Access Control',
      Icons.campaign_rounded,
      onTap: (context) {
        Navigator.push(context, instantRoute(const RBACScreen()));
      },
    ),
    IconItem(
      'Tracking System',
      Icons.punch_clock_rounded,
      onTap: (context) {
        Navigator.push(
          context,
          instantRoute(const TrackingServicesRequestPage()),
        );
      },
    ),
    IconItem(
      'Audit Log',
      Icons.timer,
      onTap: (context) {
        Navigator.push(context, instantRoute(const AuditLogScreen()));
      },
    ),

    // ── NEW: RESIDENT MODULES ───────────────────────────────────────────────
    IconItem(
      'Incident Report',
      Icons.report_outlined,
      onTap: (context) {
        Navigator.push(
          context,
          instantRoute(const ResidentIncidentReportPage()),
        );
      },
    ),

    // ── NEW: BARANGAY HALL MODULES ──────────────────────────────────────────
    IconItem(
      'User Management',
      Icons.manage_accounts_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const BarangayManagementPage()));
      },
    ),
    IconItem(
      'Access Control (RBAC)',
      Icons.shield_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const RbacManagementPage()));
      },
    ),
    IconItem(
      'Staff Activity',
      Icons.groups_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const AdminTaskPage()));
      },
    ),  IconItem(
      'Staff Activity',
      Icons.groups_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const AdminServiceTransactionsPage()));
      },
    ),
    IconItem(
      'Smart Queue',
      Icons.queue_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const SmartQueuePage()));
      },
    ),
    IconItem(
      'Document Issuance',
      Icons.description_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const DocumentIssuance()));
      },
    ),

    IconItem(
      'Hall Emergency Tracker',
      Icons.sos_outlined,
      onTap: (context) {
        Navigator.push(
          context,
          instantRoute(const hall_emg.EmergencyTrackerPage()),
        );
      },
    ),
    IconItem(
      'Incident Tracking',
      Icons.local_police_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const AdminIncidentPage()));
      },
    ),
    IconItem(
      'Household Creation',
      Icons.add_home_outlined,
      onTap: (context) {
        Navigator.push(context, instantRoute(const HouseholdCreationPage()));
      },
    ),
    IconItem(
      'Satisfaction Reports',
      Icons.star_outline,
      onTap: (context) {
        Navigator.push(context, instantRoute(const BarangayActivitiesPage()));
      },
    ),
    IconItem(
      'Satisfaction Reports',
      Icons.star_outline,
      onTap: (context) {
        Navigator.push(context, instantRoute(const BarangayAttendancePage()));
      },
    )

  ];

  List<IconItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _allItems;
    return _allItems
        .where(
          (item) =>
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()),
    )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── UI (unchanged) ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Services',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF8B2CF5),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8B2CF5),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF8B2CF5),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F0FF),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEBE0FF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEBE0FF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF8B2CF5)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredItems.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, index) =>
                    _ServiceTile(item: _filteredItems[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TILE (unchanged)
class _ServiceTile extends StatelessWidget {
  final IconItem item;

  const _ServiceTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap?.call(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.iconBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
