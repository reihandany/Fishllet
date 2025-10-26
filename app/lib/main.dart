// lib/main.dart

import 'package:flutter/material.dart';
import 'product.dart'; // Import Product model dan list
import 'login_page.dart'; // Import LoginPage
import 'product_list_page.dart'; // Import ProductListPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;
  String username = '';
  List<Product> cart = [];
  List<List<Product>> orders = [];

  void login(String user) {
    setState(() {
      loggedIn = true;
      username = user;
    });
  }

  void logout() {
    setState(() {
      loggedIn = false;
      username = '';
      cart.clear();
      orders.clear(); // Opsional: Hapus riwayat pesanan saat logout
    });
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  void checkout() {
    setState(() {
      orders.add(List<Product>.from(cart)); // Salin keranjang ke orders
      cart.clear(); // Kosongkan keranjang
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishllet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2380c4)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white, // Agar ikon dan teks di AppBar berwarna putih
        ),
      ),
      home: loggedIn
          ? ProductListPage(
              username: username,
              cart: cart,
              orders: orders,
              addToCart: addToCart,
              logout: logout,
              checkout: checkout,
              clearCart: clearCart,
            )
          : LoginPage(onLogin: login),
    );
  }
}