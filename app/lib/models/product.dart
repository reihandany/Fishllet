import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String price;

  @HiveField(5)
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.price = "Rp 45.000",
    this.quantity = 1,
  });

  factory Product.fromJsonList(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
    );
  }

  factory Product.fromJsonDetail(Map<String, dynamic> json) {
    return Product(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
      description: json['strInstructions'] ?? 'Deskripsi tidak tersedia.',
    );
  }

  /// Factory untuk data dari Supabase
  factory Product.fromSupabase(Map<String, dynamic> json) {
    // Format price dari numeric ke string Rupiah
    String formattedPrice = 'Rp 45.000';
    if (json['price'] != null) {
      final price = json['price'];
      // Format angka dengan pemisah ribuan
      final priceStr = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      formattedPrice = 'Rp $priceStr';
    }
    
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Tanpa nama',
      imageUrl: json['image_url'] ?? '',
      description: json['description'],
      price: formattedPrice,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromJsonList(json);
  }
}
