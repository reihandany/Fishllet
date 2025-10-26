// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
class AuthController extends GetxController {
  // Gunakan .obs untuk membuat variabel reaktif (Reactive)
  var isLoggedIn = false.obs;
  var username = ''.obs;

  void login(String user) {
    if (user.isNotEmpty) {
      username.value = user;
      isLoggedIn.value = true;
    }
  }

  void logout() {
    username.value = '';
    isLoggedIn.value = false;
    // (Opsional) Hapus juga data cart saat logout
    Get.find<CartController>().cart.clear();
    Get.find<CartController>().orders.clear();
  }
}