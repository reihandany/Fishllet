import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepository {
  final _client = Supabase.instance.client;

  /// Get atau buat cart untuk user saat ini
  Future<int> getOrCreateCart() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Cek apakah cart sudah ada
    var cart = await _client
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (cart != null) {
      return cart['id'] as int;
    }

    // Buat cart baru
    final newCart = await _client
        .from('carts')
        .insert({'user_id': userId})
        .select('id')
        .single();

    return newCart['id'] as int;
  }

  /// Tambah produk ke cart
  Future<void> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    final cartId = await getOrCreateCart();

    // Cek apakah produk sudah ada di cart
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      // Update quantity
      await _client
          .from('cart_items')
          .update({'quantity': existing['quantity'] + quantity})
          .eq('id', existing['id']);
    } else {
      // Insert baru
      await _client.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  /// Ambil semua item di cart dengan detail produk
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final cartId = await getOrCreateCart();

    final data = await _client
        .from('cart_items')
        .select('id, quantity, product_id, products(id, name, price, image_url)')
        .eq('cart_id', cartId);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Update quantity item
  Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    await _client
        .from('cart_items')
        .update({'quantity': newQuantity})
        .eq('id', cartItemId);
  }

  /// Hapus item dari cart
  Future<void> removeItem(int cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
  }

  /// Clear semua item di cart
  Future<void> clearCart() async {
    final cartId = await getOrCreateCart();
    await _client.from('cart_items').delete().eq('cart_id', cartId);
  }
}
