// lib/views/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/theme_controller.dart';

// Models
import '../models/product.dart';

import 'cart_page.dart';
import 'product_detail_page.dart';
import 'add_product_page.dart';
import 'orders_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT LIST PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Main product listing page dengan GetX navigation
/// Navigation flow:
/// - ProductListPage → ProductDetailPage (Get.to dengan fade transition)
/// - ProductListPage → CartPage (Get.to dengan rightToLeft transition)
/// - ProductListPage → OrdersPage (Get.to dengan slide transition)
/// - ProductListPage → AnalysisPage (Get.to)
class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final AuthController auth = Get.find();
  final ProductController product = Get.find();
  final CartController cart = Get.find();

  // Scroll controller for FAB
  final ScrollController _scrollController = ScrollController();
  final RxBool _showFAB = false.obs;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        _showFAB.value = true;
      } else {
        _showFAB.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to top method
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION METHODS - GETX STYLE
  // ─────────────────────────────────────────────────────────────────────────

  /// Navigate to Cart with rightToLeft transition
  void openCart() {
    Get.to(
      () => CartPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Navigate to Product Detail with fade transition + pass data
  void openDetail(Product productData) {
    Get.to(
      () => ProductDetailPage(product: productData),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// Navigate to Orders with downToUp transition
  void openOrders() {
    Get.to(
      () => OrdersPage(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 350),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DIALOG METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Show logout confirmation dialog
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.orange),
            SizedBox(width: 12),
            Text('Logout Confirmation'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?\nYour cart will be cleared.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              auth.logout(); // Perform logout
              Get.snackbar(
                'Logged Out',
                'You have been logged out successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                icon: const Icon(Icons.logout, color: Colors.white),
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishllet'),
        backgroundColor: const Color(0xFF2380c4),
        actions: [
        Obx(() => IconButton(
          icon: Icon(
            themeController.isDark.value ? Icons.light_mode : Icons.dark_mode,
          ),
          tooltip: themeController.isDark.value ? 'Light Mode' : 'Dark Mode',
          onPressed: () => themeController.toggleTheme(),
        )),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Product',
          onPressed: () => Get.to(() => const AddProductPage()),
        ),
        Builder(builder: (_) {
          return Obx(() {
            final itemCount = cart.totalItems;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Shopping Cart',
                  onPressed: openCart,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        itemCount > 99 ? '99+' : '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          });
          }),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF2380c4),
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Text(
                'Selamat datang, ${auth.username.value}! 👋',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Loading state dengan styling
              if (product.isLoading.value && product.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: Color(0xFF2380c4),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Loading products...',
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

              // Empty state
              if (product.products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 100,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                        'No products available.\nCheck your internet connection.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                      ],
                    ),
                  ),
                );
              }

              // Products list with scroll controller
              return ListView.builder(
                controller: _scrollController,
                itemCount: product.products.length,
                itemBuilder: (context, idx) {
                  final p = product.products[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: Image.network(
                        p.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: Color(0xFF2380c4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(p.price),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Color(0xFF2380c4),
                        ),
                        onPressed: () async {
                          await cart.addToCart(p);
                        },
                      ),
                      onTap: () => openDetail(p),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      // Floating Action Button for scroll to top
      floatingActionButton: Obx(
        () => AnimatedScale(
          scale: _showFAB.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: FloatingActionButton(
            onPressed: _scrollToTop,
            backgroundColor: const Color(0xFF2380c4),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2380c4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart),
                  label: Text('Keranjang (${cart.cart.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2380c4),
                  ),
                  onPressed: openCart,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Riwayat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2380c4),
                ),
                onPressed: openOrders,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2380c4),
                ),
                onPressed: showLogoutConfirmation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
