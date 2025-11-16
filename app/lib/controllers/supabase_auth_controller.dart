// lib/controllers/supabase_auth_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/supabase_auth_service.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE AUTH CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Controller untuk mengelola autentikasi user dengan Supabase.
/// Mengintegrasikan dengan GetX untuk reactive state management.
/// Provides:
/// - Sign up / login / logout
/// - Current user state
/// - Error handling
/// - Loading states
class SupabaseAuthController extends GetxController {
  late SupabaseAuthService _authService;

  // ─────────────────────────────────────────────────────────────────────────
  // OBSERVABLE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// User yang sedang login
  Rx<User?> currentUser = Rx<User?>(null);

  /// Status authentication
  var isAuthenticated = false.obs;

  /// Loading state untuk auth operations
  var isLoading = false.obs;

  /// Error message
  var errorMessage = ''.obs;

  /// Email field (untuk form)
  var email = ''.obs;

  /// Password field (untuk form)
  var password = ''.obs;

  /// Full name field (untuk sign up)
  var fullName = ''.obs;

  /// Password visibility toggle
  var isPasswordVisible = false.obs;

  /// Auth state stream subscription
  late StreamSubscription<AuthState> _authStateSubscription;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _authService = SupabaseAuthService();
    _checkCurrentUser();
    _listenAuthStateChanges();
  }

  @override
  void onClose() {
    _authStateSubscription.cancel();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Sign up user dengan email dan password
  /// @param email - Email user
  /// @param password - Password (min 6 karakter)
  /// @param fullName - Nama lengkap user (disimpan di metadata)
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        Get.snackbar(
          'Success',
          'Account created successfully. Please check your email to verify.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return true;
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Sign Up Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Sign up error: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Failed to create account',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Sign up error: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  /// Login user dengan email dan password
  /// @param email - Email user
  /// @param password - Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        isAuthenticated.value = true;
        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return true;
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Login error: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Failed to login',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Login error: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _authService.logout();

      currentUser.value = null;
      isAuthenticated.value = false;
      email.value = '';
      password.value = '';
      fullName.value = '';
      errorMessage.value = '';

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Logout Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Logout error: ${e.message}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Send password reset email
  /// @param email - Email user
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(email);

      Get.snackbar(
        'Success',
        'Password reset email sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Check current user dari Supabase
  void _checkCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user != null) {
      currentUser.value = user;
      isAuthenticated.value = true;
      debugPrint('✅ User found: ${user.email}');
    } else {
      isAuthenticated.value = false;
      debugPrint('❌ No user authenticated');
    }
  }

  /// Listen perubahan auth state
  void _listenAuthStateChanges() {
    _authStateSubscription = _authService.authStateChanges.listen(
      (state) {
        final session = state.session;
        if (session != null) {
          currentUser.value = session.user;
          isAuthenticated.value = true;
          debugPrint('✅ Auth state: User logged in - ${session.user.email}');
        } else {
          currentUser.value = null;
          isAuthenticated.value = false;
          debugPrint('❌ Auth state: User logged out');
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get current user ID
  String? get userId => currentUser.value?.id;

  /// Get current user email
  String? get userEmail => currentUser.value?.email;

  /// Get user full name dari metadata
  String? get userFullName => currentUser.value?.userMetadata?['full_name'] as String?;
}
