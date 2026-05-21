// ============================================================================
// lib/features/hall/smart_queue_page.dart
// Barangay Hall: Smart Queue System
// ============================================================================

import 'package:flutter/material.dart';
import 'package:ube/models/app_models.dart';
import 'package:ube/services/mock/mock_service.dart';

const _kPrimary = Color(0xFF8B2CF5);
const _kBg = Color(0xFFF5F4FA);

const _kBorder = Color(0xFFEBE0FF);

class SmartQueuePage extends StatefulWidget {
  const SmartQueuePage({super.key});

  @override
  State<SmartQueuePage> createState() => _SmartQueuePageState();
}

class _SmartQueuePageState extends State<SmartQueuePage> {
  List<QueueTicketModel> _tickets = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await MockService.getQueueTickets();
    if (mounted) {
      setState(() {
        _tickets = data;
        _isLoading = false;
      });
    }
  }

  List<QueueTicketModel> get _filtered => _filterStatus == 'all'
      ? _tickets
      : _tickets.where((t) => t.status.name == _filterStatus).toList();

  Color _statusColor(QueueStatus s) => switch (s) {
    QueueStatus.waiting => const Color(0xFFF59E0B),
    QueueStatus.serving => _kPrimary,
    QueueStatus.completed => const Color(0xFF16A34A),
    QueueStatus.noShow => const Color(0xFFDC2626),
  };

  String _statusLabel(QueueStatus s) => switch (s) {
    QueueStatus.waiting => 'Waiting',
    QueueStatus.serving => 'Now Serving',
    QueueStatus.completed => 'Completed',
    QueueStatus.noShow => 'No Show',
  };

  void _showCallNextDialog() {
    final waiting = _tickets
        .where((t) => t.status == QueueStatus.waiting)
        .toList();
    if (waiting.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tickets in queue.'),
          backgroundColor: _kPrimary,
        ),
      );
      return;
    }
    final next = waiting.first;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Call Next',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Now calling: ${next.ticketNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _kPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(next.residentName, style: const TextStyle(fontSize: 13)),
            Text(
              'Service: ${next.service}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await MockService.updateQueueStatus(next.id, QueueStatus.serving);
              _load();
            },
            child: const Text(
              'Call Now',
              style: TextStyle(color: _kPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final waiting = _tickets
        .where((t) => t.status == QueueStatus.waiting)
        .length;
    final serving = _tickets
        .where((t) => t.status == QueueStatus.serving)
        .length;
    final done = _tickets
        .where((t) => t.status == QueueStatus.completed)
        .length;

    // Currently serving ticket
    final servingTicket = _tickets
        .where((t) => t.status == QueueStatus.serving)
        .firstOrNull;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text(
          'Smart Queue System',
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
        onPressed: _showCallNextDialog,
        icon: const Icon(Icons.campaign, color: Colors.white),
        label: const Text(
          'Call Next',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kPrimary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Now Serving Banner
                  if (servingTicket != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'NOW SERVING',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              servingTicket.ticketNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              servingTicket.residentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Window ${servingTicket.windowNo ?? 1} · ${servingTicket.service}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _QStat('Waiting', waiting, const Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        _QStat('Serving', serving, _kPrimary),
                        const SizedBox(width: 8),
                        _QStat('Done', done, const Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildChip('Waiting', 'waiting'),
                        const SizedBox(width: 8),
                        _buildChip('Serving', 'serving'),
                        const SizedBox(width: 8),
                        _buildChip('Completed', 'completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Queue List (${filtered.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
                      final t = filtered[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: t.status == QueueStatus.serving
                                ? _kPrimary.withValues(alpha: 0.5)
                                : _kBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  t.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  t.ticketNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _statusColor(t.status),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.residentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    t.service,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (t.status == QueueStatus.waiting)
                                    Text(
                                      '~${t.estimatedWaitMinutes} min wait',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (t.windowNo != null)
                                    Text(
                                      'Window ${t.windowNo}',
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  t.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _statusColor(
                                    t.status,
                                  ).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                _statusLabel(t.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(t.status),
                                ),
                              ),
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

class _QStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _QStat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
