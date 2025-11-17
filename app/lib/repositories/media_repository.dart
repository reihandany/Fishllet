import 'package:supabase_flutter/supabase_flutter.dart';

class MediaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> addMedia({
    required String url,
    String? type,
    String? ownerId, // default: auth.uid() di sisi DB bisa dipakai jika kolom default
  }) async {
    final row = await _client
        .from('media')
        .insert({
          'url': url,
          if (type != null) 'type': type,
          if (ownerId != null) 'owner_id': ownerId,
        })
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  Future<List<Map<String, dynamic>>> listMyMedia() async {
    final data = await _client
        .from('media')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> deleteMedia(int id) async {
    await _client.from('media').delete().eq('id', id);
  }
}
