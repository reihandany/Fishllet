// lib/services/supabase_storage_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE STORAGE SERVICE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Service untuk upload dan manage file storage di Supabase.
/// Menyediakan fungsi:
/// - Upload foto dari file
/// - Dapatkan public URL
/// - Delete file
/// - Batch upload
class SupabaseStorageService {
  final SupabaseClient _client = SupabaseConfig.client;
  final String _bucketName = SupabaseConfig.fishPhotoBucket;

  /// Upload foto ke Supabase Storage
  /// @param filePath - Path file lokal yang akan diupload
  /// @param fileName - Nama file (optional, default: filename dari path)
  /// Returns: Public URL dari file yang diupload
  /// Throws: StorageException jika ada error
  Future<String> uploadFishPhoto(
    String filePath, {
    String? fileName,
  }) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      // Generate unique filename jika tidak diberikan
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';

      // Upload file
      final path = 'fish-photos/${SupabaseConfig.userId}/$name';
      await _client.storage.from(_bucketName).upload(path, file);

      // Get public URL
      final publicUrl =
          _client.storage.from(_bucketName).getPublicUrl(path);

      print('✅ Photo uploaded successfully: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('❌ Upload photo error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error uploading photo: $e');
      rethrow;
    }
  }

  /// Upload foto dan replace jika sudah ada dengan nama yang sama
  /// @param filePath - Path file lokal
  /// @param fileName - Nama file (untuk identify file yang di-replace)
  /// Returns: Public URL dari file
  Future<String> uploadFishPhotoReplace(
    String filePath, {
    required String fileName,
  }) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final path = 'fish-photos/${SupabaseConfig.userId}/$fileName';

      // Upload dengan upsert=true untuk replace file yang ada
      await _client.storage
          .from(_bucketName)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));

      // Get public URL
      final publicUrl =
          _client.storage.from(_bucketName).getPublicUrl(path);

      print('✅ Photo replaced successfully: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      print('❌ Replace photo error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error replacing photo: $e');
      rethrow;
    }
  }

  /// Delete foto dari storage
  /// @param fileName - Nama file (relative path di bucket)
  Future<void> deleteFishPhoto(String fileName) async {
    try {
      final path = 'fish-photos/${SupabaseConfig.userId}/$fileName';

      await _client.storage.from(_bucketName).remove([path]);

      print('✅ Photo deleted successfully');
    } on StorageException catch (e) {
      print('❌ Delete photo error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error deleting photo: $e');
      rethrow;
    }
  }

  /// Delete foto by public URL
  /// @param publicUrl - Public URL dari foto
  Future<void> deleteFishPhotoByUrl(String publicUrl) async {
    try {
      // Extract path dari URL
      // Format: https://bucket.supabase.co/storage/v1/object/public/bucket/path/to/file
      final uri = Uri.parse(publicUrl);
      final pathParts = uri.path.split('/');

      // Get path setelah '/public/'
      final publicIndex = pathParts.indexOf('public');
      if (publicIndex == -1) {
        throw Exception('Invalid public URL format');
      }

      final filePath = pathParts.sublist(publicIndex + 1).join('/');

      await _client.storage.from(_bucketName).remove([filePath]);

      print('✅ Photo deleted by URL successfully');
    } on StorageException catch (e) {
      print('❌ Delete photo by URL error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error deleting photo by URL: $e');
      rethrow;
    }
  }

  /// Batch upload multiple photos
  /// @param filePaths - List path file yang akan diupload
  /// Returns: Map<String, String> - Map dari filename ke public URL
  Future<Map<String, String>> uploadMultipleFishPhotos(
    List<String> filePaths,
  ) async {
    try {
      final results = <String, String>{};

      for (final filePath in filePaths) {
        try {
          final publicUrl = await uploadFishPhoto(filePath);
          results[filePath.split('/').last] = publicUrl;
        } catch (e) {
          print('⚠️  Failed to upload $filePath: $e');
          // Continue ke file berikutnya
        }
      }

      print('✅ Batch upload complete: ${results.length}/${filePaths.length}');
      return results;
    } catch (e) {
      print('❌ Unexpected error in batch upload: $e');
      rethrow;
    }
  }

  /// List semua foto user
  /// Returns: List<FileObject>
  Future<List<FileObject>> listFishPhotos() async {
    try {
      final files =
          await _client.storage.from(_bucketName).list(
                path: 'fish-photos/${SupabaseConfig.userId}',
              );

      print('✅ Listed ${files.length} photos');
      return files;
    } on StorageException catch (e) {
      print('❌ List photos error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error listing photos: $e');
      rethrow;
    }
  }

  /// Get public URL dari filename
  /// @param fileName - Nama file (relative path)
  /// Returns: Public URL
  String getPublicUrl(String fileName) {
    final path = 'fish-photos/${SupabaseConfig.userId}/$fileName';
    return _client.storage.from(_bucketName).getPublicUrl(path);
  }

  /// Check if bucket exists dan user bisa akses
  /// Returns: true jika bucket accessible
  Future<bool> isBucketAccessible() async {
    try {
      await listFishPhotos();
      return true;
    } catch (e) {
      return false;
    }
  }
}
