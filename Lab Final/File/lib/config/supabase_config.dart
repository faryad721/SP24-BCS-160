import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _urlKey = 'supabase_url';
  static const String _anonKey = 'supabase_anon_key';

  // ─── DEFAULT PLACEHOLDERS ──────────────────────────────────────────────────
  // Replace these with your actual Supabase project URL and anon key,
  // or enter them at runtime via the Setup screen.
  static const String defaultUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String defaultAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  // ──────────────────────────────────────────────────────────────────────────

  static Future<String> getUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey) ?? defaultUrl;
  }

  static Future<String> getAnonKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_anonKey) ?? defaultAnonKey;
  }

  static Future<void> save({required String url, required String anonKey}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url.trim());
    await prefs.setString(_anonKey, anonKey.trim());
  }

  static Future<bool> isConfigured() async {
    final url = await getUrl();
    final key = await getAnonKey();
    return url != defaultUrl &&
        key != defaultAnonKey &&
        url.startsWith('https://') &&
        key.length > 20;
  }

  static Future<void> initSupabase() async {
    final url = await getUrl();
    final key = await getAnonKey();
    await Supabase.initialize(url: url, anonKey: key);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
