import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../models/profile.dart';

/// Friendly, UI-safe error for auth failures. Never surface raw
/// PostgrestException / AuthException messages directly to the user.
class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

/// All Supabase Auth calls go through here — UI/controllers never touch
/// `Supabase.instance.client.auth` directly.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  GoTrueClient get _auth => SupabaseService.client.auth;

  // ---------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------

  /// Current logged-in Supabase user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes (sign in / sign out / token refresh) —
  /// use this to drive the Splash → Login/Dashboard routing described
  /// in the spec.
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  // ---------------------------------------------------------------------
  // Sign up
  // ---------------------------------------------------------------------

  /// Creates the auth.users record. The matching `profiles` row is created
  /// automatically by a Postgres trigger (see ca_desk_auth_trigger.sql)
  /// reading `role` / `full_name` / `firm_id` out of the metadata below —
  /// this avoids a race where the client tries to insert into `profiles`
  /// before a session exists (e.g. when email confirmation is required).
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? firmId,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': userRoleToString(role),
          if (firmId != null) 'firm_id': firmId,
        },
      );
      return response;
    } on AuthException catch (e) {
      // ignore: avoid_print
      print('[AuthService.signUp] AuthException: ${e.message} | statusCode: ${e.statusCode}');
      throw AuthFailure(_mapAuthError(e));
    } catch (e) {
      // ignore: avoid_print
      print('[AuthService.signUp] Unknown error: $e');
      throw const AuthFailure(
        'Unable to create your account. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Login / Logout
  // ---------------------------------------------------------------------

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } catch (_) {
      throw const AuthFailure(
        'Unable to sign in right now. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  // ---------------------------------------------------------------------
  // Password management
  // ---------------------------------------------------------------------

  /// Sends a password-reset email. [redirectTo] should be a deep link
  /// configured in Supabase → Authentication → URL Configuration.
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo}) async {
    try {
      await _auth.resetPasswordForEmail(email, redirectTo: redirectTo);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Call after the user lands back in the app via the reset-password
  /// deep link and a recovery session is active.
  Future<void> resetPassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Change password for an already-signed-in user (re-auth not required
  /// by Supabase for this call as long as the session is valid).
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  // ---------------------------------------------------------------------
  // Email verification
  // ---------------------------------------------------------------------

  Future<void> resendEmailVerification(String email) async {
    try {
      await _auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // ---------------------------------------------------------------------
  // Current profile
  // ---------------------------------------------------------------------

  /// Fetches the `profiles` row for the signed-in user. Returns null if
  /// signed out, or if the profile-creation trigger hasn't run yet
  /// (e.g. immediately post-signup, pre email-confirmation).
  Future<Profile?> fetchCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      if (row == null) return null;
      return Profile.fromMap(row);
    } on PostgrestException {
      throw const AuthFailure('Unable to load your profile. Please try again.');
    }
  }

  // ---------------------------------------------------------------------
  // Error mapping — never show raw Supabase error text to the user.
  // ---------------------------------------------------------------------

  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    final code = (e.statusCode ?? '').toString();

    if (msg.contains('error sending confirmation email') ||
        msg.contains('unexpected_failure') ||
        code == '500') {
      return 'Account created but we could not send the confirmation email. '
          'Please contact support or try again later.';
    }
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('password') && msg.contains('short')) {
      return 'Password is too short. Use at least 6 characters.';
    }
    if (msg.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (msg.contains('network')) {
      return 'No internet connection. Please check your network and try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
