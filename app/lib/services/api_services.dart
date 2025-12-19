// lib/services/api_services.dart
import 'package:dio/dio.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// API SERVICE - CUSTOM API + AUTO SYNC TO SUPABASE
/// ═══════════════════════════════════════════════════════════════════════════
class ApiService {
  // Custom API - Pilih sesuai platform
  static const String _baseUrl = "http://10.0.2.2:3000/api"; // Android Emulator
  // static const String _baseUrl = "http://localhost:3000/api"; // iOS/Web
  // static const String _baseUrl = "http://192.168.1.XXX:3000/api"; // Physical Device

  final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              print('🔄 API Request: ${options.method} ${options.uri}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              print('✅ API Response: ${response.statusCode}');
              return handler.next(response);
            },
            onError: (error, handler) {
              print('❌ API Error: ${error.message}');
              print('   URL: ${error.requestOptions.uri}');
              return handler.next(error);
            },
          ),
        );

  final ProductRepository _productRepo = ProductRepository();

  /// ═══════════════════════════════════════════════════════════════════════════
  /// FETCH ALL PRODUCTS - CUSTOM API + AUTO SYNC TO SUPABASE
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<List<Product>> fetchProductsWithDio() async {
    try {
      print('📡 Fetching from CUSTOM API: $_baseUrl/products');

      final response = await _dio.get('/products');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List meals = response.data['meals'] ?? [];

        print('✅ Loaded ${meals.length} products from CUSTOM API');
        if (meals.isNotEmpty) {
          print(
            '📦 First product: ${meals.first['strMeal']} - Rp ${meals.first['price']}',
          );
        }

        final products = meals
            .map((json) => Product.fromJsonList(json))
            .toList();

        // 🔥 AUTO SYNC KE SUPABASE untuk fix foreign key error
        _syncProductsToSupabase(products);

        return products;
      } else {
        throw Exception('❌ Invalid response from API');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.type} - ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          '⏱️ Connection timeout! Pastikan API server running di:\nhttp://localhost:3000\n\nJalankan: node server.js',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          '🔌 Tidak bisa connect ke server!\n\n✅ Pastikan API server running:\ncd fishllet-api\nnode server.js\n\n✅ Check baseUrl: $_baseUrl',
        );
      }

      rethrow;
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// SYNC PRODUCTS TO SUPABASE - Fix Foreign Key Error
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<void> _syncProductsToSupabase(List<Product> products) async {
    try {
      print('🔄 Syncing ${products.length} products to Supabase...');

      for (var product in products) {
        try {
          await _productRepo.upsertProduct(
            id: product.id,
            name: product.name,
            price: double.tryParse(product.price) ?? 0.0,
            description: product.description,
            imageUrl: product.imageUrl,
            category: product.category,
            updatedAt: DateTime.now(), // ✅ Tambahkan timestamp
          );
        } catch (e) {
          print('⚠️ Failed to sync product ${product.id}: $e');
          // Continue with other products
        }
      }

      print('✅ Products synced to Supabase successfully');
    } catch (e) {
      print('⚠️ Supabase sync error (non-critical): $e');
      // Don't throw - sync failure shouldn't block app
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// FETCH PRODUCT DETAIL BY ID
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<Product> fetchProductDetail(String id) async {
    try {
      print('📡 Fetching product detail: $id');

      final response = await _dio.get('/products/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List meals = response.data['meals'];
        if (meals.isEmpty) throw Exception('Product not found');

        return Product.fromJsonDetail(meals[0]);
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      print('❌ Error fetching product detail: $e');
      rethrow;
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// HEALTH CHECK
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ API Server is healthy!');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// SEARCH PRODUCTS
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products/search/$query');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List meals = response.data['meals'] ?? [];
        return meals.map((json) => Product.fromJsonList(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error searching: $e');
      return [];
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// FILTER BY PRICE
  /// ═══════════════════════════════════════════════════════════════════════════
  Future<List<Product>> filterByPrice(int min, int max) async {
    try {
      final response = await _dio.get(
        '/products/filter/price',
        queryParameters: {'min': min, 'max': max},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List meals = response.data['meals'] ?? [];
        return meals.map((json) => Product.fromJsonList(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error filtering: $e');
      return [];
    }
  }
}
