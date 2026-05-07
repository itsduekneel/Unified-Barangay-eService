import 'package:flutter/material.dart';

import 'package:ube/features/request_appointment_page.dart';
import 'package:ube/widgets/status_card.dart';

class AppColors {
  static const primary = Color(0xFF8B2CF5);
  static const primaryHover = Color(0xFF6B1BD4);
  static const primaryLight = Color(0xFFEBE0FF);
  static const primarySuperLight = Color(0xFFF5F0FF);

  static const textDark = Color(0xFF1E0447);
  static const textMedium = Color(0xFF360C78);
  static const textMuted = Color(0xFF8B2CF5);
  static const backgroundLight = Color(0xFFFAFAFA);

  static const badgeConfBg = Color(0xFFEDFAF3);
  static const badgeConfText = Color(0xFF1A7C45);
  static const badgeConfBorder = Color(0xFFB0E8C9);

  static const badgePendBg = Color(0xFFEBE0FF);
  static const badgePendText = Color(0xFF4F12A8);
}

class AppointmentItem {
  final int id;
  final String title;
  final String month;
  final String day;
  final String time;
  final String type;
  String status;
  final String notes;

  AppointmentItem({
    required this.id,
    required this.title,
    required this.month,
    required this.day,
    required this.time,
    required this.type,
    required this.status,
    required this.notes,
  });
}

class AppointmentRequestPage extends StatefulWidget {
  const AppointmentRequestPage({super.key});

  @override
  State<AppointmentRequestPage> createState() => _AppointmentRequestPageState();
}

class _AppointmentRequestPageState extends State<AppointmentRequestPage> {
  String currentFilter = 'all';
  String searchQuery = '';
  final bool _hasPdf = false; // Added missing variable

  List<AppointmentItem> requests = [
    AppointmentItem(
      id: 1,
      title: 'Plumbing inspection',
      month: 'Apr',
      day: '12',
      time: '10:00 AM',
      type: 'Maintenance',
      status: 'upcoming',
      notes: 'Possible leak under kitchen sink.',
    ),
    AppointmentItem(
      id: 2,
      title: 'HVAC maintenance',
      month: 'Apr',
      day: '18',
      time: '2:00 PM',
      type: 'HVAC',
      status: 'confirmed',
      notes: 'Annual full-unit servicing.',
    ),
    AppointmentItem(
      id: 3,
      title: 'General inspection',
      month: 'Apr',
      day: '24',
      time: '9:30 AM',
      type: 'Inspection',
      status: 'pending',
      notes: 'Quarterly walkthrough.',
    ),
    AppointmentItem(
      id: 4,
      title: 'Pest control visit',
      month: 'Mar',
      day: '29',
      time: '11:00 AM',
      type: 'Pest Control',
      status: 'completed',
      notes: 'Routine treatment applied.',
    ),
    AppointmentItem(
      id: 5,
      title: 'Electrical check',
      month: 'Mar',
      day: '15',
      time: '3:00 PM',
      type: 'Maintenance',
      status: 'completed',
      notes: 'Panel inspection completed.',
    ),
  ];

  // Simplified getters
  int get totalCount => requests.length;
  int get upcomingCount => requests
      .where((r) => r.status == 'upcoming')
      .length; // Added missing getter
  int get pendingCount => requests.where((r) => r.status == 'pending').length;
  int get confirmedCount =>
      requests.where((r) => r.status == 'confirmed').length;
  int get completedCount =>
      requests.where((r) => r.status == 'completed').length;
  int get rejectedCount => requests.where((r) => r.status == 'rejected').length;

  // Fixed List type and search logic
  List<AppointmentItem> get filteredRequests {
    return requests.where((r) {
      final matchStatus = currentFilter == 'all' || r.status == currentFilter;
      final query = searchQuery.toLowerCase();
      final matchSearch =
          query.isEmpty ||
          r.title.toLowerCase().contains(query) ||
          r.type.toLowerCase().contains(query);

      return matchStatus && matchSearch;
    }).toList();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Appointment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildAppointmentCard(context),
            const SizedBox(height: 24),
            _buildFilterAndSearchRow(),
            const SizedBox(height: 16),
            _buildAppointmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    int safeTotal = totalCount > 0 ? totalCount : 1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          StatusCard(
            value: totalCount,
            label: "Total",
            pct: 1.0,
            isActive: true,
          ),
          const SizedBox(width: 12),
          StatusCard(
            value: upcomingCount,
            label: "Upcoming",
            pct: upcomingCount / safeTotal,
            isActive: false,
          ),
          const SizedBox(width: 12),
          StatusCard(
            value: pendingCount,
            label: "Pending",
            pct: pendingCount / safeTotal,
            isActive: false,
          ),
          const SizedBox(width: 12),
          StatusCard(
            value: completedCount,
            label: "Completed",
            pct: completedCount / safeTotal,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchRow() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterTab('All', 'all'),
              _filterTab('Upcoming', 'upcoming'),
              _filterTab('Pending', 'pending'),
              _filterTab('Completed', 'completed'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.primary,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.primarySuperLight,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterTab(String label, String value) {
    bool isOn = currentFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => currentFilter = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOn ? AppColors.primary : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isOn ? FontWeight.w600 : FontWeight.w500,
              color: isOn ? Colors.white : AppColors.primaryHover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        _instantRoute(const AddAppointment()), // Assuming AddAppointment exists
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.primaryLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primarySuperLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _hasPdf ? 'Document Attached' : 'New request',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: _hasPdf ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _hasPdf
                  ? 'Tap the card to replace'
                  : 'Tap to book a service appointment',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList() {
    final list = filteredRequests; // Fixed variable name
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            "No appointments found",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ),
      );
    }

    return Column(children: list.map((a) => _buildListItem(a)).toList());
  }

  Widget _buildListItem(AppointmentItem a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () => _openDetailSheet(a),
        leading: Container(
          width: 50,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.primarySuperLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                a.month.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                a.day,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          a.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          '${a.time} · ${a.type}',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: _buildBadge(a.status),
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color bg, text, border;
    String label;

    switch (status) {
      case 'upcoming':
        bg = AppColors.primary;
        text = Colors.white;
        border = AppColors.primary;
        label = 'Upcoming';
        break;
      case 'confirmed':
        bg = AppColors.badgeConfBg;
        text = AppColors.badgeConfText;
        border = AppColors.badgeConfBorder;
        label = 'Confirmed';
        break;
      case 'pending':
        bg = AppColors.badgePendBg;
        text = AppColors.badgePendText;
        border = AppColors.primaryLight;
        label = 'Pending';
        break;
      case 'completed':
      default:
        bg = AppColors.primarySuperLight;
        text = AppColors.primary;
        border = AppColors.primarySuperLight;
        label = 'Done';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _openDetailSheet(AppointmentItem a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Appointment details',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textMedium,
                      ),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primarySuperLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.primaryLight),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow('Date', '${a.month} ${a.day}, 2026'),
                    const SizedBox(height: 12),
                    _detailRow('Time', a.time),
                    const SizedBox(height: 12),
                    _detailRow('Service type', a.type),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildBadge(a.status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Notes', a.notes),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    if (a.status != 'completed')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(
                              () => requests.removeWhere(
                                (item) => item.id == a.id,
                              ), // Fixed variable reference
                            );
                            Navigator.pop(context);
                            _showToast('Appointment cancelled');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (a.status != 'completed') const SizedBox(width: 12),
                    if (a.status != 'completed')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showToast('Reschedule requested');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Reschedule'),
                        ),
                      ),
                    if (a.status == 'completed')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showToast('Archived successfully');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryHover,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Archive'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

Route<void> _instantRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, _, _) => page,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);
