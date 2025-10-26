// lib/login_page.dart

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function(String) onLogin;
  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.isNotEmpty) {
      widget.onLogin(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2380c4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Fishllet', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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