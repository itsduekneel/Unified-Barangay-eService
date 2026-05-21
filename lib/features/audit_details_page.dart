import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'audit_log_page.dart';

// =============================================================================
// DETAIL SCREEN
// =============================================================================

class AuditLogDetailScreen extends StatelessWidget {
  final AuditEntry entry;

  const AuditLogDetailScreen({super.key, required this.entry});

  // =============================================================================
  // FUNCTIONS
  // =============================================================================

  Future<void> _downloadCSV(BuildContext context) async {
    final data = [
      ['Field', 'Value'],
      ['Activity Type', entry.activityType],
      ['Module', entry.module],
      ['Action', entry.actionLabel],
      ['Description', entry.description],
      ['User', entry.performedBy],
      ['Role', entry.role],
      ['Department', entry.department],
      ['Target Type', entry.targetType],
      ['Reference ID', entry.referenceId],
      ['Name / Title', entry.nameTitle],
      ['IP Address', entry.ipAddress],
      ['Device', entry.device],
      ['Browser / App', entry.browserApp],
      ['Location', entry.location],
    ];

    String csv = const ListToCsvConverter().convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/audit_log_${DateTime.now().millisecondsSinceEpoch}.csv',
    );

    await file.writeAsString(csv);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('CSV saved: ${file.path}')));

    await Share.shareXFiles([XFile(file.path)]);
  }

  void _shareLog() {
    final text =
        '''
Audit Log Details

Activity: ${entry.activityType}
Module: ${entry.module}
Action: ${entry.actionLabel}
User: ${entry.performedBy}
Date: ${entry.date}
''';

    Share.share(text);
  }

  // =============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4FA),
      appBar: AppBar(
        title: const Text(
          'Audit Log Details',
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

        // ✅ UPDATED MENU (NO PDF)
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: kPrimary),
            onSelected: (value) {
              if (value == 'csv') {
                _downloadCSV(context);
              } else if (value == 'share') {
                _shareLog();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('Download CSV')),
              PopupMenuItem(value: 'share', child: Text('Share')),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHero(context),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                children: [
                  _InfoSection(
                    icon: Icons.info_outline_rounded,
                    title: 'Activity Information',
                    rows: [
                      _InfoRow('Activity Type', entry.activityType),
                      _InfoRow('Module', entry.module),
                      _InfoRow('Action', entry.actionLabel),
                      _InfoRow('Description', entry.description),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoSection(
                    icon: Icons.person_outline_rounded,
                    title: 'Performed By',
                    rows: [
                      _InfoRow('User', entry.performedBy),
                      _InfoRow('Role', entry.role),
                      _InfoRow('Department', entry.department),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoSection(
                    icon: Icons.track_changes_rounded,
                    title: 'Target Information',
                    rows: [
                      _InfoRow('Target Type', entry.targetType),
                      _InfoRow('Reference ID', entry.referenceId),
                      _InfoRow('Name / Title', entry.nameTitle),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _InfoSection(
                    icon: Icons.more_horiz_rounded,
                    title: 'Additional Details',
                    rows: [
                      _InfoRow('IP Address', entry.ipAddress),
                      _InfoRow('Device', entry.device),
                      _InfoRow('Browser / App', entry.browserApp),
                      _InfoRow('Location', entry.location),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ✅ ONLY CSV BUTTON REMAINS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadCSV(context),
                      icon: const Icon(Icons.download_rounded, size: 17),
                      label: const Text(
                        'Download as CSV',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      color: const Color(0xFFF5F4FA),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: kPrimary, shape: BoxShape.circle),
            child: Icon(entry.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            entry.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kPrimary900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.activityType.isEmpty
                  ? entry.action.name
                  : entry.activityType,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: kPrimary700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.date.isEmpty ? entry.time : entry.date,
            style: const TextStyle(
              fontSize: 12,
              color: kPrimary400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REUSABLE SECTION WIDGET
// =============================================================================

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoRow> rows;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimary100.withValues(alpha: 0.7), width: 1),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary100, kPrimary50],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: kPrimary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kPrimary100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: rows.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          row.label,
                          style: const TextStyle(color: kPrimary400),
                        ),
                      ),
                      Expanded(
                        child: Text(row.value, textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
