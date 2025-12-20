// lib/views/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';
import 'product_list_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SPLASH SCREEN
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Splash screen dengan animasi seperti Netflix
/// - Logo fade in + zoom
/// - Text subtitle muncul
/// - Auto navigate ke halaman yang sesuai berdasarkan status login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation (0.0 to 1.0)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Scale animation (zoom effect)
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Check auth state and navigate after animation
    _checkAuthAndNavigate();
  }

  /// Check authentication state and navigate to appropriate screen
  Future<void> _checkAuthAndNavigate() async {
    // Get auth controller
    final authController = Get.find<AuthController>();
    
    // Wait for auth state to be loaded from SharedPreferences
    // This ensures we check the correct login status
    while (!authController.isAuthLoaded.value) {
      await Future.delayed(const Duration(milliseconds: 100));
      debugPrint('⏳ Waiting for auth state to load...');
    }
    
    // Wait for minimum splash duration (at least 2 seconds for animation)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    debugPrint('🔍 Checking auth: isLoggedIn=${authController.isLoggedIn.value}, username=${authController.username.value}');
    
    // Check if user is logged in (from persistent storage)
    if (authController.isLoggedIn.value) {
      // User is logged in, navigate to product list
      debugPrint('✅ User sudah login: ${authController.username.value}');
      Get.off(
        () => const ProductListPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    } else {
      // User not logged in, navigate to login page
      debugPrint('ℹ️ User belum login, redirect ke login page');
      Get.off(
        () => LoginPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B8FCC),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo dengan animasi - MAKSIMAL BESAR, hampir full width
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        'assets/images/Fishllet Logo Design-01.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Subtitle dengan fade in delay
                    FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                        ),
                      ),
                      child: Text(
                        'Fresh Seafood Marketplace',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
