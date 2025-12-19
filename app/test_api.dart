import 'package:dio/dio.dart';

void main() async {
  print('🧪 Testing Custom API Connection...\n');

  // Test 1: Android Emulator Address
  await testAPI('http://10.0.2.2:3000/api', 'Android Emulator');

  // Test 2: Localhost (jika pakai iOS atau web)
  await testAPI('http://localhost:3000/api', 'Localhost');

  print('\n✅ Test selesai!');
}

Future<void> testAPI(String baseUrl, String name) async {
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('📡 Testing: $name');
  print('🔗 URL: $baseUrl');

  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
      ),
    );

    final response = await dio.get('/products');

    if (response.statusCode == 200) {
      final data = response.data;
      final count = data['count'];
      final meals = data['meals'] as List;

      print('✅ SUCCESS!');
      print('📦 Total products: $count');
      print('🐟 First product: ${meals.first['strMeal']}');
      print('💰 Price: Rp ${meals.first['price']}');
    }
  } catch (e) {
    print('❌ FAILED: $e');
  }
  print('');
}
