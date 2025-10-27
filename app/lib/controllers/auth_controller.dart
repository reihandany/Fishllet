// lib/controllers/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

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
    if (user.isNotEmpty) {
      username.value = user;
      isLoggedIn.value = true;
    }
  }

  /// Logout user
  /// - Clear username
  /// - Set isLoggedIn = false
  /// - Clear cart & orders
  void logout() {
    username.value = '';
    isLoggedIn.value = false;
    isLoading.value = false;

    // Clear cart saat logout
    try {
      Get.find<CartController>().cart.clear();
      Get.find<CartController>().orders.clear();
    } catch (e) {
      // CartController belum ada, skip
      debugPrint('CartController not found: $e');
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
