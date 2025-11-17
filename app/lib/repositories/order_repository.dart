import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final _client = Supabase.instance.client;

  /// Insert order baru dengan items, return order_id
  Future<int> createOrder({
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Hitung total
    final total = items.fold<num>(
      0,
      (sum, item) => sum + (item['price'] as num) * (item['qty'] as num),
    );

    // Insert order
    final orderRow = await _client
        .from('orders')
        .insert({
          'user_id': userId,
          'total': total,
          'status': 'pending',
        })
        .select('id')
        .single();

    final orderId = orderRow['id'] as int;

    // Insert order_items
    final orderItems = items.map((item) {
      return {
        'order_id': orderId,
        'product_id': item['id'],
        'product_name': item['name'],
        'quantity': item['qty'],
        'price': item['price'],
      };
    }).toList();

    await _client.from('order_items').insert(orderItems);

    return orderId;
  }

  /// Ambil semua order milik user
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Detail 1 order dengan items
  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .maybeSingle();

    return data == null ? null : Map<String, dynamic>.from(data);
  }
}
