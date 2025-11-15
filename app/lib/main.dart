// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'utils/app_bindings.dart';
import 'views/login_page.dart';
import 'views/product_list_page.dart';
import 'controllers/theme_controller.dart';
import 'controllers/product_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';



/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN ENTRY POINT
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Entry point aplikasi Fishllet.
/// Menginisialisasi bindings, error handling, dan konfigurasi global.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  try {
    AppBindings().dependencies();
    debugPrint('✅ AppBindings initialized successfully');

    // Load theme
    await Get.find<ThemeController>().loadTheme();

    // ⭐ NEW: load products on startup (tanpa tombol apapun)
    try {
      await Get.find<ProductController>().loadProducts();
      debugPrint('✅ Products loaded on startup');
    } catch (e) {
      debugPrint('❌ Error loading products on startup: $e');
    }

  } catch (e, stackTrace) {
    debugPrint('❌ Error initializing AppBindings: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('❌ Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}


/// ═══════════════════════════════════════════════════════════════════════════
/// MY APP - ROOT WIDGET
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Root widget dengan GetMaterialApp untuk mengaktifkan GetX state management.
/// Mengatur theme, navigation, dan initial route berdasarkan login status.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  final themeCtrl = Get.find<ThemeController>();

  return Obx(() => GetMaterialApp(
        // ─────────────────────────────────────────────────────────────────────
        // APP CONFIGURATION
        // ─────────────────────────────────────────────────────────────────────
        title: 'Fishllet - Fresh Seafood',
        debugShowCheckedModeBanner: false,

        // ─────────────────────────────────────────────────────────────────────
        // THEME CONFIGURATION
        // ─────────────────────────────────────────────────────────────────────
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: themeCtrl.isDark.value
            ? ThemeMode.dark
            : ThemeMode.light, // ← DI SINI PERUBAHANNYA

        // ─────────────────────────────────────────────────────────────────────
        // GETX CONFIGURATION
        // ─────────────────────────────────────────────────────────────────────
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),

        // ─────────────────────────────────────────────────────────────────────
        // INITIAL ROUTE
        // ─────────────────────────────────────────────────────────────────────
        home: _buildHomeWithErrorHandling(),
      ));
}

  /// ═════════════════════════════════════════════════════════════════════════
  /// BUILD HOME WITH ERROR HANDLING
  /// ═════════════════════════════════════════════════════════════════════════
  ///
  /// Membangun home page dengan error handling untuk mencegah crash
  /// jika AuthController belum ter-inisialisasi.
  Widget _buildHomeWithErrorHandling() {
    try {
      // Coba ambil AuthController
      return Obx(() {
        try {
          final authController = Get.find<AuthController>();

          // Tampilkan halaman sesuai login status
          return authController.isLoggedIn.value
              ? ProductListPage()
              : LoginPage();
        } catch (e) {
          // Fallback jika AuthController error
          debugPrint('❌ Error getting AuthController: $e');
          return _buildErrorPage('Controller initialization failed');
        }
      });
    } catch (e) {
      // Fallback jika Obx error
      debugPrint('❌ Error building Obx: $e');
      return _buildErrorPage('Failed to initialize app');
    }
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// ERROR PAGE
  /// ═════════════════════════════════════════════════════════════════════════
  ///
  /// Halaman error yang ditampilkan jika initialization gagal.
  Widget _buildErrorPage(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Retry initialization
                  try {
                    AppBindings().dependencies();
                    // Restart app (simple reload)
                    Get.reset();
                  } catch (e) {
                    debugPrint('❌ Retry failed: $e');
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// LIGHT THEME
  /// ═════════════════════════════════════════════════════════════════════════
  ///
  /// Custom light theme dengan branding Fishllet.
  ThemeData _buildLightTheme() {
    // Brand colors
    const Color primaryColor = Color(0xFF2380c4); // Ocean blue
    const Color secondaryColor = Color(0xFF00BCD4); // Cyan
    const Color accentColor = Color(0xFFFF6B6B); // Coral red
    const Color backgroundColor = Color(0xFFF5F5F5);
    const Color surfaceColor = Colors.white;

    return ThemeData(
      // ─────────────────────────────────────────────────────────────────────
      // COLOR SCHEME
      // ─────────────────────────────────────────────────────────────────────
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        brightness: Brightness.light,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // SCAFFOLD
      // ─────────────────────────────────────────────────────────────────────
      scaffoldBackgroundColor: backgroundColor,

      // ─────────────────────────────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // ELEVATED BUTTON
      // ─────────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // TEXT BUTTON
      // ─────────────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // INPUT DECORATION
      // ─────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON
      // ─────────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // TYPOGRAPHY
      // ─────────────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // ICON THEME
      // ─────────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: primaryColor, size: 24),
    );
  }

  /// ═════════════════════════════════════════════════════════════════════════
  /// DARK THEME
  /// ═════════════════════════════════════════════════════════════════════════
  ///
  /// Custom dark theme (optional, untuk future implementation).
  ThemeData _buildDarkTheme() {
    const Color primaryColor = Color(0xFF2380c4);
    const Color backgroundColor = Color(0xFF121212);
    const Color surfaceColor = Color(0xFF1E1E1E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
