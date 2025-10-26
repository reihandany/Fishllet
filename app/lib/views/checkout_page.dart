// lib/views/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart'; // <-- IMPORT CONTROLLER

class CheckoutPage extends StatelessWidget {
  // --- PERBAIKAN DI SINI ---
  // Constructor kosong (hanya 'key')
  CheckoutPage({super.key});

  // Ambil CartController menggunakan Get.find()
  final CartController cartController = Get.find<CartController>();
  // --- BATAS PERBAIKAN ---

  void confirmCheckout(BuildContext context) {
    // Panggil fungsi checkout dari controller
    cartController.checkout();
    
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa menutup dialog dengan klik di luar
      builder: (context) => AlertDialog(
        title: const Text('Pesanan Berhasil'),
        content: const Text('Pesanan Anda telah diterima!'),
        actions: [
          TextButton(
            onPressed: () {
              // Pop 3x: 1. Tutup dialog, 2. Kembali dari Checkout, 3. Kembali dari Keranjang
              Navigator.pop(context); 
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Konfirmasi Pesanan',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2380c4))),
            const SizedBox(height: 16),
            Expanded(
              // Gunakan Obx karena 'orders' di-update oleh controller
              // Kita tampilkan item terakhir dari 'orders' (pesanan yg baru saja dibuat)
              // Tapi lebih mudah tetap tampilkan 'cart' SEBELUM di-clear
              // Jadi kita pakai 'cartController.cart' (meskipun sudah kosong setelah checkout)
              // Solusi lebih baik: Gunakan 'cartController.orders.last'
              child: Obx(() {
                // Ambil data dari controller, bukan constructor
                final cartData = cartController.cart;
                
                return ListView.builder(
                  // Gunakan data dari controller
                  itemCount: cartData.length,
                  itemBuilder: (context, idx) {
                    final product = cartData[idx];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(product.price),
                    );
                  },
                );
              }),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2380c4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => confirmCheckout(context),
                child: const Text('Konfirmasi & Pesan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}