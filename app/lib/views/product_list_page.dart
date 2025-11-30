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
import 'my_orders_page.dart';
import 'history_page.dart';
import 'account_page.dart';
import 'map_page.dart';

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
  final int initialIndex;
  
  const ProductListPage({super.key, this.initialIndex = 0});

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
  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    // Set initial selected index dari parameter
    _selectedIndex.value = widget.initialIndex;
    
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

  /// Navigate to bottom nav items
  void _onBottomNavTap(int index) {
    _selectedIndex.value = index;
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

  // ═════════════════════════════════════════════════════════════════════════
  // DRAWER MENU
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildDrawer() {
    final ThemeController themeController = Get.find();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2380c4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Obx(() {
                    final username = auth.username.value;
                    final initial = username.isNotEmpty 
                        ? username[0].toUpperCase() 
                        : 'U';
                    return Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2380c4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      auth.username.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF2380c4)),
            title: const Text('Profil Saya'),
            onTap: () {
              Get.back();
              _selectedIndex.value = 4; // Navigate to Account
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Color(0xFF2380c4)),
            title: const Text('View Map'),
            subtitle: const Text('Lihat lokasi saya di peta'),
            onTap: () {
              Get.back();
              Get.to(
                () => MapPage(),
                transition: Transition.rightToLeft,
              );
            },
          ),
          ListTile(
            leading: Obx(() => Icon(
                  themeController.isDark.value ? Icons.light_mode : Icons.dark_mode,
                  color: const Color(0xFF2380c4),
                )),
            title: Obx(() => Text(
                  themeController.isDark.value ? 'Light Mode' : 'Dark Mode',
                )),
            onTap: () {
              themeController.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF2380c4)),
            title: const Text('Pengaturan'),
            onTap: () {
              Get.back();
              Get.snackbar(
                'Coming Soon',
                'Settings feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF2380c4),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF2380c4)),
            title: const Text('Bantuan'),
            onTap: () {
              Get.back();
              Get.snackbar(
                'Bantuan',
                'Hubungi customer service untuk bantuan',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF2380c4),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Get.back();
              showLogoutConfirmation();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishllet'),
        backgroundColor: const Color(0xFF2380c4),
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      
      body: Obx(() {
        // Show different pages based on selected index
        if (_selectedIndex.value == 1) return CartPage();
        if (_selectedIndex.value == 2) return MyOrdersPage();
        if (_selectedIndex.value == 3) return HistoryPage();
        if (_selectedIndex.value == 4) return AccountPage();

        // Default: Home page
        return Column(
        children: [
          // Welcome Banner
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
          
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => product.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2380c4)),
                suffixIcon: Obx(() => product.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => product.setSearchQuery(''),
                    )
                  : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2380c4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2380c4), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Category Chips
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.categories.length,
              itemBuilder: (context, index) {
                final category = product.categories[index];
                final isSelected = product.selectedCategory.value == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => product.setCategory(category),
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF2380c4),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            )),
          ),
          
          // Sort & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  '${product.filteredProducts.length} Produk',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2380c4),
                  ),
                )),
                PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2380c4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort, size: 18, color: Color(0xFF2380c4)),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          product.selectedSort.value,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2380c4)),
                        )),
                      ],
                    ),
                  ),
                  onSelected: (value) => product.setSort(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Nama A-Z', child: Text('Nama A-Z')),
                    const PopupMenuItem(value: 'Nama Z-A', child: Text('Nama Z-A')),
                    const PopupMenuItem(value: 'Harga Terendah', child: Text('Harga Terendah')),
                    const PopupMenuItem(value: 'Harga Tertinggi', child: Text('Harga Tertinggi')),
                    const PopupMenuItem(value: 'Rating Tertinggi', child: Text('Rating Tertinggi')),
                  ],
                ),
              ],
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
              if (product.filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 100,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          product.searchQuery.value.isNotEmpty 
                            ? 'Produk tidak ditemukan' 
                            : 'No products available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.searchQuery.value.isNotEmpty
                            ? 'Coba kata kunci lain'
                            : 'Check your internet connection.',
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
                itemCount: product.filteredProducts.length,
                itemBuilder: (context, idx) {
                  final p = product.filteredProducts[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => openDetail(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2380c4),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Category chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2380c4).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF2380c4),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Rating
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        p.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.price,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2380c4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add to cart button
                            IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Color(0xFF2380c4),
                              ),
                              onPressed: () async {
                                await cart.addToCart(p);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      );
      }),
      
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
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: _selectedIndex.value,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2380c4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Pesanan Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      )),
    );
  }
}
