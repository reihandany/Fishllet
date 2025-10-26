// lib/views/cart_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'checkout_page.dart'; // <-- Pastikan Anda punya file ini & sudah di-refactor

class CartPage extends StatelessWidget {
  // --- PERBAIKAN ---
  // Constructor kosong, tidak menerima parameter
  CartPage({super.key});

  // Ambil CartController menggunakan Get.find()
  final CartController cartController = Get.find<CartController>();
  // --- BATAS PERBAIKAN ---

  void openCheckout(BuildContext context) {
    // Panggil CheckoutPage() tanpa argumen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      // Gunakan Obx untuk mendengarkan perubahan data keranjang
      body: Obx(() => cartController.cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartController.cart.length,
                    itemBuilder: (context, idx) {
                      final product = cartController.cart[idx];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(product.price),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2380c4),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => openCheckout(context),
                          child: const Text('Checkout'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          // Panggil fungsi dari controller
                          onPressed: cartController.clearCart,
                          child: const Text('Kosongkan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
    );
  }
}