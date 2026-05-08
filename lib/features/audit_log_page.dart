import 'package:flutter/material.dart';
import 'audit_details_page.dart';
import 'package:ube/core/utils/route_utils.dart';
// =============================================================================
// THEME
// =============================================================================

const kPrimary = Color(0xFF8B2CF5);
const kPrimary900 = Color(0xFF3B0F8C);
const kPrimary700 = Color(0xFF6A1FC2);
const kPrimary400 = Color(0xFFAB65F7);
const kPrimary200 = Color(0xFFD9B8FC);
const kPrimary100 = Color(0xFFEFDEFE);
const kPrimary50 = Color(0xFFF8F2FF);

// =============================================================================
// MODEL
// =============================================================================

enum ActionType { create, update, delete, login, logout, settings }

class AuditEntry {
  final String title;
  final String subtitle;
  final String detail;
  final String time;
  final ActionType action;
  final IconData icon;

  // ── Detail-screen extras ──
  final String activityType;
  final String module;
  final String actionLabel;
  final String description;
  final String performedBy;
  final String role;
  final String department;
  final String targetType;
  final String referenceId;
  final String nameTitle;
  final String ipAddress;
  final String device;
  final String browserApp;
  final String location;
  final String date;

  const AuditEntry({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.time,
    required this.action,
    required this.icon,
    this.activityType = '',
    this.module = '',
    this.actionLabel = '',
    this.description = '',
    this.performedBy = '',
    this.role = '',
    this.department = 'N/A',
    this.targetType = '',
    this.referenceId = '',
    this.nameTitle = 'N/A',
    this.ipAddress = 'N/A',
    this.device = 'N/A',
    this.browserApp = 'N/A',
    this.location = 'N/A',
    this.date = '',
  });
}

// =============================================================================
// SAMPLE DATA
// =============================================================================

const auditLogs = [
  AuditEntry(
    title: 'Document Approved',
    subtitle: 'Barangay Clearance • BC-0512',
    detail: 'Approved by Maria Santos',
    time: '9:30 AM',
    action: ActionType.create,
    icon: Icons.description_outlined,
    activityType: 'Approval',
    module: 'Documents',
    actionLabel: 'Approved',
    description: 'A document was approved in the system.',
    performedBy: 'Maria Santos',
    role: 'Administrator',
    department: 'N/A',
    targetType: 'Document',
    referenceId: 'BC-0512',
    nameTitle: 'Barangay Clearance',
    ipAddress: '192.168.1.10',
    device: 'iPhone 14 Pro',
    browserApp: 'UBE eService iOS App',
    location: 'N/A',
    date: 'May 12, 2024 • 9:30 AM',
  ),
  AuditEntry(
    title: 'Status Updated',
    subtitle: 'Health Certificate • HC-0341',
    detail: 'Ready for Pickup',
    time: '9:15 AM',
    action: ActionType.update,
    icon: Icons.check_circle_outline,
    activityType: 'Update',
    module: 'Documents',
    actionLabel: 'Updated',
    description: 'Document status changed to Ready for Pickup.',
    performedBy: 'User B',
    role: 'Staff',
    department: 'Health',
    targetType: 'Document',
    referenceId: 'HC-0341',
    nameTitle: 'Health Certificate',
    ipAddress: '192.168.1.11',
    device: 'Samsung Galaxy S23',
    browserApp: 'UBE eService Android App',
    location: 'N/A',
    date: 'May 12, 2024 • 9:15 AM',
  ),
  AuditEntry(
    title: 'User Login',
    subtitle: 'Juan Dela Cruz',
    detail: 'Logged in to system',
    time: '9:02 AM',
    action: ActionType.login,
    icon: Icons.person_outline,
    activityType: 'Authentication',
    module: 'Auth',
    actionLabel: 'Login',
    description: 'User logged in to the system.',
    performedBy: 'Juan Dela Cruz',
    role: 'Resident',
    department: 'N/A',
    targetType: 'Session',
    referenceId: 'SES-0029',
    nameTitle: 'N/A',
    ipAddress: '192.168.1.22',
    device: 'iPhone 13',
    browserApp: 'UBE eService iOS App',
    location: 'N/A',
    date: 'May 12, 2024 • 9:02 AM',
  ),
  AuditEntry(
    title: 'Document Deleted',
    subtitle: 'Business Permit • BP-0123',
    detail: 'Deleted by Ana Reyes',
    time: '8:45 AM',
    action: ActionType.delete,
    icon: Icons.delete_outline,
    activityType: 'Deletion',
    module: 'Documents',
    actionLabel: 'Deleted',
    description: 'A business permit document was permanently deleted.',
    performedBy: 'Ana Reyes',
    role: 'Administrator',
    department: 'Business',
    targetType: 'Document',
    referenceId: 'BP-0123',
    nameTitle: 'Business Permit',
    ipAddress: '192.168.1.15',
    device: 'MacBook Pro',
    browserApp: 'Chrome 120',
    location: 'N/A',
    date: 'May 12, 2024 • 8:45 AM',
  ),
  AuditEntry(
    title: 'User Logout',
    subtitle: 'Maria Santos',
    detail: 'Logged out',
    time: '5:45 PM',
    action: ActionType.logout,
    icon: Icons.logout,
    activityType: 'Authentication',
    module: 'Auth',
    actionLabel: 'Logout',
    description: 'User logged out of the system.',
    performedBy: 'Maria Santos',
    role: 'Administrator',
    department: 'N/A',
    targetType: 'Session',
    referenceId: 'SES-0028',
    nameTitle: 'N/A',
    ipAddress: '192.168.1.10',
    device: 'iPhone 14 Pro',
    browserApp: 'UBE eService iOS App',
    location: 'N/A',
    date: 'May 11, 2024 • 5:45 PM',
  ),
];

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Audit Log',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F4FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kPrimary900,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(auditLogs.length, (i) {
                return _AuditItem(
                  entry: auditLogs[i],
                  isLast: i == auditLogs.length - 1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LIST ITEM  (now tappable → navigates to detail screen)
// =============================================================================

class _AuditItem extends StatelessWidget {
  final AuditEntry entry;
  final bool isLast;

  const _AuditItem({required this.entry, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── LEFT: timeline ──
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimary200, kPrimary100],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── CARD ──
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  instantRoute(AuditLogDetailScreen(entry: entry)),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kPrimary100.withOpacity(0.7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimary100, kPrimary50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(entry.icon, color: kPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: kPrimary900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entry.subtitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: kPrimary400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.detail,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: kPrimary200,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Time
                    Text(
                      entry.time,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: kPrimary400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
