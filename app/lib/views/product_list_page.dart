// lib/views/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

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
import 'login_page.dart';
import '../config/app_theme.dart';

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
    // Check if guest user trying to access restricted pages
    if (auth.isGuest.value && index != 0) {
      // Guest trying to access Keranjang, Pesanan, Riwayat, or Akun
      _showLoginRequiredDialog(index);
      return;
    }

    _selectedIndex.value = index;
  }

  /// Show login required dialog for guest users
  void _showLoginRequiredDialog(int attemptedIndex) {
    String featureName = '';
    switch (attemptedIndex) {
      case 1:
        featureName = 'Keranjang';
        break;
      case 2:
        featureName = 'Pesanan Saya';
        break;
      case 3:
        featureName = 'Riwayat';
        break;
      case 4:
        featureName = 'Akun';
        break;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 12),
            Text('Login Diperlukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda harus login terlebih dahulu untuk mengakses $featureName.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan login atau register untuk melanjutkan.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAll(() => LoginPage()); // Navigate to login
            },
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Login Sekarang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
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

  // ═════════════════════════════════════════════════════════════════════════
  // DRAWER MENU
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildDrawer() {
    final ThemeController themeController = Get.find();

    return Builder(
      builder: (context) {
        final isDark = AppColors.isDark(context);
        return Drawer(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryGradient,
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
                            color: AppColors.primary,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        auth.username.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, color: isDark ? AppColors.secondary : AppColors.primary),
            title: Text('Profil Saya', style: TextStyle(color: AppColors.text(context))),
            onTap: () {
              Get.back();
              if (auth.isGuest.value) {
                _showLoginRequiredDialog(4); // 4 = Akun
              } else {
                _selectedIndex.value = 4; // Navigate to Account
              }
            },
          ),
          // View Map menu item removed (no longer used)
          ListTile(
            leading: Obx(
              () => Icon(
                themeController.isDark.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
            title: Obx(
              () => Text(
                themeController.isDark.value ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(color: AppColors.text(context)),
              ),
            ),
            onTap: () {
              themeController.toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: isDark ? AppColors.secondary : AppColors.primary),
            title: Text('Pengaturan', style: TextStyle(color: AppColors.text(context))),
            onTap: () {
              Get.back();
              Get.snackbar(
                'Coming Soon',
                'Settings feature will be available soon',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: isDark ? AppColors.secondary : AppColors.primary),
            title: Text('Bantuan', style: TextStyle(color: AppColors.text(context))),
            onTap: () {
              Get.back();
              Get.snackbar(
                'Bantuan',
                'Hubungi customer service untuk bantuan',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primary,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
          Divider(color: AppColors.divider(context)),
          Obx(
            () => ListTile(
              leading: Icon(
                auth.isGuest.value ? Icons.login : Icons.logout,
                color: auth.isGuest.value
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : Colors.red,
              ),
              title: Text(
                auth.isGuest.value ? 'Login' : 'Logout',
                style: TextStyle(
                  color: auth.isGuest.value
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : Colors.red,
                ),
              ),
              onTap: () {
                Get.back();
                if (auth.isGuest.value) {
                  Get.offAll(() => LoginPage());
                } else {
                  showLogoutConfirmation();
                }
              },
            ),
          ),
        ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppStyles.buildGradientAppBar(
        height: 25,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ClipRect(
            child: Image.asset(
              'assets/images/Fishllet Logo Design-01.png',
              height: 100,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(),

      body: Obx(() {
        // Show different pages based on selected index
        // Guest users can only see Home page (index 0)
        if (_selectedIndex.value == 1 && !auth.isGuest.value) return CartPage();
        if (_selectedIndex.value == 2 && !auth.isGuest.value) return MyOrdersPage();
        if (_selectedIndex.value == 3 && !auth.isGuest.value) return HistoryPage();
        if (_selectedIndex.value == 4 && !auth.isGuest.value) return AccountPage();

        // Default: Home page (for index 0 or if guest tries to access other pages)
        return Column(
          children: [
            // Welcome Banner with Gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.waving_hand,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang!',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            auth.username.value,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar with Modern Design
            Container(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => product.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    suffixIcon: Obx(
                      () => product.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.grey,
                              ),
                              onPressed: () => product.setSearchQuery(''),
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Sort & Filter Row with Modern Design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.grid_view_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${product.filteredProducts.length} Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.sort_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Obx(
                            () => Text(
                              product.selectedSort.value,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (value) => product.setSort(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Nama A-Z',
                        child: Text('Nama A-Z'),
                      ),
                      const PopupMenuItem(
                        value: 'Nama Z-A',
                        child: Text('Nama Z-A'),
                      ),
                      const PopupMenuItem(
                        value: 'Harga Terendah',
                        child: Text('Harga Terendah'),
                      ),
                      const PopupMenuItem(
                        value: 'Harga Tertinggi',
                        child: Text('Harga Tertinggi'),
                      ),
                      const PopupMenuItem(
                        value: 'Rating Tertinggi',
                        child: Text('Rating Tertinggi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                // Loading state dengan shimmer effect modern
                if (product.isLoading.value && product.products.isEmpty) {
                  return ListView.builder(
                    itemCount: 5,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          height: 120,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 14,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 14,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Empty state dengan design modern
                if (product.filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B8FCC).withOpacity(0.1),
                                  const Color(0xFF5AA5D6).withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              product.searchQuery.value.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.inventory_2_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            product.searchQuery.value.isNotEmpty
                                ? 'Produk Tidak Ditemukan'
                                : 'Belum Ada Produk',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.searchQuery.value.isNotEmpty
                                ? 'Coba kata kunci yang berbeda'
                                : 'Periksa koneksi internet Anda',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Products list dengan modern card design
                return RefreshIndicator(
                  onRefresh: () => product.refreshProducts(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: product.filteredProducts.length,
                    itemBuilder: (context, idx) {
                      final p = product.filteredProducts[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => openDetail(p),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image dengan border gradient
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        p.imageUrl,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 96,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.shade200,
                                                  Colors.grey.shade300,
                                                ],
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.set_meal_rounded,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF3B8FCC),
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        // Category chip dengan gradient
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF3B8FCC).withOpacity(0.15),
                                                const Color(0xFF5AA5D6).withOpacity(0.15),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.category_rounded,
                                                size: 12,
                                                color: Color(0xFF3B8FCC),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                p.category,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: const Color(0xFF3B8FCC),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Rating dengan star icon
                                        Row(
                                          children: [
                                            ...List.generate(
                                              5,
                                              (index) => Icon(
                                                index < p.rating.floor()
                                                    ? Icons.star_rounded
                                                    : Icons.star_outline_rounded,
                                                size: 16,
                                                color: Colors.amber.shade600,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              p.rating.toStringAsFixed(1),
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Price dengan gradient text
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [AppColors.primary, AppColors.secondary],
                                          ).createShader(bounds),
                                          child: Text(
                                            p.price,
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Add to cart button dengan gradient
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          if (auth.isGuest.value) {
                                            _showLoginRequiredDialog(1);
                                            return;
                                          }
                                          await cart.addToCart(p);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.add_shopping_cart_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),

      // Floating Action Button dengan gradient
      floatingActionButton: Obx(
        () => AnimatedScale(
          scale: _showFAB.value ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex.value,
            onTap: _onBottomNavTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Keranjang',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_rounded),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Pesanan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                activeIcon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person),
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
