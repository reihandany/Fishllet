// lib/controllers/cart_controller.dart
import 'package:get/get.dart';
import '../models/product.dart';

class CartController extends GetxController {
  var cart = <Product>[].obs;
  var orders = <List<Product>>[].obs;

  void addToCart(Product product) {
    cart.add(product);
    Get.snackbar(
      'Berhasil Ditambahkan',
      '${product.name} ditambahkan ke keranjang!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void clearCart() {
    cart.clear();
  }

  void checkout() {
    if (cart.isNotEmpty) {
      orders.add(List<Product>.from(cart)); // Salin keranjang ke orders
      cart.clear(); // Kosongkan keranjang
    }
  }
}