// lib/views/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/checkout_controller.dart';
import 'product_list_page.dart';
import 'payment_method_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CHECKOUT PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Checkout page dengan fitur:
/// - Ringkasan pesanan (produk, quantity, total)
/// - Form input (nama, alamat, payment method)
/// - CircularProgressIndicator saat submit
/// - Form validation
/// - Navigate ke OrdersPage setelah sukses
/// - Clear cart setelah order berhasil
/// - Success/error dialog
/// - Error handling
class CheckoutPage extends StatelessWidget {
  CheckoutPage({super.key});

  // Controllers
  final CartController cartController = Get.find<CartController>();
  final CheckoutController checkoutController = Get.find<CheckoutController>();

  // Form key untuk validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────────────────────────────────
  // CHECKOUT LOGIC
  // ─────────────────────────────────────────────────────────────────────────

  /// Handle checkout submit
  Future<void> _handleCheckout() async {
    // Tutup keyboard
    FocusScope.of(Get.context!).unfocus();

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Form Invalid',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Submit checkout
    final success = await checkoutController.submitCheckout();

    if (success) {
      // Show success dialog
      _showSuccessDialog();
    }
  }

  /// Show success dialog dan navigate ke OrdersPage
  void _showSuccessDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                'Order Successful!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Your order has been placed successfully.\nThank you for shopping with us!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // View Orders button - Navigate to Pesanan Saya tab
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.offAll(() => const ProductListPage(initialIndex: 2)); // Navigate to Pesanan Saya tab (index 2)
              },
              child: const Text(
                'View Orders',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            // Continue Shopping button - Back to home
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.offAll(() => const ProductListPage(initialIndex: 0)); // Back to home tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2380c4),
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Show loading saat submit
        if (checkoutController.isLoading.value) {
          return _buildLoadingState();
        }

        // Normal checkout form
        return _buildCheckoutForm();
      }),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // UI COMPONENTS
  // ═════════════════════════════════════════════════════════════════════════

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Checkout',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF2380c4),
      foregroundColor: Colors.white,
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF2380c4), strokeWidth: 3),
          SizedBox(height: 24),
          Text(
            'Processing your order...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please wait',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Checkout form
  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Section
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            _buildOrderSummary(),
            const SizedBox(height: 24),

            // Customer Information Section
            _buildSectionTitle('Customer Information'),
            const SizedBox(height: 12),
            _buildCustomerForm(),
            const SizedBox(height: 24),

            // Payment Method Section
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentMethod(),
            const SizedBox(height: 32),

            // Total Price
            _buildTotalPrice(),
            const SizedBox(height: 24),

            // Place Order Button
            _buildPlaceOrderButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2380c4),
      ),
    );
  }

  /// Order summary (list produk)
  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(() {
        final items = checkoutController.cartItems;

        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'No items in cart',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final product = items[index];

            // Calculate subtotal
            final priceStr = product.price.replaceAll(RegExp(r'[^0-9]'), '');
            final price = double.tryParse(priceStr) ?? 0.0;
            final subtotal = price * product.quantity;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${product.price} × ${product.quantity}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              trailing: Text(
                'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF2380c4),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// Customer form (nama & alamat)
  Widget _buildCustomerForm() {
    return Column(
      children: [
        // Name field
        TextFormField(
          validator: checkoutController.validateName,
          onChanged: checkoutController.updateName,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // Address field
        TextFormField(
          validator: checkoutController.validateAddress,
          onChanged: checkoutController.updateAddress,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Delivery Address *',
            hintText: 'Enter your complete address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Payment method selector - Navigates to PaymentMethodPage
  Widget _buildPaymentMethod() {
    return Obx(() {
      // Get icon for current payment method
      IconData getPaymentIcon(String method) {
        switch (method) {
          case 'gopay':
            return Icons.account_balance_wallet;
          case 'ovo':
            return Icons.account_balance_wallet;
          case 'dana':
            return Icons.account_balance_wallet;
          case 'bank_transfer':
            return Icons.account_balance;
          case 'cod':
            return Icons.money;
          case 'credit_card':
            return Icons.credit_card;
          case 'Cash':
            return Icons.money;
          case 'Credit Card':
            return Icons.credit_card;
          case 'Debit Card':
            return Icons.credit_card;
          case 'E-Wallet':
            return Icons.account_balance_wallet;
          case 'Bank Transfer':
            return Icons.account_balance;
          default:
            return Icons.payment;
        }
      }

      // Get display name
      String getDisplayName(String method) {
        switch (method) {
          case 'gopay':
            return 'GoPay';
          case 'ovo':
            return 'OVO';
          case 'dana':
            return 'DANA';
          case 'bank_transfer':
            return 'Transfer Bank';
          case 'cod':
            return 'Cash on Delivery (COD)';
          case 'credit_card':
            return 'Kartu Kredit/Debit';
          default:
            return method;
        }
      }

      return InkWell(
        onTap: () async {
          // Navigate to PaymentMethodPage
          final result = await Get.to(
            () => PaymentMethodPage(totalAmount: checkoutController.totalPrice),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );

          if (result != null) {
            checkoutController.updatePaymentMethod(result);
            Get.snackbar(
              'Metode Pembayaran Dipilih',
              'Anda memilih: ${getDisplayName(result)}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF2380c4),
              colorText: Colors.white,
              icon: Icon(getPaymentIcon(result), color: Colors.white),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                getPaymentIcon(checkoutController.paymentMethod.value),
                size: 24,
                color: const Color(0xFF2380c4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  getDisplayName(checkoutController.paymentMethod.value),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      );
    });
  }

  /// Total price display
  Widget _buildTotalPrice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2380c4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2380c4).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Amount:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Obx(() {
            return Text(
              checkoutController.totalPrice == 0
                  ? 'Rp 0'
                  : 'Rp ${checkoutController.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2380c4),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Place order button
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2380c4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Place Order',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
