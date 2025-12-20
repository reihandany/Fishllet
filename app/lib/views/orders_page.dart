// lib/views/orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/orders_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ORDERS PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman riwayat pesanan dengan fitur:
/// - List semua pesanan yang pernah dibuat
/// - CircularProgressIndicator saat loading
/// - Detail order (tanggal, status, total harga, items)
/// - Navigate ke detail order (bottom sheet)
/// - Filter/sort (terbaru, terlama, harga tertinggi, terendah)
/// - Empty state yang menarik
/// - Pull-to-refresh
/// - Status badges dengan warna
class OrdersPage extends StatelessWidget {
  OrdersPage({super.key});

  // Controller
  final OrdersController ordersController = Get.find<OrdersController>();

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Format date (e.g., "27 Oct 2025, 14:30")
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  /// Format price with separator
  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Color(0xFF1F70B2);
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Show order detail in bottom sheet
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['orderId']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F70B2),
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

              // Order Info
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
              const SizedBox(height: 12),
              _buildDetailRow(Icons.payment, 'Payment', order['paymentMethod']),

              const SizedBox(height: 24),
              const Text(
                'Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Items list
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

              // Total
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
                      color: Color(0xFF1F70B2),
                    ),
                  ),
                ],
              ),

              // Action buttons (jika status masih pending)
              if (order['status'].toLowerCase() == 'pending') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          ordersController.cancelOrder(order['orderId']);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          ordersController.updateOrderStatus(
                            order['orderId'],
                            'Processing',
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Process'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F70B2),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Build detail row for bottom sheet
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

  /// Show sort options with enhanced bottom sheet
  void _showSortOptions() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.sort, color: Color(0xFF1F70B2), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Sort Orders By',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F70B2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),

            // Sort options
            _buildSortOption('date_desc', 'Newest First', Icons.arrow_downward),
            _buildSortOption('date_asc', 'Oldest First', Icons.arrow_upward),
            _buildSortOption('price_desc', 'Highest Price', Icons.trending_up),
            _buildSortOption('price_asc', 'Lowest Price', Icons.trending_down),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: false,
    );
  }

  /// Build sort option item with enhanced styling
  Widget _buildSortOption(String value, String label, IconData icon) {
    return Obx(() {
      final isSelected = ordersController.sortBy.value == value;
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1F70B2).withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF1F70B2) : Colors.grey.shade700,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF1F70B2) : Colors.black,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF1F70B2))
            : null,
        onTap: () {
          ordersController.changeSortBy(value);
          Get.back();
          Get.snackbar(
            'Sort Applied',
            'Orders sorted by: $label',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1F70B2),
            colorText: Colors.white,
            icon: Icon(icon, color: Colors.white),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        },
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Loading state
        if (ordersController.isLoading.value) {
          return _buildLoadingState();
        }

        // Empty state
        if (ordersController.orders.isEmpty) {
          return _buildEmptyState();
        }

        // Orders list
        return _buildOrdersList();
      }),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═════════════════════════════════════════════════════════════════════════

  /// AppBar with sort button
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order History',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          Obx(() {
            final count = ordersController.totalOrders;
            return Text(
              '$count order${count != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            );
          }),
        ],
      ),
      backgroundColor: const Color(0xFF1F70B2),
      foregroundColor: Colors.white,
      actions: [
        // Sort button
        IconButton(
          onPressed: _showSortOptions,
          icon: const Icon(Icons.sort),
          tooltip: 'Sort Orders',
        ),
      ],
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF1F70B2), strokeWidth: 3),
          SizedBox(height: 24),
          Text(
            'Loading orders...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state with animations
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with scale animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 120,
                  color: Colors.grey.shade300,
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Title with fade
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text(
                  'No Orders Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Description with fade
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'You haven\'t placed any orders.\nStart shopping to see your order history here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Button with slide animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Back to products
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Start Shopping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F70B2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Orders list with pull-to-refresh
  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: () async {
        await ordersController.loadOrders();
      },
      color: const Color(0xFF1F70B2),
      child: Obx(() {
        final orders = ordersController.sortedOrders;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(order);
          },
        );
      }),
    );
  }

  /// Order card
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final items = order['items'] as List;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order ID & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['orderId']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F70B2),
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

              // Date
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _formatPrice(order['totalPrice']),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F70B2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // View detail button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showOrderDetail(order),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1F70B2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
