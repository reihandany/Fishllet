// lib/views/my_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/orders_controller.dart';
import 'delivery_tracking_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MY ORDERS PAGE (PENDING/CHECKOUT ORDERS)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman untuk pesanan yang sudah checkout/pending
class MyOrdersPage extends StatelessWidget {
  MyOrdersPage({super.key});

  final OrdersController ordersController = Get.find<OrdersController>();

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      default:
        return Icons.info;
    }
  }

  void _showOrderDetail(Map<String, dynamic> order) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['orderId']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2380c4),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.calendar_today,
                'Date',
                _formatDate(order['orderDate']),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.info_outline,
                'Status',
                order['status'],
                valueColor: _getStatusColor(order['status']),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.person_outline,
                'Customer',
                order['customerName'],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.location_on_outlined,
                'Address',
                order['deliveryAddress'],
              ),
              const SizedBox(height: 24),
              const Text(
                'Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...((order['items'] as List).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item['name']} × ${item['quantity']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        _formatPrice(item['price'] * item['quantity']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatPrice(order['totalPrice']),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2380c4),
                    ),
                  ),
                ],
              ),
              if (order['status'].toLowerCase() == 'pending') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Close bottom sheet
                      // Navigate to live tracking page
                      // Use delivery address coordinates (simulate random location)
                      final random = DateTime.now().millisecond / 1000;
                      final deliveryLatLng = LatLng(
                        -6.2088 + (random * 0.05), // Jakarta area
                        106.8456 + (random * 0.05),
                      );
                      
                      Get.to(
                        () => DeliveryTrackingPage(
                          orderId: order['orderId'],
                          customerLocation: deliveryLatLng,
                          customerAddress: order['deliveryAddress'],
                        ),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Track Live Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2380c4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (order['status'].toLowerCase() == 'pending') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back(); // Close bottom sheet
                      // Show confirmation dialog
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Row(
                            children: const [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 12),
                              Text('Cancel Order'),
                            ],
                          ),
                          content: Text(
                            'Are you sure you want to cancel order #${order['orderId']}?',
                            style: const TextStyle(fontSize: 15),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back(); // Close dialog
                                ordersController.cancelOrder(order['orderId']);
                                Get.snackbar(
                                  'Order Cancelled',
                                  'Order #${order['orderId']} has been cancelled',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  icon: const Icon(Icons.cancel, color: Colors.white),
                                  duration: const Duration(seconds: 2),
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        backgroundColor: const Color(0xFF2380c4),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (ordersController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: Color(0xFF2380c4)),
                SizedBox(height: 24),
                Text('Loading orders...'),
              ],
            ),
          );
        }

        // Filter hanya pending, processing, shipped
        final pendingOrders = ordersController.orders.where((order) {
          final status = order['status'].toString().toLowerCase();
          return status == 'pending' || 
                 status == 'processing' || 
                 status == 'shipped';
        }).toList();

        if (pendingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tidak ada pesanan aktif',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pesanan Anda yang sedang diproses\nakan muncul di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingOrders.length,
          itemBuilder: (context, index) {
            final order = pendingOrders[index];
            final status = order['status'] as String;
            final items = order['items'] as List;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _showOrderDetail(order),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['orderId']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2380c4),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(status),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: 14,
                                  color: _getStatusColor(status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(order['orderDate']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${items.length} item${items.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatPrice(order['totalPrice']),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2380c4),
                            ),
                          ),
                        ],
                      ),
                      // Add track location button for pending orders
                      if (status.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Navigate to live tracking page
                              final random = DateTime.now().millisecond / 1000;
                              final deliveryLatLng = LatLng(
                                -6.2088 + (random * 0.05),
                                106.8456 + (random * 0.05),
                              );
                              
                              Get.to(
                                () => DeliveryTrackingPage(
                                  orderId: order['orderId'],
                                  customerLocation: deliveryLatLng,
                                  customerAddress: order['deliveryAddress'],
                                ),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 300),
                              );
                            },
                            icon: const Icon(Icons.location_on, size: 18),
                            label: const Text('Track Live Location'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2380c4),
                              side: const BorderSide(
                                color: Color(0xFF2380c4),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
