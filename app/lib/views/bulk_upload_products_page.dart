import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';
import '../repositories/product_repository.dart';

class BulkUploadProductsPage extends StatefulWidget {
  const BulkUploadProductsPage({super.key});

  @override
  State<BulkUploadProductsPage> createState() => _BulkUploadProductsPageState();
}

class _BulkUploadProductsPageState extends State<BulkUploadProductsPage> {
  final _storage = StorageService();
  final _productRepo = ProductRepository();
  final List<Map<String, dynamic>> _uploadQueue = [];
  bool _isUploading = false;
  int _uploadedCount = 0;

  // Data produk sesuai gambar yang Anda kirim
  final List<Map<String, dynamic>> _productData = [
    {'name': 'Ceviche de pescado', 'price': 45000, 'description': 'Fresh fish ceviche'},
    {'name': 'Paella valenciana', 'price': 85000, 'description': 'Traditional Spanish paella'},
    {'name': 'Arroz con gambas y calamar', 'price': 75000, 'description': 'Rice with shrimp and squid'},
    {'name': 'Pulpo a la gallega', 'price': 95000, 'description': 'Galician-style octopus'},
    {'name': 'Calamares a la romana', 'price': 55000, 'description': 'Fried calamari rings'},
    {'name': 'Gambas al ajillo', 'price': 65000, 'description': 'Garlic shrimp'},
  ];

  Future<void> _pickAndUploadImages() async {
    try {
      // Pick multiple images
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _uploadQueue.clear();
        for (int i = 0; i < result.files.length && i < _productData.length; i++) {
          final file = result.files[i];
          _uploadQueue.add({
            'file': file,
            'product': _productData[i],
            'status': 'pending',
          });
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file: $e');
    }
  }

  Future<void> _uploadAll() async {
    if (_uploadQueue.isEmpty) {
      Get.snackbar('Info', 'Pilih gambar terlebih dahulu');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
    });

    try {
      for (int i = 0; i < _uploadQueue.length; i++) {
        final item = _uploadQueue[i];
        final file = item['file'] as PlatformFile;
        final product = item['product'] as Map<String, dynamic>;

        setState(() {
          _uploadQueue[i]['status'] = 'uploading';
        });

        try {
          // Upload gambar ke Storage
          final fileName = 'prod_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final imageUrl = await _storage.uploadBytes(
            bytes: file.bytes!,
            path: 'products/$fileName',
            contentType: 'image/jpeg',
          );

          // Insert produk ke database
          await _productRepo.addProduct(
            name: product['name'],
            price: product['price'],
            description: product['description'],
            imageUrl: imageUrl,
          );

          setState(() {
            _uploadQueue[i]['status'] = 'success';
            _uploadQueue[i]['imageUrl'] = imageUrl;
            _uploadedCount++;
          });
        } catch (e) {
          setState(() {
            _uploadQueue[i]['status'] = 'failed';
            _uploadQueue[i]['error'] = e.toString();
          });
        }

        // Delay sedikit agar tidak overload
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Get.snackbar(
        'Selesai',
        'Berhasil upload $_uploadedCount dari ${_uploadQueue.length} produk',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Upload Products'),
        backgroundColor: const Color(0xFF1F70B2),
        actions: [
          if (_uploadQueue.isNotEmpty && !_isUploading)
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: _uploadAll,
              tooltip: 'Upload All',
            ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1F70B2).withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cara Upload Produk:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text('1. Klik tombol "Pilih Gambar"'),
                const Text('2. Pilih 6 gambar produk sesuai urutan:'),
                ...List.generate(
                  _productData.length,
                  (i) => Text('   ${i + 1}. ${_productData[i]['name']}'),
                ),
                const Text('3. Klik ikon upload di atas'),
                const SizedBox(height: 8),
                Text(
                  'Progress: $_uploadedCount/${_uploadQueue.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Upload Queue List
          Expanded(
            child: _uploadQueue.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Belum ada gambar dipilih'),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _pickAndUploadImages,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Pilih Gambar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F70B2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _uploadQueue.length,
                    itemBuilder: (context, index) {
                      final item = _uploadQueue[index];
                      final file = item['file'] as PlatformFile;
                      final product = item['product'] as Map<String, dynamic>;
                      final status = item['status'] as String;

                      IconData icon;
                      Color color;
                      switch (status) {
                        case 'success':
                          icon = Icons.check_circle;
                          color = Colors.green;
                          break;
                        case 'failed':
                          icon = Icons.error;
                          color = Colors.red;
                          break;
                        case 'uploading':
                          icon = Icons.cloud_upload;
                          color = Color(0xFF1F70B2);
                          break;
                        default:
                          icon = Icons.pending;
                          color = Colors.grey;
                      }

                      return ListTile(
                        leading: file.bytes != null
                            ? Image.memory(file.bytes!, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image),
                        title: Text(product['name']),
                        subtitle: Text('Rp ${product['price']} - ${file.name}'),
                        trailing: status == 'uploading'
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(icon, color: color),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _uploadQueue.isEmpty
          ? FloatingActionButton.extended(
              onPressed: _pickAndUploadImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Pilih Gambar'),
              backgroundColor: const Color(0xFF1F70B2),
            )
          : null,
    );
  }
}
