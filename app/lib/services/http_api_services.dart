import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class HttpApiService {
  final String baseUrl = 'https://www.themealdb.com/api/json/v1/1/search.php?s=fish';

  Future<List<Product>> fetchProducts() async {
    final stopwatch = Stopwatch()..start();
    final response = await http.get(Uri.parse(baseUrl));
    stopwatch.stop();

    print('⏱ HTTP response time: ${stopwatch.elapsedMilliseconds} ms');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'] as List;
      return meals.map((item) => Product.fromJsonList(item)).toList();
    } else {
      throw Exception('Failed to load fish products');
    }
  }

  Future<Product> fetchProductDetail(String idMeal) async {
    final url = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meal = data['meals'][0];
      return Product.fromJsonDetail(meal);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }
}
