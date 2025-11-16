// lib/services/supabase_fish_items_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/fish_item.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE FISH ITEMS SERVICE
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Service untuk CRUD operation tabel fish_items di Supabase.
/// Menyediakan fungsi:
/// - Create / Insert item ikan baru
/// - Read / Fetch data ikan user
/// - Update data ikan
/// - Delete data ikan
/// - Stream/Real-time sync data ikan
class SupabaseFishItemsService {
  final SupabaseClient _client = SupabaseConfig.client;
  final String _tableName = SupabaseConfig.fishItemsTable;

  /// Insert/Create item ikan baru
  /// @param fishItem - FishItem object dengan data yang akan disimpan
  /// Returns: FishItem dengan ID dari Supabase
  /// Throws: PostgrestException jika ada error di database
  Future<FishItem> addFishItem(FishItem fishItem) async {
    try {
      final data = fishItem.toJson();
      data.remove('id'); // Remove ID karena akan auto-generate

      final response = await _client
          .from(_tableName)
          .insert([data])
          .select()
          .single();

      final newItem = FishItem.fromJson(response as Map<String, dynamic>);
      print('✅ Fish item added successfully: ${newItem.name}');
      return newItem;
    } on PostgrestException catch (e) {
      print('❌ Add fish item error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error adding fish item: $e');
      rethrow;
    }
  }

  /// Get semua fish items milik user yang login
  /// @param userId - ID user (optional, jika kosong pakai current user)
  /// Returns: List<FishItem>
  Future<List<FishItem>> getFishItemsByUser(String? userId) async {
    try {
      final uid = userId ?? SupabaseConfig.userId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', uid)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final items =
          (response as List).map((e) => FishItem.fromJson(e)).toList();
      print('✅ Fetched ${items.length} fish items for user $uid');
      return items;
    } on PostgrestException catch (e) {
      print('❌ Fetch fish items error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error fetching fish items: $e');
      rethrow;
    }
  }

  /// Get fish item by ID
  /// @param itemId - ID dari fish item
  /// Returns: FishItem atau null jika tidak ditemukan
  Future<FishItem?> getFishItemById(String itemId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', itemId)
          .single();

      final item = FishItem.fromJson(response as Map<String, dynamic>);
      print('✅ Fetched fish item: ${item.name}');
      return item;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found
        return null;
      }
      print('❌ Fetch fish item error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error fetching fish item: $e');
      rethrow;
    }
  }

  /// Update fish item
  /// @param fishItem - FishItem dengan data yang sudah diupdate (harus memiliki ID)
  /// Returns: FishItem terupdate
  Future<FishItem> updateFishItem(FishItem fishItem) async {
    try {
      if (fishItem.id == null) {
        throw Exception('Fish item ID cannot be null');
      }

      final data = fishItem.toJson();
      data.remove('id');
      data.remove('user_id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from(_tableName)
          .update(data)
          .eq('id', fishItem.id!)
          .select()
          .single();

      final updatedItem = FishItem.fromJson(response as Map<String, dynamic>);
      print('✅ Fish item updated successfully: ${updatedItem.name}');
      return updatedItem;
    } on PostgrestException catch (e) {
      print('❌ Update fish item error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error updating fish item: $e');
      rethrow;
    }
  }

  /// Delete fish item (soft delete - set is_active = false)
  /// @param itemId - ID dari fish item
  Future<void> deleteFishItem(String itemId) async {
    try {
      await _client
          .from(_tableName)
          .update({'is_active': false})
          .eq('id', itemId);

      print('✅ Fish item deleted successfully');
    } on PostgrestException catch (e) {
      print('❌ Delete fish item error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error deleting fish item: $e');
      rethrow;
    }
  }

  /// Hard delete fish item (permanent delete)
  /// @param itemId - ID dari fish item
  Future<void> hardDeleteFishItem(String itemId) async {
    try {
      await _client.from(_tableName).delete().eq('id', itemId);

      print('✅ Fish item permanently deleted');
    } on PostgrestException catch (e) {
      print('❌ Hard delete fish item error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error hard deleting fish item: $e');
      rethrow;
    }
  }

  /// Real-time stream untuk listen perubahan data fish items
  /// Berguna untuk sinkronisasi data realtime antar device
  /// @param userId - ID user
  /// Returns: Stream<List<FishItem>>
  Stream<List<FishItem>> getFishItemsStream(String userId) {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at')
        .map((response) {
          return (response as List)
              .map((e) => FishItem.fromJson(e as Map<String, dynamic>))
              .toList();
        });
  }

  /// Search fish items by name atau species
  /// @param query - Search query (nama atau jenis ikan)
  /// @param userId - ID user
  /// Returns: List<FishItem>
  Future<List<FishItem>> searchFishItems(String query, String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .or('name.ilike.%$query%,species.ilike.%$query%');

      final items =
          (response as List).map((e) => FishItem.fromJson(e)).toList();
      print('✅ Found ${items.length} items matching "$query"');
      return items;
    } on PostgrestException catch (e) {
      print('❌ Search fish items error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error searching fish items: $e');
      rethrow;
    }
  }

  /// Batch insert multiple fish items
  /// @param items - List<FishItem> untuk diinsert
  /// Returns: List<FishItem> dengan ID dari Supabase
  Future<List<FishItem>> addMultipleFishItems(List<FishItem> items) async {
    try {
      final dataList = items.map((item) {
        final data = item.toJson();
        data.remove('id');
        return data;
      }).toList();

      final response = await _client
          .from(_tableName)
          .insert(dataList)
          .select();

      final newItems = (response as List)
          .map((e) => FishItem.fromJson(e as Map<String, dynamic>))
          .toList();
      print('✅ ${newItems.length} fish items added successfully');
      return newItems;
    } on PostgrestException catch (e) {
      print('❌ Batch add fish items error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected error batch adding fish items: $e');
      rethrow;
    }
  }
}
