// lib/utils/app__bindings.dart
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/checkout_controller.dart';
import '../controllers/orders_controller.dart';

import '../services/api_services.dart';
import '../services/http_api_services.dart';
import '../services/dio_api_services.dart';

/// AppBindings - Dependency Injection utama aplikasi menggunakan GetX
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ==================== SERVICES ====================
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<HttpApiService>(() => HttpApiService(), fenix: true);
    Get.lazyPut<DioApiService>(() => DioApiService(), fenix: true);

    // ==================== CONTROLLERS ====================

    // Auth Controller
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Product Controller → eager load
    Get.put<ProductController>(ProductController(), permanent: true);

    // Cart Controller
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // Checkout Controller
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);

    // Orders Controller
    Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}
