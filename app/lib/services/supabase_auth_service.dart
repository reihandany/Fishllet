// lib/services/supabase_auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE AUTH SERVICE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Service untuk mengelola autentikasi user menggunakan Supabase Auth.
/// Menyediakan fungsi:
/// - Sign up dengan email & password
/// - Login dengan email & password
/// - Logout
/// - Cek user yang sedang login
/// - Update profile/metadata user
/// - Get current user info
class SupabaseAuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Register user baru ke Supabase Auth
  /// [email] dan [password] wajib diisi
  /// [fullName] akan disimpan sebagai metadata
  Future<User?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      if (response.user != null) {
        print('✅ Sign up successful: ${response.user?.email}');
        return response.user;
      }
    } on AuthException catch (e) {
      print('❌ Sign up error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error during sign up: $e');
      rethrow;
    }
    return null;
  }

  /// Contoh pemanggilan:
  /// await signUp(email: 'user@email.com', password: 'password', fullName: 'Nama Lengkap');

  /// Login dengan email & password
  /// @param email - Email user
  /// @param password - Password
  /// Returns: User object jika berhasil login
  /// Throws: AuthException jika credential salah
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Login successful: ${response.user?.email}');
        return response.user;
      }
    } on AuthException catch (e) {
      print('❌ Login error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      rethrow;
    }
    return null;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      print('✅ Logout successful');
    } on AuthException catch (e) {
      print('❌ Logout error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error during logout: $e');
      rethrow;
    }
  }

  /// Get current logged in user
  /// Returns: User object jika ada user yang login, null jika tidak
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _client.auth.currentUser?.email;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _client.auth.currentUser != null;
  }

  /// Get user metadata
  Map<String, dynamic>? getUserMetadata() {
    return _client.auth.currentUser?.userMetadata;
  }

  /// Update user metadata
  /// @param metadata - Data baru untuk diupdate
  /// Returns: User object dengan metadata terupdate
  Future<User?> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(data: metadata),
      );

      if (response.user != null) {
        print('✅ User metadata updated successfully');
        return response.user;
      }
    } on AuthException catch (e) {
      print('❌ Update metadata error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error updating metadata: $e');
      rethrow;
    }
    return null;
  }

  /// Update user password
  /// @param newPassword - Password baru (min 6 karakter)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('✅ Password updated successfully');
    } on AuthException catch (e) {
      print('❌ Update password error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error updating password: $e');
      rethrow;
    }
  }

  /// Send password reset email
  /// @param email - Email user
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent to $email');
    } on AuthException catch (e) {
      print('❌ Reset password error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error sending reset email: $e');
      rethrow;
    }
  }

  /// Get auth state changes stream
  /// Gunakan untuk listen perubahan status autentikasi
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
