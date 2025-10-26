// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String imageUrl;
  String? description; // Deskripsi (dari API detail)
  final String price;   // Harga (dummy data, karena API tidak menyediakan)

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.price = "Rp 45.000", // Harga dummy untuk UI
  });

  // Factory untuk mem-parsing data dari list API
  factory Product.fromJsonList(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
    );
  }

  // Factory untuk mem-parsing data dari detail API (untuk chained request)
  factory Product.fromJsonDetail(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
      description: json['strInstructions'] ?? 'Deskripsi tidak tersedia.',
    );
  }
}