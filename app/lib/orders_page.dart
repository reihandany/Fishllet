// lib/orders_page.dart

import 'package:flutter/material.dart';
import 'product.dart';

class OrdersPage extends StatelessWidget {
  final List<List<Product>> orders;
  const OrdersPage({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, idx) {
                final order = orders[idx];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('Pesanan #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order.map((p) => Text('- ${p.name} (${p.price})')).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }
}