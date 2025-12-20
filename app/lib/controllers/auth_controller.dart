// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AUTH CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Mengelola state authentication user:
/// - Login/logout
/// - Loading state
/// - Password visibility toggle
/// - User data
/// - Persistent login (tetap login saat aplikasi ditutup)
class AuthController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // CONSTANTS FOR SHARED PREFERENCES KEYS
  // ─────────────────────────────────────────────────────────────────────────
  static const String _keyIsLoggedIn = 'auth_isLoggedIn';
  static const String _keyUsername = 'auth_username';
  static const String _keyIsGuest = 'auth_isGuest';

  // ─────────────────────────────────────────────────────────────────────────
  // OBSERVABLE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Status login user (true = sudah login, false = belum)
  var isLoggedIn = false.obs;

  /// Username user yang sedang login
  var username = ''.obs;

  /// Loading state untuk proses login/logout
  var isLoading = false.obs;

  /// Password visibility toggle (untuk show/hide password)
  var isPasswordVisible = false.obs;

  /// Guest mode flag (true = login sebagai guest, false = login normal)
  var isGuest = false.obs;
  
  /// Flag untuk menandakan auth state sudah di-load dari storage
  var isAuthLoaded = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE METHODS
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Load saved auth state when controller initializes
    loadAuthState();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PERSISTENT AUTH METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Load auth state from SharedPreferences
  /// Dipanggil saat app start untuk memulihkan session login
  Future<void> loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedIsLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final savedUsername = prefs.getString(_keyUsername) ?? '';
      final savedIsGuest = prefs.getBool(_keyIsGuest) ?? false;
      
      debugPrint('🔍 Loading auth: isLoggedIn=$savedIsLoggedIn, username=$savedUsername, isGuest=$savedIsGuest');
      
      if (savedIsLoggedIn && savedUsername.isNotEmpty) {
        isLoggedIn.value = savedIsLoggedIn;
        username.value = savedUsername;
        isGuest.value = savedIsGuest;
        
        debugPrint('✅ Auth restored: $savedUsername (guest: $savedIsGuest)');
      } else {
        debugPrint('ℹ️ No saved auth state found');
      }
    } catch (e) {
      debugPrint('❌ Error loading auth state: $e');
    } finally {
      // Mark auth as loaded regardless of success/failure
      isAuthLoaded.value = true;
      debugPrint('✅ Auth loading completed, isLoggedIn=${isLoggedIn.value}');
    }
  }

  /// Save auth state to SharedPreferences
  /// Dipanggil setelah login berhasil
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_keyIsLoggedIn, isLoggedIn.value);
      await prefs.setString(_keyUsername, username.value);
      await prefs.setBool(_keyIsGuest, isGuest.value);
      
      debugPrint('✅ Auth state saved: ${username.value}');
    } catch (e) {
      debugPrint('❌ Error saving auth state: $e');
    }
  }

  /// Clear auth state from SharedPreferences
  /// Dipanggil saat logout
  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUsername);
      await prefs.remove(_keyIsGuest);
      
      debugPrint('✅ Auth state cleared');
    } catch (e) {
      debugPrint('❌ Error clearing auth state: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Login user
  /// @param user - username yang diinput
  Future<void> login(String user) async {
    username.value = user;
    isLoggedIn.value = true;
    isGuest.value = false;
    
    // Save to persistent storage
    await _saveAuthState();
  }

  /// Login sebagai Guest
  /// - Set username = 'Guest'
  /// - Set isLoggedIn = true
  /// - Set isGuest = true
  Future<void> loginAsGuest() async {
    username.value = 'Guest';
    isLoggedIn.value = true;
    isGuest.value = true;
    
    // Save to persistent storage
    await _saveAuthState();
  }

  /// Logout user
  /// - Clear username
  /// - Set isLoggedIn = false
  /// - Clear cart & orders
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Sign out dari Supabase
      await Supabase.instance.client.auth.signOut();

      // Clear persistent storage
      await _clearAuthState();

      // Reset state
      username.value = '';
      isLoggedIn.value = false;
      isGuest.value = false;
      isLoading.value = false;

      // Navigate ke login page
      Get.offAllNamed('/login');

      // Show success message
      Get.snackbar(
        'Logout Berhasil',
        'Anda telah keluar dari aplikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Logout Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
