// lib/product_detail_page.dart

import 'package:flutter/material.dart';
import 'product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailPage({super.key, required this.product, required this.onAddToCart});

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
            Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2380c4))),
            const SizedBox(height: 12),
            Text(product.price, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            Text(product.description),
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
                  onAddToCart();
                  // Tampilkan Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} ditambahkan ke keranjang!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
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