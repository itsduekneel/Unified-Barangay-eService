// ============================================================================
// lib/features/incident_report_page.dart
// Resident: Incident Report Module
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);

const _kBorder = Color(0xFFEBE0FF);

class IncidentReportPage extends StatefulWidget {
  const IncidentReportPage({super.key});

  @override
  State<IncidentReportPage> createState() => _IncidentReportPageState();
}

class _IncidentReportPageState extends State<IncidentReportPage> {
  List<IncidentReportModel> _incidents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getIncidentReports();
    // Show only current user's reports (mock: filter by R001)
    if (mounted) {
      setState(() {
        _incidents = data.where((i) => i.residentId == 'R001').toList();
        _isLoading = false;
      });
    }
  }

  Color _statusColor(RequestStatus s) => switch (s) {
    RequestStatus.pending => const Color(0xFFF59E0B),
    RequestStatus.approved => _kPrimary,
    RequestStatus.completed => const Color(0xFF16A34A),
    RequestStatus.rejected => const Color(0xFFDC2626),
    _ => Colors.grey,
  };

  String _statusLabel(RequestStatus s) => switch (s) {
    RequestStatus.pending => 'Pending',
    RequestStatus.approved => 'Under Review',
    RequestStatus.completed => 'Resolved',
    RequestStatus.rejected => 'Closed',
    _ => 'Unknown',
  };

  Color _severityColor(IncidentSeverity s) => switch (s) {
    IncidentSeverity.minor => const Color(0xFF16A34A),
    IncidentSeverity.moderate => const Color(0xFFF59E0B),
    IncidentSeverity.severe => const Color(0xFFDC2626),
  };

  void _showReportForm() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String selectedSeverity = 'Minor';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'File Incident Report',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FormField(
                  ctrl: titleCtrl,
                  label: 'Incident Title',
                  hint: 'e.g. Noise Complaint',
                ),
                const SizedBox(height: 10),
                _FormField(
                  ctrl: locCtrl,
                  label: 'Location',
                  hint: 'e.g. 14 Sampaguita St.',
                ),
                const SizedBox(height: 10),
                _FormField(
                  ctrl: descCtrl,
                  label: 'Description',
                  hint: 'Describe the incident in detail...',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Severity',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['Minor', 'Moderate', 'Severe'].map((sev) {
                    final selected = selectedSeverity == sev;
                    Color color = sev == 'Minor'
                        ? const Color(0xFF16A34A)
                        : sev == 'Moderate'
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFDC2626);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedSeverity = sev),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? color : _kBorder,
                              ),
                            ),
                            child: Text(
                              sev,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? color : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final report = IncidentReportModel(
                        id: 'INC_NEW',
                        reportedBy: 'Juan Dela Cruz',
                        residentId: 'R001',
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        location: locCtrl.text,
                        dateReported: 'May 5, 2025',
                        timeReported: '10:00 AM',
                        severity: selectedSeverity == 'Minor'
                            ? IncidentSeverity.minor
                            : selectedSeverity == 'Moderate'
                            ? IncidentSeverity.moderate
                            : IncidentSeverity.severe,
                        status: RequestStatus.pending,
                      );
                      await MockService.createIncidentReport(report);
                      _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incident report submitted!'),
                            backgroundColor: _kPrimary,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Submit Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Incident Report',
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kPrimary,
        onPressed: _showReportForm,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text(
          'File Report',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : _incidents.isEmpty
          ? _EmptyState(onTap: _showReportForm)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _incidents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final inc = _incidents[i];
                final sc = _severityColor(inc.severity);
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
                              color: _statusColor(inc.status).withOpacity(0.1),
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
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        inc.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          Text(
                            inc.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              inc.severity.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: sc,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${inc.dateReported} · ${inc.timeReported}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      if (inc.assignedOfficer != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 13,
                              color: _kPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Assigned: ${inc.assignedOfficer}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.report_gmailerrorred_outlined,
            size: 60,
            color: _kPrimary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No incident reports yet.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the button below to file one.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'File Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final int maxLines;
  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 12, color: _kPrimary),
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
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
    );
  }
}
