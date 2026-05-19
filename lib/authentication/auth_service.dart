import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_info.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Registration ─────────────────────────────────────────────────────────

  /// Registers a new user and saves their profile to the [profiles] table.
  static Future<void> register(UserInfo info) async {
    debugPrint('[AuthService] register() — ${info.email}');

    try {
      // 1. Create the auth user
      final response = await _client.auth.signUp(
        email: info.email,
        password: info.password,
      );

      final userId = response.user?.id;
      if (userId == null) throw const AuthException('Registration failed - No user ID');

      // 2. Save the profile record
      // We use upsert on the 'profiles' table which is used throughout the app.
      await _client.from('profiles').upsert(
        info.toSupabaseMap(userId),
        onConflict: 'id',
      );
      
      debugPrint('[AuthService] Registration complete for $userId');
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('[AuthService] Unexpected error: $e');
      throw AuthException(e.toString());
    }
  }

  // ── Login ────────────────────────────────────────────────────────────────

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    debugPrint('[AuthService] login() — $email');
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _client.auth.signOut();
    debugPrint('[AuthService] Signed out.');
  }

  // ── OTP Verification ───────────────────────────────────────────────────────

  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
    } on AuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static AuthException _handleAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return const AuthException('Incorrect email or password. Please try again.');
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return const AuthException('This email is already registered. Please sign in instead.');
    }
    if (msg.contains('email not confirmed')) {
      return const AuthException('Please verify your email address before signing in.');
    }
    return e;
  }
}
