// lib/views/product_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/product_controller.dart';

// Models
import '../models/product.dart';

// Views (Halaman Lain)
import 'analysis_page.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';
import 'orders_page.dart';

class ProductListPage extends StatelessWidget {
  ProductListPage({super.key});

  final AuthController auth = Get.find();
  final ProductController product = Get.find();
  final CartController cart = Get.find();

  void openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(), // <--- Pemanggilan class
      ),
    );
  }

  void openDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  void openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrdersPage()),
    );
  }

  void openAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AnalysisPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishllet'),
        backgroundColor: const Color(0xFF2380c4),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Halaman Analisis Modul 3',
            onPressed: () => openAnalysis(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF2380c4),
            padding: const EdgeInsets.all(16),
            child: Obx(() => Text('Selamat datang, ${auth.username.value}! 👋',
                style: const TextStyle(color: Colors.white, fontSize: 18))),
          ),
          Expanded(
            child: Obx(() {
              if (product.isLoading.value && product.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (product.products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Data produk kosong.\nSilakan jalankan eksperimen di "Halaman Analisis" (ikon 📊 di kanan atas).',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: product.products.length,
                itemBuilder: (context, idx) {
                  final p = product.products[idx];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        p.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(p.name,
                          style: const TextStyle(
                              color: Color(0xFF2380c4),
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(p.price),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: Color(0xFF2380c4)),
                        onPressed: () {
                          cart.addToCart(p);
                        },
                      ),
                      onTap: () => openDetail(context, p),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF2380c4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() => ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: Text('Keranjang (${cart.cart.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2380c4),
                    ),
                    onPressed: () => openCart(context),
                  )),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Riwayat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2380c4),
                ),
                onPressed: () => openOrders(context),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2380c4),
                ),
                onPressed: auth.logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}