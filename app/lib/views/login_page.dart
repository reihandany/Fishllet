// lib/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

// Diubah menjadi StatelessWidget karena state dikelola GetX
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Ambil instance AuthController yang sudah di-register di main.dart
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.isNotEmpty) {
      // Panggil fungsi login dari controller
      authController.login(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI tetap sama seperti kode Anda
    return Scaffold(
      backgroundColor: const Color(0xFF2380c4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Fishllet',
                  style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2380c4),
                  ),
                  onPressed: _submit,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}