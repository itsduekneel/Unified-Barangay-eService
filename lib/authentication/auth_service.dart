import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_info.dart';

// ─── AUTH SERVICE ─────────────────────────────────────────────────────────────

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Registration ─────────────────────────────────────────────────────────

  /// Registers a new user and saves their profile to [user_profiles].
  ///
  /// Flow:
  ///  1. Pre-check: if a profile with this email already exists → block.
  ///  2. signUp → get userId.
  ///  3. If signUp says "already registered" (orphan) → sign in to recover userId.
  ///  4. Upsert profile using the service-role workaround for RLS.
  static Future<void> register(UserInfo info) async {
    debugPrint('[AuthService] register() — ${info.emailAddress}');

    // ── Step 1: pre-check for existing profile ───────────────────────────
    // Guards against silent duplicate upserts when email confirmation is off.
    try {
      final existing = await _client
          .from('user_profiles')
          .select('id')
          .eq('email', info.emailAddress)
          .maybeSingle();

      if (existing != null) {
        debugPrint('[AuthService] Duplicate email detected in profile table.');
        throw AuthException(
          'This email address is already in use. '
          'Please sign in or use a different email.',
        );
      }
    } on PostgrestException catch (e) {
      // If table doesn't exist yet, skip the pre-check and let Step 4 surface it.
      if (e.code != '42P01') rethrow;
    }

    // ── Step 2: create (or recover) the auth user ────────────────────────
    String userId;

    try {
      final response = await _client.auth.signUp(
        email: info.emailAddress,
        password: info.password,
      );

      if (response.user?.id == null) {
        throw AuthException(
          'Registration failed — no user ID returned. Please try again.',
        );
      }

      userId = response.user!.id;
      debugPrint('[AuthService] Auth user created: $userId');
    } on AuthException catch (e) {
      debugPrint('[AuthService] signUp error: ${e.message}');

      final msg = e.message.toLowerCase();
      final isAlreadyRegistered =
          msg.contains('already registered') ||
          msg.contains('already been registered') ||
          msg.contains('user already exists');

      if (!isAlreadyRegistered) rethrow;

      // Orphan recovery: auth user exists but no profile row.
      debugPrint('[AuthService] Orphan auth user — recovering via sign-in...');
      try {
        final signInResponse = await _client.auth.signInWithPassword(
          email: info.emailAddress,
          password: info.password,
        );
        userId = signInResponse.user!.id;
        debugPrint('[AuthService] Recovered orphan userId: $userId');
      } catch (_) {
        throw AuthException(
          'This email address is already in use. '
          'Please sign in or use a different email.',
        );
      }
    }

    // ── Step 3: ensure we have an active session before the RLS insert ───
    //
    // After signUp, the session is already set on the client. But if signUp
    // returned a user without a session (email confirmation flow), we must
    // sign in explicitly so auth.uid() is populated when the RLS policy runs.
    if (_client.auth.currentSession == null) {
      debugPrint('[AuthService] No active session — signing in to set it...');
      try {
        await _client.auth.signInWithPassword(
          email: info.emailAddress,
          password: info.password,
        );
        debugPrint('[AuthService] Session established.');
      } catch (e) {
        debugPrint('[AuthService] Could not establish session: $e');
        // Not fatal — the upsert may still work if RLS is configured correctly.
      }
    }

    // ── Step 4: upsert the profile row ───────────────────────────────────
    try {
      await _client.from('user_profiles').upsert(
        info.toSupabaseMap(userId),
        onConflict: 'id',
      );
      debugPrint('[AuthService] Profile saved for $userId');
    } on PostgrestException catch (e) {
      debugPrint('[AuthService] Profile error: ${e.message} (code: ${e.code})');

      if (e.code == '42P01') {
        throw AuthException(
          'Table "user_profiles" not found. '
          'Please run supabase_setup.sql and try again.',
        );
      }

      // RLS violation — session was not set in time.
      if (e.code == '42501' || (e.message.contains('row-level security'))) {
        throw AuthException(
          'Permission denied. Please make sure you ran supabase_setup.sql '
          'with the correct RLS policies.',
        );
      }

      throw AuthException('Could not save your profile: ${e.message}');
    }

    debugPrint('[AuthService] Registration complete.');
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
      debugPrint('[AuthService] Login success — uid: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      debugPrint('[AuthService] Login error: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
        throw AuthException('Incorrect email or password. Please try again.');
      }
      if (msg.contains('email not confirmed')) {
        throw AuthException(
          'Please verify your email before signing in. '
          'Check your inbox for a confirmation link.',
        );
      }
      rethrow;
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _client.auth.signOut();
    debugPrint('[AuthService] Signed out.');
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;
}
