// lib/views/payment_method_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PAYMENT METHOD PAGE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Halaman untuk memilih metode pembayaran
/// Block untuk guest user
class PaymentMethodPage extends StatefulWidget {
  final double totalAmount;

  const PaymentMethodPage({super.key, required this.totalAmount});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String? selectedMethod;
  final AuthController authController = Get.find<AuthController>();

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'gopay',
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'description': 'Bayar dengan GoPay',
    },
    {
      'id': 'ovo',
      'name': 'OVO',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
      'description': 'Bayar dengan OVO',
    },
    {
      'id': 'dana',
      'name': 'DANA',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF1F70B2),
      'description': 'Bayar dengan DANA',
    },
    {
      'id': 'bank_transfer',
      'name': 'Transfer Bank',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'description': 'Transfer melalui Bank',
    },
    {
      'id': 'cod',
      'name': 'Cash on Delivery (COD)',
      'icon': Icons.money,
      'color': Colors.teal,
      'description': 'Bayar saat barang diterima',
    },
    {
      'id': 'credit_card',
      'name': 'Kartu Kredit/Debit',
      'icon': Icons.credit_card,
      'color': Color(0xFF1F70B2),
      'description': 'Bayar dengan kartu',
    },
  ];

  void _processPayment() {
    if (selectedMethod == null) {
      Get.snackbar(
        'Pilih Metode Pembayaran',
        'Silakan pilih metode pembayaran terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Return selected method to previous page
    Get.back(result: selectedMethod);
  }

  @override
  void initState() {
    super.initState();

    // Check if guest user, show dialog dan redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isGuest.value) {
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.payment, color: Colors.orange),
                SizedBox(width: 12),
                Text('Pembayaran Tidak Tersedia'),
              ],
            ),
            content: const Text(
              'Maaf, Anda harus login terlebih dahulu untuk melakukan pembayaran.\n\nSilakan login atau register untuk melanjutkan.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Back to previous page
                },
                child: const Text('Nanti'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.offAll(() => LoginPage()); // Navigate to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F70B2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Login Sekarang'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Metode Pembayaran'),
        backgroundColor: const Color(0xFF1F70B2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Total Amount Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1F70B2),
                  const Color(0xFF1F70B2).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F70B2).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${widget.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Payment Methods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                final isSelected = selectedMethod == method['id'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF1F70B2)
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedMethod = method['id'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (method['color'] as Color).withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              method['icon'] as IconData,
                              color: method['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  method['description'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Radio indicator
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1F70B2)
                                    : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF1F70B2),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confirm Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F70B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
