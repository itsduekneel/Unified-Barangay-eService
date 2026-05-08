import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/notification_card.dart';
import 'notification_read_pages.dart';
import 'package:ube/core/utils/route_utils.dart';

/// =======================
/// MAIN NOTIFICATION PAGE
/// =======================
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String selectedFilter = 'All';
  List<NotificationItem> notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
    _subscribeToAnnouncements();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  // ─── Fetch all announcements once on load ───────────────────────────────────
  Future<void> _fetchAnnouncements() async {
    try {
      final data = await Supabase.instance.client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        notifications = (data as List)
            .map(
              (row) => NotificationItem(
                id: row['id'],
                title: row['title'],
                description: row['description'],
                time: _timeAgo(DateTime.parse(row['created_at'])),
                status: 'Unread',
                author: row['author'] ?? 'Username',
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load notifications.');
    }
  }

  // ─── Real-time listener for new announcements ───────────────────────────────
  void _subscribeToAnnouncements() {
    _channel = Supabase.instance.client
        .channel('announcements_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'announcements',
          callback: (payload) {
            final row = payload.newRecord;
            final newItem = NotificationItem(
              id: row['id'],
              title: row['title'],
              description: row['description'],
              time: _timeAgo(DateTime.parse(row['created_at'])),
              status: 'Unread',
              author: row['author'] ?? 'Kap. Maria Santos',
            );
            if (!mounted) return;
            setState(() {
              notifications.insert(0, newItem);
            });
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'announcements',
          callback: (payload) {
            final deletedId = payload.oldRecord['id'];
            if (!mounted) return;
            setState(() {
              notifications.removeWhere((n) => n.id == deletedId);
            });
          },
        )
        .subscribe();
  }

  // ─── Delete from Supabase ───────────────────────────────────────────────────
  Future<void> _deleteAnnouncement(NotificationItem item) async {
    try {
      await Supabase.instance.client
          .from('announcements')
          .delete()
          .eq('id', item.id);
    } catch (e) {
      _showError('Failed to delete announcement.');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  List<NotificationItem> get _filtered {
    if (selectedFilter == 'Read') {
      return notifications.where((n) => n.status == 'Read').toList();
    }
    if (selectedFilter == 'Unread') {
      return notifications.where((n) => n.status == 'Unread').toList();
    }
    return notifications;
  }

  // ─── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF8B2CF5),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.white),
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Read', child: Text('Read')),
              PopupMenuItem(value: 'Unread', child: Text('Unread')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B2CF5),
                  ),
                ),
                Text(
                  selectedFilter,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B2CF5),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B2CF5)),
                  )
                : _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No notifications found.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF8B2CF5),
                    onRefresh: _fetchAnnouncements,
                    child: ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];

                        return NotificationCard(
                          item: item,
                          onTap: () {
                            setState(() => item.status = 'Read');

                            Navigator.push(
                              context,
                              instantRoute(
                                NotificationReadPages(
                                  title: item.title,
                                  description: item.description,
                                  time: item.time,
                                  author: item.author,
                                  onDelete: () async {
                                    await _deleteAnnouncement(item);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Instant page transition (no animation) ─────────────────────────────────
