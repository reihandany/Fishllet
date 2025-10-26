// lib/cart_page.dart

import 'package:flutter/material.dart';
import 'product.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final VoidCallback checkout;
  final VoidCallback clearCart;

  const CartPage({super.key, required this.cart, required this.checkout, required this.clearCart});

  void openCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cart: cart,
          checkout: checkout,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Keranjang kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, idx) {
                      final product = cart[idx];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(product.price),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2380c4),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => openCheckout(context),
                          child: const Text('Checkout'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: clearCart,
                          child: const Text('Kosongkan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}