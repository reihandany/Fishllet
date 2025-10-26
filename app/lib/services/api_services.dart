// lib/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String _baseUrl = "https://www.themealdb.com/api/json/v1/1";

  // --- PERBAIKAN DI SINI ---
  // Kita atur baseUrl saat membuat instance Dio menggunakan BaseOptions.
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://www.themealdb.com/api/json/v1/1",
  ));
  // -------------------------

  // 1. Implementasi menggunakan library 'http' (Tidak Berubah)
  Future<List<Product>> fetchProductsWithHttp() async {
    final response = await http.get(Uri.parse('$_baseUrl/filter.php?c=Seafood'));

    if (response.statusCode == 200) {
      final List meals = json.decode(response.body)['meals'];
      return meals.map((meal) => Product.fromJsonList(meal)).toList();
    } else {
      throw Exception('Failed to load products (http)');
    }
  }

  // 2. Implementasi menggunakan library 'Dio'
  Future<List<Product>> fetchProductsWithDio() async {
    // --- PERBAIKAN DI SINI ---
    // Hapus parameter 'options' karena baseUrl sudah diatur di instance _dio
    final response = await _dio.get('/filter.php?c=Seafood');
    // -------------------------

    final List meals = response.data['meals'];
    return meals.map((meal) => Product.fromJsonList(meal)).toList();
  }

  // --- Fungsi helper untuk EKSPERIMEN 2 (Async Handling) ---

  // Mengambil detail produk berdasarkan ID (untuk chained request)
  Future<Product> fetchProductDetail(String id) async {
    // --- PERBAIKAN DI SINI ---
    // Hapus parameter 'options'
    final response = await _dio.get('/lookup.php?i=$id');
    // -------------------------

    final Map<String, dynamic> meal = response.data['meals'][0];
    return Product.fromJsonDetail(meal);
  }
}