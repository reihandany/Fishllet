// lib/views/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart'; // <-- Pastikan import dari '/models/'
import '../controllers/cart_controller.dart';

class ProductDetailPage extends StatelessWidget {
  // Ambil CartController
  final CartController cartController = Get.find<CartController>();
  
  // HANYA terima 'product'. 'onAddToCart' dihapus.
  final Product product;

  ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2380c4))),
            const SizedBox(height: 12),
            Text(product.price, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            // Tampilkan deskripsi dari API (jika ada)
            Text(product.description ?? 'Tidak ada deskripsi.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Tambah ke Keranjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2380c4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Panggil fungsi dari controller
                  cartController.addToCart(product);
                  // (Snackbar akan di-handle oleh controller)
                  Navigator.pop(context); // Kembali ke halaman produk
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}