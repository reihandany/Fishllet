// lib/controllers/checkout_controller.dart
import 'package:get/get.dart';
import '../models/product.dart';
import 'cart_controller.dart';
import 'orders_controller.dart';

class CheckoutController extends GetxController {
  // Loading state
  var isLoading = false.obs;

  // Form fields
  var customerName = ''.obs;
  var customerAddress = ''.obs;
  var paymentMethod = 'Cash'.obs;

  // Payment methods options
  final List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'E-Wallet',
    'Bank Transfer',
  ];

  // Get cart controller untuk akses data cart
  final CartController cartController = Get.find<CartController>();

  // Calculate total price
  double get totalPrice {
    return cartController.cart.fold(0.0, (sum, product) {
      // Parse price (hapus 'Rp' dan convert ke double)
      final priceStr = product.price.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceStr) ?? 0.0;
      return sum + price;
    });
  }

  // Get cart items
  List<Product> get cartItems => cartController.cart;

  // Form validation
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }

  // Submit checkout
  Future<bool> submitCheckout() async {
    try {
      // Validasi data
      if (customerName.value.isEmpty || customerAddress.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Mohon lengkapi semua data',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (cartItems.isEmpty) {
        Get.snackbar(
          'Error',
          'Keranjang kosong',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      isLoading.value = true;

      // Simulasi proses checkout ke server (2 detik)
      await Future.delayed(const Duration(seconds: 2));

      // Create order object
      final order = {
        'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        'customerName': customerName.value,
        'customerAddress': customerAddress.value,
        'paymentMethod': paymentMethod.value,
        'items': cartItems,
        'totalPrice': totalPrice,
        'orderDate': DateTime.now(),
        'status': 'Pending',
      };

      // Save to orders controller
      final ordersController = Get.find<OrdersController>();
      ordersController.addOrder(order);

      // Clear cart
      cartController.clearCart();

      // Reset form
      customerName.value = '';
      customerAddress.value = '';
      paymentMethod.value = 'Cash';

      isLoading.value = false;

      Get.snackbar(
        'Berhasil',
        'Pesanan berhasil dibuat!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal membuat pesanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Update form fields
  void updateName(String value) {
    customerName.value = value;
  }

  void updateAddress(String value) {
    customerAddress.value = value;
  }

  void updatePaymentMethod(String value) {
    paymentMethod.value = value;
  }
}
