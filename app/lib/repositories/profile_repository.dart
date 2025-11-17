import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> upsertProfile({
    required String id,
    required String username,
    required String email,
  }) async {
    await _client.from('profiles').upsert(
      {
        'id': id,
        'username': username,
        'display_name': username,
        'email': email,
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    );
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    return data == null ? null : Map<String, dynamic>.from(data);
  }
}
