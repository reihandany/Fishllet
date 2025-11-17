// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// AUTH CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Mengelola state authentication user:
/// - Login/logout
/// - Loading state
/// - Password visibility toggle
/// - User data
class AuthController extends GetxController {
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

  // ─────────────────────────────────────────────────────────────────────────
  // METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Login user
  /// @param user - username yang diinput
  void login(String user) {
    username.value = user;
    isLoggedIn.value = true;
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

      // Reset state
      username.value = '';
      isLoggedIn.value = false;
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
