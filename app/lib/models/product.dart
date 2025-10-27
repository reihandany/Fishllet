// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String? description; // Deskripsi dari API detail
  final String price; // Harga dummy untuk UI
  int quantity; // Quantity untuk cart (mutable)

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.price = "Rp 45.000",
    this.quantity = 1, // Default quantity = 1
  });

  // ✅ Factory untuk parsing data dari list API (misalnya list meal)
  factory Product.fromJsonList(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
    );
  }

  // ✅ Factory untuk parsing data dari detail API
  factory Product.fromJsonDetail(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
      description: json['strInstructions'] ?? 'Deskripsi tidak tersedia.',
    );
  }

  // ✅ Tambahan alias agar kompatibel dengan Product.fromJson()
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromJsonList(json);
  }
}
