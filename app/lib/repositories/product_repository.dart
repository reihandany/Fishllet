import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listProducts() async {
    final data = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> addProduct({
    required String name,
    required num price,
    String? description,
    String? imageUrl,
  }) async {
    final row = await _client
        .from('products')
        .insert({
          'name': name,
          'price': price,
          'description': description,
          'image_url': imageUrl,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> fields,
  ) async {
    final row = await _client
        .from('products')
        .update(fields)
        .eq('id', id)
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<void> deleteProduct(int id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    try {
      final intId = int.parse(id);
      final row = await _client
          .from('products')
          .select()
          .eq('id', intId)
          .maybeSingle();
      if (row == null) return null;
      return Map<String, dynamic>.from(row);
    } catch (_) {
      // If ID is not numeric or any other error occurs
      return null;
    }
  }
}
