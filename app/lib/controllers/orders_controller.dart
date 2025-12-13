// lib/controllers/orders_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../services/fcm_service.dart';

class OrdersController extends GetxController {
  late Box ordersBox;
  // List of all orders
  var orders = <Map<String, dynamic>>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Filter/sort options
  var sortBy = 'date_desc'.obs; // date_desc, date_asc, price_desc, price_asc

  @override
  void onInit() async {
    super.onInit();
    // Open Hive box
    ordersBox = await Hive.openBox('orders');
    // Load orders from Hive
    loadOrders();
  }

  // Load orders from Hive
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;

      // Load from Hive
      final savedOrders = ordersBox.get('ordersList', defaultValue: []);
      if (savedOrders is List) {
        orders.value = List<Map<String, dynamic>>.from(
          savedOrders.map((order) => Map<String, dynamic>.from(order)),
        );
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal memuat pesanan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add new order
  Future<void> addOrder(Map<String, dynamic> order) async {
    orders.insert(0, order); // Tambah di paling atas (order terbaru)
    
    // Save to Hive
    await ordersBox.put('ordersList', orders.toList());

    // Tampilkan notifikasi lokal ketika pesanan berhasil ditambahkan
    try {
      await FCMService.showLocalNotification(
        title: 'Pesanan Diterima',
        body: 'Pesanan Anda berhasil dipesan.',
        payload: order.toString(),
      );
    } catch (e) {
      // Jika gagal menampilkan notifikasi, log saja
      debugPrint('❌ Gagal menampilkan notifikasi: $e');
    }
  }

  // Get total orders count
  int get totalOrders => orders.length;

  // Get total revenue (total semua pesanan)
  double get totalRevenue {
    return orders.fold(
      0.0,
      (sum, order) => sum + (order['totalPrice'] as double),
    );
  }

  // Get sorted orders
  List<Map<String, dynamic>> get sortedOrders {
    final List<Map<String, dynamic>> sorted = List.from(orders);

    switch (sortBy.value) {
      case 'date_asc':
        sorted.sort(
          (a, b) => (a['orderDate'] as DateTime).compareTo(
            b['orderDate'] as DateTime,
          ),
        );
        break;
      case 'date_desc':
        sorted.sort(
          (a, b) => (b['orderDate'] as DateTime).compareTo(
            a['orderDate'] as DateTime,
          ),
        );
        break;
      case 'price_asc':
        sorted.sort(
          (a, b) =>
              (a['totalPrice'] as double).compareTo(b['totalPrice'] as double),
        );
        break;
      case 'price_desc':
        sorted.sort(
          (a, b) =>
              (b['totalPrice'] as double).compareTo(a['totalPrice'] as double),
        );
        break;
    }

    return sorted;
  }

  // Change sort method
  void changeSortBy(String newSort) {
    sortBy.value = newSort;
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = orders.indexWhere((order) => order['orderId'] == orderId);
    if (index != -1) {
      orders[index]['status'] = newStatus;
      orders.refresh(); // Trigger UI update
      
      // Save to Hive
      await ordersBox.put('ordersList', orders.toList());

      Get.snackbar(
        'Status Updated',
        'Status pesanan diubah menjadi $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    final index = orders.indexWhere((order) => order['orderId'] == orderId);
    if (index != -1) {
      orders[index]['status'] = 'Cancelled';
      orders.refresh();
      
      // Save to Hive
      await ordersBox.put('ordersList', orders.toList());

      Get.snackbar(
        'Order Cancelled',
        'Pesanan berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete order from list
  Future<void> deleteOrder(String orderId) async {
    orders.removeWhere((order) => order['orderId'] == orderId);
    
    // Save to Hive
    await ordersBox.put('ordersList', orders.toList());

    Get.snackbar(
      'Deleted',
      'Pesanan berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Refresh orders (pull to refresh)
  Future<void> refreshOrders() async {
    await loadOrders();
  }
}
