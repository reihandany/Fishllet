// lib/models/fish_item.dart
import 'package:intl/intl.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FISH ITEM MODEL
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Model untuk merepresentasikan item ikan/catatan ikan user.
/// Digunakan untuk CRUD operation di Supabase.
class FishItem {
  final String? id; // UUID dari Supabase
  final String userId; // ID user pemilik item
  final String name; // Nama ikan
  final String species; // Jenis ikan (e.g., "Koi", "Cupang")
  final String? description; // Deskripsi/catatan
  final double? quantity; // Jumlah atau stok
  final String? quantityUnit; // Satuan (e.g., "ekor", "kg")
  final double? price; // Harga per unit
  final String? photoUrl; // URL foto dari Supabase Storage
  final DateTime? createdAt; // Waktu dibuat
  final DateTime? updatedAt; // Waktu diupdate
  final bool? isActive; // Apakah item masih aktif/tersedia

  FishItem({
    this.id,
    required this.userId,
    required this.name,
    required this.species,
    this.description,
    this.quantity,
    this.quantityUnit,
    this.price,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Convert FishItem to JSON (untuk Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      'description': description,
      'quantity': quantity,
      'quantity_unit': quantityUnit,
      'price': price,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Convert JSON to FishItem (dari Supabase response)
  factory FishItem.fromJson(Map<String, dynamic> json) {
    return FishItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble(),
      quantityUnit: json['quantity_unit'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Copy with - untuk update field tertentu
  FishItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? species,
    String? description,
    double? quantity,
    String? quantityUnit,
    double? price,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FishItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Format untuk display
  @override
  String toString() {
    return '''FishItem(
      id: $id,
      name: $name,
      species: $species,
      quantity: $quantity $quantityUnit,
      price: $price,
      createdAt: ${createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : 'N/A'}
    )''';
  }
}
