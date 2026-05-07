// ============================================================================
// lib/features/hall/incident_tracking_page.dart
// Barangay Hall: Incident Tracking Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);
const _kPrimaryLight = Color(0xFFF5F0FF);
const _kBorder = Color(0xFFEBE0FF);

class IncidentTrackingPage extends StatefulWidget {
  const IncidentTrackingPage({super.key});

  @override
  State<IncidentTrackingPage> createState() => _IncidentTrackingPageState();
}

class _IncidentTrackingPageState extends State<IncidentTrackingPage> {
  List<IncidentReportModel> _incidents = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getIncidentReports();
    if (mounted)
      setState(() {
        _incidents = data;
        _isLoading = false;
      });
  }

  List<IncidentReportModel> get _filtered => _incidents.where((inc) {
    final matchStatus =
        _filterStatus == 'all' || inc.status.name == _filterStatus;
    final matchSearch =
        _searchQuery.isEmpty ||
        inc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        inc.reportedBy.toLowerCase().contains(_searchQuery.toLowerCase());
    return matchStatus && matchSearch;
  }).toList();

  Color _severityColor(IncidentSeverity s) => switch (s) {
    IncidentSeverity.minor => const Color(0xFF16A34A),
    IncidentSeverity.moderate => const Color(0xFFF59E0B),
    IncidentSeverity.severe => const Color(0xFFDC2626),
  };

  String _severityLabel(IncidentSeverity s) => switch (s) {
    IncidentSeverity.minor => 'Minor',
    IncidentSeverity.moderate => 'Moderate',
    IncidentSeverity.severe => 'Severe',
  };

  Color _statusColor(RequestStatus s) => switch (s) {
    RequestStatus.pending => const Color(0xFFF59E0B),
    RequestStatus.approved => _kPrimary,
    RequestStatus.completed => const Color(0xFF16A34A),
    RequestStatus.rejected => const Color(0xFFDC2626),
    _ => Colors.grey,
  };

  String _statusLabel(RequestStatus s) => switch (s) {
    RequestStatus.pending => 'Pending',
    RequestStatus.approved => 'Assigned',
    RequestStatus.completed => 'Resolved',
    RequestStatus.rejected => 'Closed',
    _ => 'Unknown',
  };

  void _showUpdateDialog(IncidentReportModel incident) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Update Status',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              incident.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...RequestStatus.values
                .where((s) => s != RequestStatus.cancelled)
                .map(
                  (s) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _statusLabel(s),
                      style: const TextStyle(fontSize: 13),
                    ),
                    leading: Radio<RequestStatus>(
                      value: s,
                      groupValue: incident.status,
                      activeColor: _kPrimary,
                      onChanged: (v) async {
                        Navigator.pop(context);
                        await MockService.updateIncidentStatus(
                          incident.id,
                          v!,
                          null,
                        );
                        _load();
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final pending = _incidents
        .where((i) => i.status == RequestStatus.pending)
        .length;
    final assigned = _incidents
        .where((i) => i.status == RequestStatus.approved)
        .length;
    final resolved = _incidents
        .where((i) => i.status == RequestStatus.completed)
        .length;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Incident Tracking',
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
                  // Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _Stat('Pending', pending, const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _Stat('Assigned', assigned, _kPrimary),
                        const SizedBox(width: 8),
                        _Stat('Resolved', resolved, const Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search incidents...',
                        hintStyle: const TextStyle(
                          color: _kPrimary,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: _kPrimary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: _kPrimaryLight,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _kPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildChip('Pending', 'pending'),
                        const SizedBox(width: 8),
                        _buildChip('Assigned', 'approved'),
                        const SizedBox(width: 8),
                        _buildChip('Resolved', 'completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Incident Reports',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${filtered.length} reports',
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
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final inc = filtered[i];
                      return Container(
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
                                Expanded(
                                  child: Text(
                                    inc.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _severityColor(
                                      inc.severity,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _severityColor(
                                        inc.severity,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _severityLabel(inc.severity),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _severityColor(inc.severity),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inc.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    inc.location,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  inc.reportedBy,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${inc.dateReported} ${inc.timeReported}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            if (inc.assignedOfficer != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shield_outlined,
                                    size: 13,
                                    color: _kPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    inc.assignedOfficer!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _kPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      inc.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _statusColor(
                                        inc.status,
                                      ).withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _statusLabel(inc.status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _statusColor(inc.status),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showUpdateDialog(inc),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _kPrimary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Update',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChip(String label, String value) {
    final selected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kPrimary : _kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Stat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
