// lib/services/api_services.dart
import '../models/product.dart';
import '../repositories/product_repository.dart';

/// ApiService tanpa TheMealDB.
/// Sumber data hanya dari Supabase melalui `ProductRepository`.
class ApiService {
  final ProductRepository _supabaseRepo = ProductRepository();

  /// Ambil daftar produk dari Supabase saja.
  /// Tetap mempertahankan nama method agar kompatibel dengan controller.
  Future<List<Product>> fetchProductsWithDio() async {
    try {
      final supabaseProducts = await _supabaseRepo.listProducts();
      return supabaseProducts
          .map((e) => Product.fromSupabase(e))
          .toList();
    } catch (e) {
      print('⚠️ Error fetching from Supabase: $e');
      rethrow;
    }
  }

  /// Ambil detail produk dari Supabase menggunakan ID.
  Future<Product> fetchProductDetail(String id) async {
    try {
      final row = await _supabaseRepo.getProductById(id);
      if (row == null) {
        throw Exception('Product not found');
      }
      return Product.fromSupabase(row);
    } catch (e) {
      rethrow;
    }
  }
}
