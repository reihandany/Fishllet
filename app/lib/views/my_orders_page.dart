// lib/views/my_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';
import '../controllers/auth_controller.dart';
import '../config/app_theme.dart';
import 'login_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MY ORDERS PAGE (PENDING/CHECKOUT ORDERS)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman untuk pesanan yang sudah checkout/pending
class MyOrdersPage extends StatelessWidget {
  MyOrdersPage({super.key});

  final OrdersController ordersController = Get.find<OrdersController>();
  final AuthController authController = Get.find<AuthController>();

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
        return Color(0xFF1F70B2);
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
      Builder(
        builder: (context) {
          final isDark = AppColors.isDark(context);
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(Icons.close, color: AppColors.text(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.divider(context)),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Date',
                    _formatDate(order['orderDate']),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.info_outline,
                    'Status',
                    order['status'],
                    valueColor: _getStatusColor(order['status']),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.person_outline,
                    'Customer',
                    order['customerName'],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.location_on_outlined,
                    'Address',
                    order['deliveryAddress'],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
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
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.text(context),
                              ),
                            ),
                          ),
                          Text(
                            _formatPrice(item['price'] * item['quantity']),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.divider(context)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text(context),
                        ),
                      ),
                      Text(
                        _formatPrice(order['totalPrice']),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
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
                                    ordersController.cancelOrder(
                                      order['orderId'],
                                    );
                                    Get.snackbar(
                                      'Order Cancelled',
                                      'Order #${order['orderId']} has been cancelled',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.white,
                                      ),
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
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final isDark = AppColors.isDark(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey.shade600,
                ),
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
    final isDark = AppColors.isDark(context);
    return Scaffold(
      appBar: AppStyles.buildGradientAppBar(
        context: context,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        // Check if guest user
        if (authController.isGuest.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Pesanan Tidak Ada',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Harap Login atau Register Akun',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.offAll(() => LoginPage());
                      },
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text(
                        'Login / Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F70B2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Anda masuk sebagai Guest. Login untuk melihat pesanan Anda.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (ordersController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'Loading orders...',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
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
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tidak ada pesanan aktif',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pesanan Anda yang sedang diproses\nakan muncul di sini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
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
              elevation: 4,
              color: AppColors.card(context),
              shadowColor: AppColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                              color: AppColors.primary,
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
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(order['orderDate']),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey.shade700,
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
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${items.length} item${items.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: AppColors.divider(context)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                            ),
                          ),
                          Text(
                            _formatPrice(order['totalPrice']),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
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
