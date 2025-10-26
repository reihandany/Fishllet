import 'package:get/get.dart';
import '../models/product.dart';
import '../services/http_api_services.dart';
import '../services/dio_api_services.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;

  final httpService = HttpApiService();
  final dioService = DioApiService();

  // Fungsi utama
  Future<void> loadProductsWithHttp() async {
    try {
      isLoading.value = true;
      products.value = await httpService.fetchProducts();
    } catch (e) {
      print('HTTP Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProductsWithDio() async {
    try {
      isLoading.value = true;
      products.value = await dioService.fetchProducts();
    } catch (e) {
      print('Dio Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 🧪 Tambahkan fungsi test performa (agar bisa dipanggil di analysis_page.dart)
  Future<void> runHttpTest() async {
    print('🔹 Running HTTP test...');
    await loadProductsWithHttp();
  }

  Future<void> runDioTest() async {
    print('🔹 Running Dio test...');
    await loadProductsWithDio();
  }
}
