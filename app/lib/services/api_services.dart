// lib/services/api_services.dart
import 'package:dio/dio.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://www.themealdb.com/api/json/v1/1",
    connectTimeout: Duration(seconds: 6),
    receiveTimeout: Duration(seconds: 6),
  ));

  final ProductRepository _supabaseRepo = ProductRepository();

  // FETCH LIST - Gabungan dari API eksternal + Supabase
  Future<List<Product>> fetchProductsWithDio() async {
    List<Product> allProducts = [];

    // 1. Ambil dari API eksternal (themealdb)
    try {
      final response = await _dio.get('/filter.php?c=Seafood');
      final List meals = response.data['meals'];
      allProducts.addAll(meals.map((e) => Product.fromJsonList(e)).toList());
    } catch (e) {
      print('⚠️ Error fetching from external API: $e');
    }

    // 2. Ambil dari Supabase (produk custom)
    try {
      final supabaseProducts = await _supabaseRepo.listProducts();
      allProducts.addAll(
        supabaseProducts.map((e) => Product.fromSupabase(e)).toList(),
      );
    } catch (e) {
      print('⚠️ Error fetching from Supabase: $e');
    }

    return allProducts;
  }

  // DETAIL
  Future<Product> fetchProductDetail(String id) async {
    final response = await _dio.get('/lookup.php?i=$id');
    final Map<String, dynamic> meal = response.data['meals'][0];
    return Product.fromJsonDetail(meal);
  }
}
