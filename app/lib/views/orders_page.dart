// lib/views/orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart'; // <-- Import controller

class OrdersPage extends StatelessWidget {
  // Hapus 'orders' dari constructor
  OrdersPage({super.key});

  // Ambil CartController
  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      // Gunakan Obx untuk mendengarkan 'orders' dari controller
      body: Obx(() => cartController.orders.isEmpty
          ? const Center(child: Text('Belum ada pesanan'))
          : ListView.builder(
              itemCount: cartController.orders.length,
              itemBuilder: (context, idx) {
                final order = cartController.orders[idx];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('Pesanan #${idx + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: order
                          .map((p) => Text('- ${p.name} (${p.price})'))
                          .toList(),
                    ),
                  ),
                );
              },
            )),
    );
  }
}