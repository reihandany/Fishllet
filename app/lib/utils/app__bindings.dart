// lib/utils/app__bindings.dart
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
