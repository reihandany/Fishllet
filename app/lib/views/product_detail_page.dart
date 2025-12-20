// lib/views/product_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT DETAIL PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Detail page dengan GetX navigation & loading states
/// Features:
/// - Add to cart → Get.back() (kembali ke ProductListPage)
/// - Back button → Get.back() (automatic)
/// - Image loading indicator (CircularProgressIndicator)
/// - Image error handling
class ProductDetailPage extends StatelessWidget {
  ProductDetailPage({super.key, required this.product});

  // Controller
  final CartController cartController = Get.find<CartController>();

  // Data yang di-pass dari previous page
  final Product product;

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Add to cart and navigate back with result
  Future<void> addToCartAndGoBack() async {
    await cartController.addToCart(product);
    // Navigate back dengan result (untuk feedback)
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFF1F70B2),
        foregroundColor: Colors.white,
        // GetX automatic back button (no need to override)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Loading indicator saat image loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Image loaded
                    }
                    return Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFF1F70B2),
                          strokeWidth: 3,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  // Error handling jika image gagal load
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F70B2),
              ),
            ),
            const SizedBox(height: 12),

            // Product Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F70B2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                product.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F70B2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  product.description ?? 'No description available.',
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add to Cart Button with loading state
            Obx(() {
              final isLoading = cartController.isLoading.value;

              return SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart),
                  label: Text(isLoading ? 'Adding...' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F70B2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: isLoading ? null : addToCartAndGoBack,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
