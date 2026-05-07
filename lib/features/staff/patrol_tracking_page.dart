// ============================================================================
// lib/features/staff/patrol_tracking_page.dart
// Staff: Patrol Tracking (Tanod) Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class PatrolTrackingPage extends StatefulWidget {
  const PatrolTrackingPage({super.key});

  @override
  State<PatrolTrackingPage> createState() => _PatrolTrackingPageState();
}

class _PatrolTrackingPageState extends State<PatrolTrackingPage> {
  List<PatrolRouteModel> _routes = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getPatrolRoutes();
    if (mounted)
      setState(() {
        _routes = data;
        _isLoading = false;
      });
  }

  List<PatrolRouteModel> get _filtered => _filterStatus == 'all'
      ? _routes
      : _routes.where((r) => r.status == _filterStatus).toList();

  Color _statusColor(String s) => switch (s) {
    'Active' => _kPrimary,
    'Completed' => const Color(0xFF16A34A),
    _ => const Color(0xFFF59E0B),
  };

  IconData _statusIcon(String s) => switch (s) {
    'Active' => Icons.directions_walk,
    'Completed' => Icons.check_circle_outline,
    _ => Icons.schedule,
  };

  void _showCheckpointSheet(PatrolRouteModel route) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CheckpointSheet(route: route),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Patrol Tracking (Tanod)',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _kPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Map placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, color: _kPrimary, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Live Patrol Map',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _kPrimary,
                            ),
                          ),
                          Text(
                            '(GPS tracking enabled in production)',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: ['all', 'Active', 'Scheduled', 'Completed']
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _filterStatus = s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _filterStatus == s
                                        ? _kPrimary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _filterStatus == s
                                          ? _kPrimary
                                          : _kBorder,
                                    ),
                                  ),
                                  child: Text(
                                    s == 'all' ? 'All' : s,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _filterStatus == s
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Patrol Routes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${filtered.length} routes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return GestureDetector(
                        onTap: () => _showCheckpointSheet(r),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        r.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _statusIcon(r.status),
                                      color: _statusColor(r.status),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          r.assignedTanod,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _kPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        r.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor(
                                          r.status,
                                        ).withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _statusColor(r.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 13,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${r.startTime} – ${r.endTime}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 13,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    r.date,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Progress bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Checkpoints',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '${r.completedCheckpoints}/${r.checkpoints.length}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _kPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: r.progress,
                                      backgroundColor: _kBorder,
                                      color: _statusColor(r.status),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to view checkpoints',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _CheckpointSheet extends StatelessWidget {
  final PatrolRouteModel route;
  const _CheckpointSheet({required this.route});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  route.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          Text(
            'Assigned: ${route.assignedTanod}',
            style: const TextStyle(fontSize: 12, color: _kPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Checkpoints:',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 10),
          ...route.checkpoints.asMap().entries.map((e) {
            final idx = e.key;
            final checkpoint = e.value;
            final isDone = idx < route.completedCheckpoints;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF16A34A) : _kBorder,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.radio_button_unchecked,
                      color: isDone ? Colors.white : Colors.grey,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      checkpoint,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDone ? Colors.black87 : Colors.grey[600],
                        fontWeight: isDone
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (idx == route.completedCheckpoints &&
                      route.status == 'Active')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 10,
                          color: _kPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
