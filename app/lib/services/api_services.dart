// lib/services/api_services.dart
import 'package:dio/dio.dart';
import '../models/product.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://www.themealdb.com/api/json/v1/1",
    connectTimeout: Duration(seconds: 6),
    receiveTimeout: Duration(seconds: 6),
  ));

  // FETCH LIST
  Future<List<Product>> fetchProductsWithDio() async {
    final response = await _dio.get('/filter.php?c=Seafood');
    final List meals = response.data['meals'];
    return meals.map((e) => Product.fromJsonList(e)).toList();
  }

  // DETAIL
  Future<Product> fetchProductDetail(String id) async {
    final response = await _dio.get('/lookup.php?i=$id');
    final Map<String, dynamic> meal = response.data['meals'][0];
    return Product.fromJsonDetail(meal);
  }
}
