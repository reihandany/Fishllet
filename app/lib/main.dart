// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'utils/app__bindings.dart';
import 'views/login_page.dart';
import 'views/product_list_page.dart';

void main() {
  // Inisialisasi semua controller saat aplikasi dimulai
  AppBindings().dependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan GetMaterialApp untuk mengaktifkan GetX
    return GetMaterialApp(
      title: 'Fishllet (Refactored)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2380c4)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
        ),
      ),
      // Gunakan Obx untuk bereaksi terhadap perubahan state login
      home: Obx(() {
        // Cari AuthController yang sudah di-inisialisasi
        final authController = Get.find<AuthController>();
        // Tampilkan halaman yang sesuai berdasarkan status login
        return authController.isLoggedIn.value
            ? ProductListPage()
            : LoginPage();
      }),
    );
  }
}