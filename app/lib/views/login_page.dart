// lib/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'product_list_page.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form key untuk validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────────────────────────────────
  // VALIDATION METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Validasi username
  /// - Tidak boleh kosong
  /// - Minimal 3 karakter
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
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
      // Form tidak valid, error message sudah ditampilkan di TextField
      return;
    }

    try {
      // Set loading state
      authController.isLoading.value = true;

      // Simulasi proses login (misal: API call)
      await Future.delayed(const Duration(seconds: 2));

      // Panggil login dari controller
      authController.login(_usernameController.text);

      // Reset loading state
      authController.isLoading.value = false;

      // Check apakah login berhasil
      if (authController.isLoggedIn.value) {
        // Login berhasil - navigate dengan Get.offAll()
        // offAll() akan clear semua route sebelumnya (tidak bisa back ke login)
        Get.offAll(
          () => ProductListPage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );

        // Show success message
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${_usernameController.text}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        // Login gagal
        _showLoginError('Username atau password salah');
      }
    } catch (e) {
      // Handle error
      authController.isLoading.value = false;
      _showLoginError('Terjadi kesalahan: $e');
    }
  }

  /// Tampilkan error message dengan Snackbar
  void _showLoginError(String message) {
    Get.snackbar(
      'Login Gagal',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2380c4), // Ocean blue background
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
                  // ───────────────────────────────────────────────────────
                  // LOGO & TITLE
                  // ───────────────────────────────────────────────────────
                  _buildLogo(),
                  const SizedBox(height: 16),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 48),

                  // ───────────────────────────────────────────────────────
                  // USERNAME INPUT
                  // ───────────────────────────────────────────────────────
                  _buildUsernameField(),
                  const SizedBox(height: 20),

                  // ───────────────────────────────────────────────────────
                  // PASSWORD INPUT
                  // ───────────────────────────────────────────────────────
                  _buildPasswordField(),
                  const SizedBox(height: 32),

                  // ───────────────────────────────────────────────────────
                  // LOGIN BUTTON (dengan loading state)
                  // ───────────────────────────────────────────────────────
                  _buildLoginButton(),
                  const SizedBox(height: 16),

                  // ───────────────────────────────────────────────────────
                  // DEMO INFO
                  // ───────────────────────────────────────────────────────
                  _buildDemoInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═════════════════════════════════════════════════════════════════════════

  /// Logo icon
  Widget _buildLogo() {
    return const Icon(
      Icons.set_meal_rounded, // Fish/seafood icon
      size: 80,
      color: Colors.white,
    );
  }

  /// App title
  Widget _buildTitle() {
    return const Text(
      'Fishllet',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Subtitle
  Widget _buildSubtitle() {
    return const Text(
      'Fresh Seafood Marketplace',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Username input field dengan validation
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      validator: _validateUsername,
      textInputAction: TextInputAction.next, // Next button di keyboard
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Masukkan username Anda',
        prefixIcon: const Icon(Icons.person_outline),
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
        // Error style
        errorStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Password input field dengan validation
  Widget _buildPasswordField() {
    return Obx(() {
      // Reactive untuk show/hide password dari AuthController

      return TextFormField(
        controller: _passwordController,
        validator: _validatePassword,
        obscureText: !authController.isPasswordVisible.value,
        textInputAction: TextInputAction.done, // Done button di keyboard
        onFieldSubmitted: (_) => _handleLogin(), // Submit saat tekan done
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Masukkan password Anda',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              authController.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () {
              authController.togglePasswordVisibility();
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
        ),
      );
    });
  }

  /// Login button dengan loading state
  Widget _buildLoginButton() {
    return Obx(() {
      // Reactive - rebuild saat isLoading berubah
      final isLoading = authController.isLoading.value;

      return SizedBox(
        height: 56, // Consistent button height
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleLogin, // Disable saat loading
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2380c4),
            disabledBackgroundColor: Colors.white70, // Color saat disabled
            disabledForegroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: isLoading ? 0 : 2,
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2380c4),
                        ),
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
    });
  }

  /// Demo info text
  Widget _buildDemoInfo() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        'Demo: Username minimal 3 karakter, Password minimal 6 karakter',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white60,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
