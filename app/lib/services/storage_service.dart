import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const String bucket = 'product-images';
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    return getPublicUrl(path);
  }

  String getPublicUrl(String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
