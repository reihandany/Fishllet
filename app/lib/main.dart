// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/product_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/checkout_controller.dart';
import 'utils/app__bindings.dart';
import 'views/login_page.dart';
import 'views/product_list_page.dart';
import 'views/checkout_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'services/fcm_service.dart';


/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN ENTRY POINT
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Entry point aplikasi Fishllet.
/// Menginisialisasi bindings, error handling, dan konfigurasi global.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load .env
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FCM
  await FCMService.initializeFCM();
  FCMService.listenTokenRefresh();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
    // Initialize ThemeController first (before AppBindings)
    Get.put<ThemeController>(ThemeController(), permanent: true);
    debugPrint('✅ ThemeController initialized');
    
    // Load theme
    await Get.find<ThemeController>().loadTheme();
    debugPrint('✅ Theme loaded');
    
    AppBindings().dependencies();
    debugPrint('✅ AppBindings initialized successfully');

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
    // Get existing controllers (already initialized in AppBindings)
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fishllet',
      themeMode: themeController.isDark.value ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      // Set initial route
      initialRoute: '/login',
      // Define named routes
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/products', page: () => const ProductListPage()),
        GetPage(
          name: '/checkout',
          page: () => CheckoutPage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<CheckoutController>(() => CheckoutController());
          }),
        ),
      ],
    ));
  }
}

/// ═════════════════════════════════════════════════════════════════════════
/// DARK THEME
/// ═════════════════════════════════════════════════════════════════════════
///
/// Custom dark theme (optional, untuk future implementation).
// Error app jika initialization gagal
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Pastikan:\n1. File .env ada di root project\n2. SUPABASE_URL dan SUPABASE_ANON_KEY sudah diisi\n3. Semua dependency sudah terinstall (flutter pub get)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
