import 'package:dio/dio.dart';
import '../models/product.dart';

class DioApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://www.themealdb.com/api/json/v1/1/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  DioApiService() {
    // Tambahkan interceptor untuk logging request dan response
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🧾 DIO LOG: $obj'),
      ),
    );
  }

  // Ambil daftar ikan (list)
  Future<List<Product>> fetchProducts() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await dio.get('search.php?s=salmon');
      print('⏱ Dio response time: ${stopwatch.elapsedMilliseconds} ms');

      if (response.statusCode == 200) {
        final data = response.data;
        final meals = data['meals'] as List;
        return meals.map((item) => Product.fromJsonList(item)).toList();
      } else {
        throw Exception('Failed to load fish products with Dio');
      }
    } on DioException catch (e) {
      stopwatch.stop();
      print('❌ Dio Error: ${e.message}');
      rethrow;
    }
  }

  // Ambil detail ikan berdasarkan ID (untuk eksperimen async atau detail view)
  Future<Product> fetchProductDetail(String idMeal) async {
    try {
      final response = await dio.get('lookup.php?i=$idMeal');

      if (response.statusCode == 200) {
        final data = response.data;
        final meal = data['meals'][0];
        return Product.fromJsonDetail(meal);
      } else {
        throw Exception('Failed to load meal detail with Dio');
      }
    } on DioException catch (e) {
      print('❌ Dio Detail Error: ${e.message}');
      rethrow;
    }
  }
}