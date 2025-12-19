import '../models/product.dart';
import 'api_services.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// HTTP API SERVICE - DEPRECATED
/// ═══════════════════════════════════════════════════════════════════════════
///
/// File ini sudah TIDAK DIPAKAI lagi.
/// Semua request sekarang menggunakan ApiService dengan Dio
/// TheMealDB API sudah dihapus total!

@Deprecated('Use ApiService instead')
class HttpApiService {
  // Gunakan ApiService() untuk fetch data dari Custom API
  static final _apiService = ApiService();

  @Deprecated('Use ApiService().fetchProductsWithDio() instead')
  Future<List<Product>> fetchProductsWithHttp() async {
    return await _apiService.fetchProductsWithDio();
  }
}