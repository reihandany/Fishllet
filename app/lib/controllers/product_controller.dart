import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/product.dart';
import '../services/api_services.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;
  var isOffline = false.obs;

  final ApiService api = ApiService();
  late Box<Product> offlineBox;

  @override
  void onInit() async {
    super.onInit();

    // buka box HIVE
    offlineBox = await Hive.openBox<Product>('products');

    // load langsung tanpa harus klik tombol
    loadProducts();
  }

  /// =====================================================================
  ///  FETCH PRODUCTS (ONLINE + FALLBACK OFFLINE)
  /// =====================================================================
  Future<void> loadProducts() async {
    isLoading.value = true;

    try {
      // ONLINE FETCH
      final data = await api.fetchProductsWithDio();

      // tampilkan ke UI
      products.assignAll(data);

      // simpan ke hive
      await offlineBox.clear();
      await offlineBox.addAll(data);

      isOffline.value = false;
    } catch (e) {
      // OFFLINE MODE
      final cached = offlineBox.values.toList();

      if (cached.isNotEmpty) {
        products.assignAll(cached);
        isOffline.value = true;
      } else {
        products.clear();
      }
    }

    isLoading.value = false;
  }

  /// =====================================================================
  /// FETCH DETAIL - ONLINE + OFFLINE
  /// =====================================================================
  Future<Product> loadDetail(String id) async {
    try {
      return await api.fetchProductDetail(id);
    } catch (e) {
      return products.firstWhere(
        (p) => p.id == id,
        orElse: () => Product(id: id, name: "Unknown", imageUrl: ""),
      );
    }
  }
}
