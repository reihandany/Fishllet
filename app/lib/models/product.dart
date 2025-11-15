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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromJsonList(json);
  }
}
