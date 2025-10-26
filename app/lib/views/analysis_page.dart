// lib/views/analysis_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';

class AnalysisPage extends StatelessWidget {
  AnalysisPage({super.key});

  final ProductController product = Get.find<ProductController>();

  Widget _buildResultCard(String title, RxString result, RxString error) {
    return Obx(() => Card(
          color: error.value.isNotEmpty ? Colors.red.shade50 : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (result.value.isNotEmpty) const SizedBox(height: 8),
                if (result.value.isNotEmpty) Text(result.value),
                if (error.value.isNotEmpty) const SizedBox(height: 8),
                if (error.value.isNotEmpty)
                  Text('Error: ${error.value}',
                      style: TextStyle(color: Colors.red.shade700)),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Analisis & Profiling'),
        backgroundColor: const Color(0xFF2380c4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- EKSPERIMEN 1: Performa HTTP Library ---
            Text('Eksperimen 1: Performa HTTP Library',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: product.runHttpTest,
              // --- PERBAIKAN DI SINI ---
              child: const Text("Jalankan Tes 'http'"),
            ),
            ElevatedButton(
              onPressed: product.runDioTest,
              // --- PERBAIKAN DI SINI ---
              child: const Text("Jalankan Tes 'Dio'"),
            ),
            const SizedBox(height: 16),
            Obx(() => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text('Response Time \'http\': ${product.httpResponseTime.value} ms'),
                        Text('Response Time \'Dio\': ${product.dioResponseTime.value} ms'),
                      ],
                    ),
                  ),
                )),
            _buildResultCard(
                'Log \'http\'', ''.obs, product.httpError),
            _buildResultCard(
                'Log \'Dio\'', ''.obs, product.dioError),

            const Divider(height: 40, thickness: 1),

            // --- EKSPERIMEN 2: Async Handling ---
            Text('Eksperimen 2: Async Handling (Chained Request)',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: product.runAsyncAwaitChain,
              // --- PERBAIKAN DI SINI ---
              child: const Text("Jalankan 'async-await'"),
            ),
            ElevatedButton(
              onPressed: product.runCallbackChain,
              // --- PERBAIKAN DI SINI ---
              child: const Text("Jalankan 'Callback Chaining'"),
            ),
            const SizedBox(height: 16),
            _buildResultCard('Hasil Async-Await',
                product.asyncAwaitResult, product.asyncError),
            _buildResultCard('Hasil Callback Chain',
                product.callbackChainResult, product.callbackError),
            
            // Tampilkan Indikator Loading Global
            Obx(() {
              if (product.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}