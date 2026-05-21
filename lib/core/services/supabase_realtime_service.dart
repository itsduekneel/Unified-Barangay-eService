import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_notification_service.dart';
import 'package:flutter/foundation.dart';

class SupabaseRealtimeService {
  static final _supabase = Supabase.instance.client;
  static RealtimeChannel? _emergencyChannel;
  static String? _userRole;

  static Future<void> init() async {
    await _fetchUserRole();
    _startListening();
  }

  static Future<void> _fetchUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Check profiles first
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        _userRole = profile['role'];
      } else {
        // Check barangays table fallback
        final barangay = await _supabase
            .from('barangays')
            .select('id')
            .eq('auth_uid', user.id)
            .maybeSingle();
        if (barangay != null) {
          _userRole = 'Barangay';
        }
      }
      debugPrint('SupabaseRealtimeService: User role is $_userRole');
    } catch (e) {
      debugPrint('SupabaseRealtimeService: Error fetching role: $e');
    }
  }

  static void _startListening() {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return;

    _emergencyChannel = _supabase
        .channel('public:emergency_incidents')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'emergency_incidents',
          callback: (payload) {
            if (_userRole == 'Barangay') {
              final newIncident = payload.newRecord;
              LocalNotificationService.showNotification(
                id: DateTime.now().millisecond,
                title: '🚨 NEW EMERGENCY ALERT',
                body: '${newIncident['type']} reported at ${newIncident['location']}',
              );
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'emergency_incidents',
          callback: (payload) {
            final newRecord = payload.newRecord;
            
            // Check if user is the reporter to notify about status changes
            if (newRecord['reported_by'] == currentUser.id) {
              final newStep = newRecord['step'] as int;
              
              // We notify if step is > 0 (meaning it was updated from initial pending state)
              if (newStep > 0) {
                String statusMsg = _getStepMessage(newStep);
                LocalNotificationService.showNotification(
                  id: DateTime.now().millisecond,
                  title: 'Emergency Update',
                  body: 'Status: $statusMsg',
                );
              }
            }
          },
        )
        .subscribe();
  }

  static String _getStepMessage(int step) {
    switch (step) {
      case 1: return 'Responders have been assigned.';
      case 2: return 'Responders are on their way!';
      case 3: return 'Emergency has been resolved.';
      default: return 'Your request is being updated.';
    }
  }

  static void stop() {
    if (_emergencyChannel != null) {
      _supabase.removeChannel(_emergencyChannel!);
      _emergencyChannel = null;
    }
    _userRole = null;
  }
}
