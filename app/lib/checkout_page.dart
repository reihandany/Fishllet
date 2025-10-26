// lib/checkout_page.dart

import 'package:flutter/material.dart';
import 'product.dart';

class CheckoutPage extends StatelessWidget {
  final List<Product> cart;
  final VoidCallback checkout;
  // final VoidCallback clearCart; // clearCart tidak digunakan di sini, bisa dihapus

  const CheckoutPage({super.key, required this.cart, required this.checkout});

  void confirmCheckout(BuildContext context) {
    checkout();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pesanan Berhasil'),
        content: const Text('Pesanan Anda telah diterima!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // kembali ke keranjang
              Navigator.pop(context); // kembali ke produk
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
            const Text('Konfirmasi Pesanan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2380c4))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, idx) {
                  final product = cart[idx];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(product.price),
                  );
                },
              ),
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