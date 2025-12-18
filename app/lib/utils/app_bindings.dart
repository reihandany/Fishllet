// lib/utils/app_bindings.dart
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/orders_controller.dart';
import '../controllers/theme_controller.dart';

import '../services/api_services.dart';

/// AppBindings - Dependency Injection utama aplikasi menggunakan GetX
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ==================== SERVICES ====================
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    // External TheMealDB services removed

    // ==================== CONTROLLERS ====================

    // Auth Controller
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Product Controller → eager load
    Get.put<ProductController>(ProductController(), permanent: true);

    // Theme Controller
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // Cart Controller
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // Checkout Controller
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);

    // Orders Controller
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}
