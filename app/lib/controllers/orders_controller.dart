// lib/controllers/orders_controller.dart
import 'package:get/get.dart';

class OrdersController extends GetxController {
  // List of all orders
  var orders = <Map<String, dynamic>>[].obs;

  // Loading state
  var isLoading = false.obs;

  // Filter/sort options
  var sortBy = 'date_desc'.obs; // date_desc, date_asc, price_desc, price_asc

  @override
  void onInit() {
    super.onInit();
    // Load orders from local storage or API (simulasi)
    loadOrders();
  }

  // Load orders (simulasi - bisa diganti dengan API call)
  Future<void> loadOrders() async {
    try {
      isLoading.value = true;

      // Simulasi loading dari server (1 detik)
      await Future.delayed(const Duration(seconds: 1));

      // Data akan diisi dari checkout
      // orders sudah terisi dari addOrder()

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
  void addOrder(Map<String, dynamic> order) {
    orders.insert(0, order); // Tambah di paling atas (order terbaru)
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
  void updateOrderStatus(String orderId, String newStatus) {
    final index = orders.indexWhere((order) => order['orderId'] == orderId);
    if (index != -1) {
      orders[index]['status'] = newStatus;
      orders.refresh(); // Trigger UI update

      Get.snackbar(
        'Status Updated',
        'Status pesanan diubah menjadi $newStatus',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Cancel order
  void cancelOrder(String orderId) {
    final index = orders.indexWhere((order) => order['orderId'] == orderId);
    if (index != -1) {
      orders[index]['status'] = 'Cancelled';
      orders.refresh();

      Get.snackbar(
        'Order Cancelled',
        'Pesanan berhasil dibatalkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete order from list
  void deleteOrder(String orderId) {
    orders.removeWhere((order) => order['orderId'] == orderId);

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
