import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/snackbar_utils.dart';

// ─── Theme Constants ──────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF8B2CF5);
  static const primaryLight = Color(0xFFEEECFD);
  static const bg = Color(0xFFF5F4FA);
  static const text = Color(0xFF1A1A2E);
  static const subtext = Color(0xFF9490B0);
  static const border = Color(0xFFE8E5F5);
  static const white = Colors.white;
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFDCFCE7);
}

class NotifDetail {
  final IconData icon;
  final String label;
  final String value;
  const NotifDetail({
    required this.icon,
    required this.label,
    required this.value,
  });
}

// ─── Main Widget ──────────────────────────────────────────────────────────────
class NotificationReadPages extends StatefulWidget {
  final String title;
  final String description;
  final String time; // e.g. "2 mins ago • May 16, 2025 • 4:21 PM"
  final String author; // e.g. "Kap. Juan dela Cruz"
  final VoidCallback onDelete;

  // Optional structured details (shown as icon rows below the description)
  final List<NotifDetail> details;

  const NotificationReadPages({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.author,
    required this.onDelete,
    this.details = const [],
  });

  @override
  State<NotificationReadPages> createState() => _NotificationReadPagesState();
}

class _NotificationReadPagesState extends State<NotificationReadPages> {
  bool _isRead = true; // tracks read/unread toggle

  // ── Delete confirmation dialog ─────────────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: _C.subtext)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: _C.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              widget.onDelete();
              AppSnackBar.show(
                context,
                message: 'Notification deleted',
                icon: Icons.delete_forever_rounded,
                backgroundColor: Colors.redAccent,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Share ──────────────────────────────────────────────────────────────────
  Future<void> _share() async {
    final text =
        'Barangay Update: ${widget.title}\n\n${widget.description}'
        '\n\nPosted by: ${widget.author}'
        '\nSent: ${widget.time}';
    await Share.share(text, subject: 'Ube Digital Update');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        title: const Text(
          'Notification',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF8B2CF5)),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete',
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main content card ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: bell icon + read badge + share button ─────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bell icon with read checkmark
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _C.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.notifications_rounded,
                              color: _C.primary,
                              size: 26,
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: _C.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: _C.success,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      // Read badge + timestamp + author
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _C.successBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Read',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _C.success,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: _C.subtext,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // ── Author row ───────────────────────────────────
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_rounded,
                                  size: 10,
                                  color: _C.subtext,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Posted by ${widget.author}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _C.subtext,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Share button
                      OutlinedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.share_rounded, size: 14),
                        label: const Text(
                          'Share',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.primary,
                          side: const BorderSide(color: _C.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Title ──────────────────────────────────────────────────
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _C.text,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: _C.border, height: 1),
                  const SizedBox(height: 14),

                  // ── Description ────────────────────────────────────────────
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                      height: 1.65,
                    ),
                  ),

                  // ── Detail rows ────────────────────────────────────────────
                  if (widget.details.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    ...widget.details.map((d) => _DetailRow(detail: d)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Add to Calendar button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: integrate calendar plugin
                },
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: const Text(
                  'Add to Calendar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  foregroundColor: _C.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: _C.primary.withOpacity(0.35),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Mark as Unread / Read toggle ───────────────────────────────
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isRead = !_isRead),
                child: Text(
                  _isRead ? 'Mark as Unread' : 'Mark as Read',
                  style: const TextStyle(
                    color: _C.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final NotifDetail detail;
  const _DetailRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _C.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(detail.icon, color: _C.primary, size: 18),
          ),

          const SizedBox(width: 14),

          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.label,
                  style: const TextStyle(fontSize: 11, color: _C.subtext),
                ),
                const SizedBox(height: 2),
                Text(
                  detail.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
