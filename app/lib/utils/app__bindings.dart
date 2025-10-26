// lib/utils/app_bindings.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../services/api_services.dart';

// Sesuai modul, gunakan GetX
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi service dan controller
    Get.lazyPut(() => ApiService());
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => ProductController(apiService: Get.find()));
    Get.lazyPut(() => CartController());
  }
}