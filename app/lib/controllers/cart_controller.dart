// lib/controllers/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CART CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Mengelola shopping cart:
/// - Add/remove products
/// - Update quantity
/// - Calculate total price
/// - Checkout process
class CartController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // OBSERVABLE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// List produk di cart
  var cart = <Product>[].obs;

  /// List orders history
  var orders = <List<Product>>[].obs;

  /// Loading state untuk async operations
  var isLoading = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // COMPUTED PROPERTIES
  // ─────────────────────────────────────────────────────────────────────────

  /// Total items di cart (sum of all quantities)
  int get totalItems {
    return cart.fold(0, (sum, product) => sum + product.quantity);
  }

  /// Total harga semua produk di cart
  double get totalPrice {
    return cart.fold(0.0, (sum, product) {
      // Parse price string (Rp 45.000 → 45000)
      final priceStr = product.price.replaceAll(RegExp(r'[^0-9]'), '');
      final price = double.tryParse(priceStr) ?? 0.0;
      return sum + (price * product.quantity);
    });
  }

  /// Format currency (45000 → Rp 45.000)
  String get formattedTotalPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CART OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Add product to cart
  /// - Check if product already exists
  /// - If exists, increase quantity
  /// - If not, add new product with quantity = 1
  void addToCart(Product product) {
    // Check if product already in cart
    final existingIndex = cart.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      // Product exists, increase quantity
      cart[existingIndex].quantity++;
      cart.refresh(); // Trigger UI update

      Get.snackbar(
        'Quantity Updated',
        '${product.name} quantity increased to ${cart[existingIndex].quantity}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2380c4),
        colorText: Colors.white,
        icon: const Icon(Icons.add_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      // Product not in cart, add new
      product.quantity = 1; // Reset quantity
      cart.add(product);

      Get.snackbar(
        'Added to Cart',
        '${product.name} added to cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Remove product from cart
  void removeFromCart(Product product) {
    cart.removeWhere((p) => p.id == product.id);

    Get.snackbar(
      'Removed',
      '${product.name} removed from cart',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.delete, color: Colors.white),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Increase quantity
  void increaseQuantity(Product product) {
    final index = cart.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      cart[index].quantity++;
      cart.refresh(); // Trigger UI update
    }
  }

  /// Decrease quantity
  /// - If quantity > 1, decrease
  /// - If quantity == 1, remove from cart
  void decreaseQuantity(Product product) {
    final index = cart.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
        cart.refresh(); // Trigger UI update
      } else {
        // Quantity = 1, remove from cart
        removeFromCart(product);
      }
    }
  }

  /// Clear all items from cart
  void clearCart() {
    if (cart.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Your cart is already empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Clear Cart',
      middleText: 'Are you sure you want to clear all items?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () {
        cart.clear();
        Get.back(); // Close dialog
        Get.snackbar(
          'Cart Cleared',
          'All items removed from cart',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHECKOUT
  // ─────────────────────────────────────────────────────────────────────────

  /// Checkout process
  void checkout() {
    if (cart.isNotEmpty) {
      orders.add(List<Product>.from(cart)); // Save to orders
      cart.clear(); // Clear cart
    }
  }

  /// Validate stock (simulasi async operation)
  Future<bool> validateStock() async {
    isLoading.value = true;

    // Simulasi API call untuk validasi stock (2 detik)
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Return true (stock available)
    return true;
  }
}
