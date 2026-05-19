import 'package:supabase_flutter/supabase_flutter.dart';

enum EmergencyStatus { pending, responding, resolved }

class EmergencyIncident {
  final String id;
  final String type;
  final double lat;
  final double lng;
  final EmergencyStatus status;
  final DateTime createdAt;

  EmergencyIncident({
    required this.id,
    required this.type,
    required this.lat,
    required this.lng,
    required this.status,
    required this.createdAt,
  });
}

abstract class EmergencyRepository {
  Future<String> createIncident(String type, double lat, double lng);
  Stream<List<EmergencyIncident>> getLiveIncidents();
}

class EmergencyRepositoryImpl implements EmergencyRepository {
  final _client = Supabase.instance.client;

  @override
  Future<String> createIncident(String type, double lat, double lng) async {
    final response = await _client.from('emergency_incidents').insert({
      'type': type,
      'map_lat': lat,
      'map_lng': lng,
      'status': 'pending',
      'reported_by': _client.auth.currentUser?.id,
    }).select().single();
    
    return response['id'].toString();
  }

  @override
  Stream<List<EmergencyIncident>> getLiveIncidents() {
    return _client
        .from('emergency_incidents')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((map) => EmergencyIncident(
              id: map['id'].toString(),
              type: map['type'],
              lat: map['map_lat'],
              lng: map['map_lng'],
              status: EmergencyStatus.values.byName(map['status']),
              createdAt: DateTime.parse(map['created_at']),
            )).toList());
  }
}
