import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/product.dart';
import '../services/api_services.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var filteredProducts = <Product>[].obs;
  var isLoading = false.obs;
  var isOffline = false.obs;
  
  // Search & Filter
  var searchQuery = ''.obs;
  var selectedCategory = 'Semua'.obs;
  var selectedSort = 'Nama A-Z'.obs;
  var categories = <String>['Semua'].obs;

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

      // Extract unique categories
      final cats = data.map((p) => p.category).toSet().toList();
      categories.value = ['Semua', ...cats];

      // simpan ke hive
      await offlineBox.clear();
      await offlineBox.addAll(data);

      isOffline.value = false;
      
      // Apply filter after loading
      applyFilter();
    } catch (e) {
      // OFFLINE MODE
      final cached = offlineBox.values.toList();

      if (cached.isNotEmpty) {
        products.assignAll(cached);
        final cats = cached.map((p) => p.category).toSet().toList();
        categories.value = ['Semua', ...cats];
        isOffline.value = true;
        applyFilter();
      } else {
        products.clear();
        filteredProducts.clear();
      }
    }

    isLoading.value = false;
  }

  /// =====================================================================
  /// SEARCH & FILTER
  /// =====================================================================
  void applyFilter() {
    var result = products.toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      result = result.where((p) => 
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Filter by category
    if (selectedCategory.value != 'Semua') {
      result = result.where((p) => p.category == selectedCategory.value).toList();
    }

    // Sort
    switch (selectedSort.value) {
      case 'Nama A-Z':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Nama Z-A':
        result.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Harga Terendah':
        result.sort((a, b) => a.numericPrice.compareTo(b.numericPrice));
        break;
      case 'Harga Tertinggi':
        result.sort((a, b) => b.numericPrice.compareTo(a.numericPrice));
        break;
      case 'Rating Tertinggi':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    filteredProducts.assignAll(result);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilter();
  }

  void setSort(String sort) {
    selectedSort.value = sort;
    applyFilter();
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
