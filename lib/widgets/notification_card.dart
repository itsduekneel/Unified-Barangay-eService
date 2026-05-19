import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onMarkRead,
  });

  static const Color primaryColor = Color(0xFF8B2CF5);

  // ── Mark as read: update Supabase then call onMarkRead to refresh UI ───────
  Future<void> _handleTap(BuildContext context) async {
    onTap(); // run any existing onTap logic

    final bool isRead = item.status == 'Read';
    if (isRead) return; // already read, nothing to do

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'status': 'Read'})
          .eq('id', item.id);

      // Update local object so the card reflects immediately
      item.status = 'Read';

      // Notify parent to call setState / refresh list
      onMarkRead?.call();
    } on PostgrestException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = item.status == 'Read';

    return InkWell(
      onTap: () => _handleTap(context), // ← use the new handler
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isRead
                        ? Colors.grey.shade100
                        : primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isRead ? Colors.grey : primaryColor,
                    size: 20,
                  ),
                ),
                if (!isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 15,
                            color: isRead ? Colors.black54 : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: isRead ? Colors.black38 : Colors.black54,
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
}

// lib/models/notification_item.dart

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  String status; // mutable so UI can update locally
  final String author;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.status,
    required this.author,
  });

  // ── Factory from Supabase row ──────────────────────────────────────────────
  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      time: map['created_at'] ?? '',
      status: map['status'] ?? 'Unread',
      author: map['author'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'author': author,
    };
  }
}

