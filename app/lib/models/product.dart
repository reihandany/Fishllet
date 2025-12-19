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

  @HiveField(6)
  final String category;

  @HiveField(7)
  final double rating;

  @HiveField(8)
  final double numericPrice;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description,
    this.price = "Rp 45.000",
    this.quantity = 1,
    this.category = "Ikan Segar",
    this.rating = 4.5,
    this.numericPrice = 45000,
  });

  factory Product.fromJsonList(Map<String, dynamic> json) {
    // Format price dari API
    String formattedPrice = 'Rp 45.000';
    double numPrice = 45000;
    if (json['price'] != null) {
      final price = json['price'];
      numPrice = price is int ? price.toDouble() : (price is double ? price : 45000.0);
      // Format angka dengan pemisah ribuan
      final priceStr = numPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      formattedPrice = 'Rp $priceStr';
    }
    
    return Product(
      id: json['idMeal'] ?? json['id']?.toString() ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
      category: json['strCategory'] ?? 'Ikan Segar',
      rating: 4.0 + (json['idMeal'].hashCode % 10) / 10, // Random rating 4.0-4.9
      price: formattedPrice,
      numericPrice: numPrice,
    );
  }

  factory Product.fromJsonDetail(Map<String, dynamic> json) {
    // Format price dari API
    String formattedPrice = 'Rp 45.000';
    double numPrice = 45000;
    if (json['price'] != null) {
      final price = json['price'];
      numPrice = price is int ? price.toDouble() : (price is double ? price : 45000.0);
      // Format angka dengan pemisah ribuan
      final priceStr = numPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
      formattedPrice = 'Rp $priceStr';
    }
    
    return Product(
      id: json['idMeal'] ?? json['id']?.toString() ?? '',
      name: json['strMeal'] ?? 'Tanpa nama',
      imageUrl: json['strMealThumb'] ?? '',
      description: json['strInstructions'] ?? 'Deskripsi tidak tersedia.',
      category: json['strCategory'] ?? 'Ikan Segar',
      rating: 4.0 + (json['idMeal'].hashCode % 10) / 10,
      price: formattedPrice,
      numericPrice: numPrice,
    );
  }

  /// Factory untuk data dari Supabase
  factory Product.fromSupabase(Map<String, dynamic> json) {
    // Format price dari numeric ke string Rupiah
    String formattedPrice = 'Rp 45.000';
    double numPrice = 45000;
    if (json['price'] != null) {
      final price = json['price'];
      numPrice = price.toDouble();
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
      category: json['category'] ?? 'Ikan Segar',
      rating: json['rating']?.toDouble() ?? 4.5,
      numericPrice: numPrice,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.fromJsonList(json);
  }
}
