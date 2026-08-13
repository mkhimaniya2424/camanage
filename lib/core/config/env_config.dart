import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central place to read environment configuration.
///
/// Values are loaded from `.env` (via flutter_dotenv) at app startup.
/// Never hardcode SUPABASE_URL / SUPABASE_ANON_KEY anywhere else —
/// always read them through this class.
class EnvConfig {
  EnvConfig._();

  static String get supabaseUrl => _require('SUPABASE_URL');

  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty || value.startsWith('your-')) {
      throw StateError(
        'Missing or unset "$key" in .env. '
        'Copy .env.example to .env and fill in your Supabase project values.',
      );
    }
    return value;
  }
}
