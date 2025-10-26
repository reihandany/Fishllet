// lib/product_list_page.dart

import 'package:flutter/material.dart';
import 'product.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';
import 'orders_page.dart';

class ProductListPage extends StatelessWidget {
  final String username;
  final List<Product> cart;
  final List<List<Product>> orders;
  final Function(Product) addToCart;
  final VoidCallback logout;
  final VoidCallback checkout;
  final VoidCallback clearCart;

  const ProductListPage({
    super.key,
    required this.username,
    required this.cart,
    required this.orders,
    required this.addToCart,
    required this.logout,
    required this.checkout,
    required this.clearCart,
  });

  void openCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cart: cart,
          checkout: checkout,
          clearCart: clearCart,
        ),
      ),
    );
  }

  void openDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          onAddToCart: () => addToCart(product),
        ),
      ),
    );
  }

  void openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersPage(orders: orders),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishllet'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF2380c4),
            padding: const EdgeInsets.all(16),
            child: Text('Selamat datang, $username! 👋', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, idx) {
                final product = products[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(product.name, style: const TextStyle(color: Color(0xFF2380c4), fontWeight: FontWeight.bold)),
                    subtitle: Text(product.price),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF2380c4)),
                      onPressed: () {
                        addToCart(product);
                        // Tampilkan Snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ditambahkan ke keranjang!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    onTap: () => openDetail(context, product),
                  ),
                );
              },
            ),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: Text('Keranjang (${cart.length})'), // Tampilkan jumlah item
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2380c4),
                ),
                onPressed: () => openCart(context),
              ),
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
                onPressed: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}