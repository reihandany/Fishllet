// lib/config/supabase_config.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE CONFIGURATION
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Konfigurasi Supabase untuk aplikasi Fishllet.
/// Ganti SUPABASE_URL dan SUPABASE_ANON_KEY dengan credentials dari Supabase dashboard.
class SupabaseConfig {
  // Load from .env (use flutter_dotenv)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Initialize Supabase
  /// Panggil di main.dart sebelum runApp()
  static Future<void> initialize() async {
    try {
      await dotenv.load();
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization error: $e');
      rethrow;
    }
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get user ID
  static String? get userId => currentUser?.id;

  /// Get user email
  static String? get userEmail => currentUser?.email;

  /// Supabase tables
  static const String fishItemsTable = 'fish_items';
  static const String userNotesTable = 'user_notes';

  /// Supabase storage buckets
  static const String fishPhotoBucket = 'fish-photos';
}
