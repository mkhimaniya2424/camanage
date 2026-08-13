import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

/// Thin wrapper around the Supabase client so the rest of the app
/// (features/services) never imports `supabase_flutter` directly.
/// This keeps the backend swappable later if needed.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  /// Call once, before runApp(). Reads config from .env only —
  /// no URL/key is ever hardcoded here or elsewhere.
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      publishableKey: EnvConfig.supabaseAnonKey,
    );

    _initialized = true;
  }

  /// The shared Supabase client. Only the public anon-key client is
  /// ever used inside Flutter — no service-role key belongs here.
  static SupabaseClient get client => Supabase.instance.client;

  static bool get isInitialized => _initialized;
}
