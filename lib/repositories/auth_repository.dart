import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<AppUser?> signIn(String email, String password);
  Future<void> signUp(String email, String password, Map<String, dynamic> metadata);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Stream<AuthState> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AppUser?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return await _getUserProfile(response.user!.id);
    }
    return null;
  }

  @override
  Future<void> signUp(String email, String password, Map<String, dynamic> metadata) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
    
    if (response.user != null) {
      await _client.from('profiles').upsert({
        'id': response.user!.id,
        'email': email,
        ...metadata,
        'role': 'resident',
        'is_active': true,
      });
    }
  }

  @override
  Future<void> signOut() async => await _client.auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) return await _getUserProfile(user.id);
    return null;
  }

  Future<AppUser?> _getUserProfile(String id) async {
    final data = await _client.from('profiles').select().eq('id', id).maybeSingle();
    if (data != null) return AppUser.fromMap(data);
    return null;
  }
}
