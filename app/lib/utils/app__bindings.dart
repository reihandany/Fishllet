// lib/utils/app_bindings.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/theme_controller.dart';

import '../services/api_services.dart';
import '../services/http_api_services.dart';
import '../services/dio_api_services.dart';

/// AppBindings - Central Dependency Injection untuk semua Controller & Service
///
/// Mengelola lifecycle dan dependency injection menggunakan GetX Bindings.
/// Semua controller dan service didaftarkan di sini untuk digunakan di seluruh aplikasi.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ==================== SERVICES ====================
    // Services di-inisialisasi dengan lazyPut agar hanya dibuat saat dibutuhkan
    // Ini menghemat memory dan meningkatkan performa startup

    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<HttpApiService>(() => HttpApiService(), fenix: true);
    Get.lazyPut<DioApiService>(() => DioApiService(), fenix: true);

    // ==================== CONTROLLERS ====================

    // 1. AuthController - Login/Logout management
    // Menggunakan lazyPut karena hanya dibutuhkan saat user belum login
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // 2. ProductController - Product data & API calls
    // Menggunakan put() agar langsung ter-inisialisasi (eager loading)
    // Karena product list dibutuhkan segera setelah login
    Get.put<ProductController>(ProductController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);


    // 3. CartController - Shopping cart management
    // Menggunakan lazyPut dengan fenix:true agar bisa recreate setelah logout
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // 4. CheckoutController - Checkout process
    // Menggunakan lazyPut karena hanya dibutuhkan di halaman checkout
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);

    // 5. OrdersController - Order history management
    // Menggunakan lazyPut dengan fenix:true untuk recreate setelah logout
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);

    // ==================== PENJELASAN ====================
    //
    // Get.put() vs Get.lazyPut():
    // - Get.put(): Langsung create instance saat app start (eager loading)
    //   → Digunakan untuk controller yang PASTI langsung dipakai (ProductController)
    //
    // - Get.lazyPut(): Baru create instance saat pertama kali dipanggil (lazy loading)
    //   → Digunakan untuk controller yang MUNGKIN dipakai (Auth, Cart, Checkout, Orders)
    //   → Menghemat memory karena tidak semua controller langsung dibuat
    //
    // fenix: true
    // - Controller akan di-recreate jika sudah di-delete sebelumnya
    // - Berguna untuk controller yang mungkin di-reset saat logout
    //
    // permanent: true
    // - Controller tidak akan pernah di-delete dari memory
    // - Digunakan untuk controller yang selalu dibutuhkan (ProductController)
  }
}
