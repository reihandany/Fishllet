// lib/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/auth_controller.dart';
import 'product_list_page.dart';
import 'register_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LOGIN PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman login dengan:
/// - Form validation (email/password tidak boleh kosong)
/// - Loading state dengan CircularProgressIndicator
/// - Error handling & messages
/// - Navigasi otomatis ke ProductListPage setelah login berhasil
/// - UI/UX yang polished dengan spacing & styling yang baik
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // ─────────────────────────────────────────────────────────────────────────
  // CONTROLLERS
  // ─────────────────────────────────────────────────────────────────────────

  // GetX AuthController untuk state management
  final AuthController authController = Get.find<AuthController>();

  // Text controllers untuk form input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key untuk validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Password visibility toggle
  final RxBool _obscurePassword = true.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Validasi email
  /// - Tidak boleh kosong
  /// - Format email harus valid
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    // Simple email validation
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null; // Valid
  }

  /// Validasi password
  /// - Tidak boleh kosong
  /// - Minimal 6 karakter
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null; // Valid
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN LOGIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Handle submit login
  /// - Validasi form
  /// - Show loading indicator
  /// - Call AuthController.login()
  /// - Navigate to ProductListPage atau show error
  Future<void> _handleLogin() async {
    // Tutup keyboard
    FocusScope.of(Get.context!).unfocus();

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      authController.isLoading.value = true;

      // Login ke Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      authController.isLoading.value = false;

      if (response.user != null) {
        // Ambil username dari metadata
        final username = response.user!.userMetadata?['username'] ??
            response.user!.email?.split('@')[0] ??
            'User';

        authController.login(username);

        Get.offAll(
          () => ProductListPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, $username!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        _showLoginError('Email atau password salah');
      }
    } on AuthException catch (e) {
      authController.isLoading.value = false;
      _showLoginError(e.message);
    } catch (e) {
      authController.isLoading.value = false;
      _showLoginError('Terjadi kesalahan: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ERROR HANDLING
  // ─────────────────────────────────────────────────────────────────────────

  /// Show login error message
  void _showLoginError(String message) {
    Get.snackbar(
      'Login Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI/UX
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2380c4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.set_meal_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  // Judul
                  const Text(
                    'Fishllet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Fresh Seafood Marketplace',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Email input
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Masukkan email Anda',
                      prefixIcon: const Icon(Icons.email_outlined),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Password input
                  Obx(() => TextFormField(
                    controller: _passwordController,
                    validator: _validatePassword,
                    obscureText: _obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Masukkan password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          _obscurePassword.value = !_obscurePassword.value;
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  )),
                  const SizedBox(height: 36),
                  // Tombol Login
                  Obx(() {
                    final isLoading = authController.isLoading.value;
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2380c4),
                          disabledBackgroundColor: Colors.white70,
                          disabledForegroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: isLoading ? 0 : 2,
                        ),
                        child: isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2380c4)),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Logging in...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Tombol Register di bawah login
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2380c4),
                        disabledBackgroundColor: Colors.white70,
                        disabledForegroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info demo
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Email harus valid, Password minimal 6 karakter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
