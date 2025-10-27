// lib/views/cart_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../models/product.dart';
import 'checkout_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CART PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Shopping cart page dengan fitur:
/// - List produk di cart (reactive dengan Obx)
/// - Tambah/kurangi quantity
/// - Hapus produk
/// - Total harga otomatis (reactive)
/// - Navigate ke Checkout
/// - Loading state untuk validasi stock
/// - Empty state untuk cart kosong
/// - Animasi smooth saat add/remove items
class CartPage extends StatelessWidget {
  CartPage({super.key});

  // GetX CartController
  final CartController cartController = Get.find<CartController>();

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Navigate ke CheckoutPage
  Future<void> _navigateToCheckout() async {
    // Validate stock dulu (simulasi async operation)
    cartController.isLoading.value = true;

    final isStockAvailable = await cartController.validateStock();

    if (isStockAvailable) {
      // Stock available, navigate to checkout
      Get.to(
        () => CheckoutPage(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      // Stock not available
      Get.snackbar(
        'Stock Unavailable',
        'Some items are out of stock',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Reactive - rebuild saat cart berubah

        // Show loading indicator saat validasi stock
        if (cartController.isLoading.value) {
          return _buildLoadingState();
        }

        // Show empty state jika cart kosong
        if (cartController.cart.isEmpty) {
          return _buildEmptyState();
        }

        // Show cart items
        return Column(
          children: [
            // Cart items list
            Expanded(child: _buildCartList()),

            // Bottom section: Total & Checkout button
            _buildBottomSection(),
          ],
        );
      }),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═════════════════════════════════════════════════════════════════════════

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Obx(() {
        // Reactive - update total items di title
        return Text(
          'Cart (${cartController.totalItems} items)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        );
      }),
      backgroundColor: const Color(0xFF2380c4),
      foregroundColor: Colors.white,
      actions: [
        // Clear cart button
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: cartController.clearCart,
          tooltip: 'Clear Cart',
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
          CircularProgressIndicator(color: Color(0xFF2380c4)),
          SizedBox(height: 16),
          Text(
            'Validating stock...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Empty state with animation
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty cart icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 120,
                    color: Colors.grey.shade300,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title with fade animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Description
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Add some products to your cart\nand they will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Back button with slide animation
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
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Continue Shopping'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2380c4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Cart items list
  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cartController.cart.length,
      itemBuilder: (context, index) {
        final product = cartController.cart[index];

        // Animated list item dengan Dismissible
        return Dismissible(
          key: Key(product.id),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(),
          confirmDismiss: (direction) async {
            // Show confirmation dialog
            return await Get.dialog<bool>(
                  AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Remove Item'),
                      ],
                    ),
                    content: Text(
                      'Remove "${product.name}" from cart?',
                      style: const TextStyle(fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                ) ??
                false; // Default to false if dialog is dismissed
          },
          onDismissed: (direction) {
            cartController.removeFromCart(product);
          },
          child: _buildCartItem(product),
        );
      },
    );
  }

  /// Dismiss background (swipe to delete)
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }

  /// Single cart item
  Widget _buildCartItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product image
            _buildProductImage(product),
            const SizedBox(width: 12),

            // Product info
            Expanded(child: _buildProductInfo(product)),

            // Quantity controls
            _buildQuantityControls(product),
          ],
        ),
      ),
    );
  }

  /// Product image
  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        product.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Product info (name, price, subtotal)
  Widget _buildProductInfo(Product product) {
    // Calculate subtotal
    final priceStr = product.price.replaceAll(RegExp(r'[^0-9]'), '');
    final price = double.tryParse(priceStr) ?? 0.0;
    final subtotal = price * product.quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Price per item
        Text(
          '${product.price} / item',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),

        // Subtotal
        Text(
          'Subtotal: Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2380c4),
          ),
        ),
      ],
    );
  }

  /// Quantity controls (-, quantity, +)
  Widget _buildQuantityControls(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          IconButton(
            icon: Icon(
              product.quantity > 1 ? Icons.remove : Icons.delete_outline,
              size: 20,
            ),
            onPressed: () => cartController.decreaseQuantity(product),
            color: product.quantity > 1 ? Colors.black87 : Colors.red,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),

          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${product.quantity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // Increase button
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => cartController.increaseQuantity(product),
            color: Colors.black87,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Bottom section (total price & checkout button)
  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total price (reactive)
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    cartController.formattedTotalPrice,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2380c4),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _navigateToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2380c4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
