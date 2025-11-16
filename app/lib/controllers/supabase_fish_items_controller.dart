// lib/controllers/supabase_fish_items_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/fish_item.dart';
import '../services/supabase_fish_items_service.dart';
import 'supabase_auth_controller.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SUPABASE FISH ITEMS CONTROLLER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Controller untuk mengelola data fish items user di Supabase.
/// Provides:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Real-time sync dengan Supabase Realtime
/// - Caching dan filtering data
/// - Loading dan error states
class SupabaseFishItemsController extends GetxController {
  late SupabaseFishItemsService _service;
  late SupabaseAuthController _authController;

  // ─────────────────────────────────────────────────────────────────────────
  // OBSERVABLE VARIABLES
  // ─────────────────────────────────────────────────────────────────────────

  /// List semua fish items user
  var fishItems = <FishItem>[].obs;

  /// Loading state
  var isLoading = false.obs;

  /// Error message
  var errorMessage = ''.obs;

  /// Search query
  var searchQuery = ''.obs;

  /// Filtered items berdasarkan search
  var filteredItems = <FishItem>[].obs;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _service = SupabaseFishItemsService();

    try {
      _authController = Get.find<SupabaseAuthController>();
    } catch (e) {
      debugPrint('⚠️  SupabaseAuthController not found');
    }

    // Listen search query
    ever(searchQuery, (_) => _filterItems());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Load semua fish items milik user
  Future<void> loadFishItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user ID dari auth controller
      final userId = _authController.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final items = await _service.getFishItemsByUser(userId);
      fishItems.assignAll(items);
      _filterItems();

      debugPrint('✅ Loaded ${items.length} fish items');
    } catch (e) {
      errorMessage.value = 'Failed to load fish items: $e';
      Get.snackbar(
        'Error',
        'Failed to load fish items',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('❌ Load fish items error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add fish item baru
  /// @param fishItem - FishItem object
  Future<bool> addFishItem(FishItem fishItem) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Ensure userId is set
      final userId = _authController.userId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final newItem = fishItem.copyWith(userId: userId);
      final result = await _service.addFishItem(newItem);

      fishItems.add(result);
      _filterItems();

      Get.snackbar(
        'Success',
        'Fish item added',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to add fish item: $e';
      Get.snackbar(
        'Error',
        'Failed to add fish item',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('❌ Add fish item error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update fish item
  /// @param fishItem - FishItem dengan data terupdate
  Future<bool> updateFishItem(FishItem fishItem) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final updatedItem = await _service.updateFishItem(fishItem);

      // Update di list
      final index = fishItems.indexWhere((item) => item.id == fishItem.id);
      if (index != -1) {
        fishItems[index] = updatedItem;
      }

      _filterItems();

      Get.snackbar(
        'Success',
        'Fish item updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to update fish item: $e';
      Get.snackbar(
        'Error',
        'Failed to update fish item',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('❌ Update fish item error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete fish item
  /// @param itemId - ID dari fish item
  Future<bool> deleteFishItem(String itemId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _service.deleteFishItem(itemId);

      fishItems.removeWhere((item) => item.id == itemId);
      _filterItems();

      Get.snackbar(
        'Success',
        'Fish item deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to delete fish item: $e';
      Get.snackbar(
        'Error',
        'Failed to delete fish item',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('❌ Delete fish item error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Search fish items
  /// @param query - Search query (nama atau jenis ikan)
  Future<void> searchFishItems(String query) async {
    try {
      searchQuery.value = query;

      if (query.isEmpty) {
        _filterItems();
        return;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final userId = _authController.userId;
      if (userId == null) return;

      final results = await _service.searchFishItems(query, userId);
      filteredItems.assignAll(results);

      debugPrint('✅ Found ${results.length} items matching "$query"');
    } catch (e) {
      errorMessage.value = 'Failed to search fish items: $e';
      debugPrint('❌ Search fish items error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get fish item by ID
  /// @param itemId - ID dari fish item
  Future<FishItem?> getFishItemById(String itemId) async {
    try {
      return await _service.getFishItemById(itemId);
    } catch (e) {
      debugPrint('❌ Get fish item error: $e');
      return null;
    }
  }

  /// Stream real-time fish items
  /// Returns: Stream<List<FishItem>>
  Stream<List<FishItem>> getFishItemsStream() {
    final userId = _authController.userId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _service.getFishItemsStream(userId);
  }

  /// Refresh data dari Supabase
  Future<void> refreshFishItems() async {
    await loadFishItems();
  }

  /// Clear all data
  void clearFishItems() {
    fishItems.clear();
    filteredItems.clear();
    searchQuery.value = '';
    errorMessage.value = '';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE METHODS
  // ─────────────────────────────────────────────────────────────────────────

  /// Filter items berdasarkan search query
  void _filterItems() {
    if (searchQuery.value.isEmpty) {
      filteredItems.assignAll(fishItems);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredItems.assignAll(
        fishItems.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.species.toLowerCase().contains(query) ||
              (item.description?.toLowerCase().contains(query) ?? false);
        }).toList(),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get total count fish items
  int get totalFishItems => fishItems.length;

  /// Get total value (sum price * quantity)
  double get totalValue {
    return fishItems.fold(0, (sum, item) {
      return sum +
          ((item.price ?? 0) *
              (item.quantity ?? 0));
    });
  }

  /// Get items yang sedang ditampilkan (filtered or all)
  List<FishItem> get displayedItems =>
      searchQuery.value.isEmpty ? fishItems : filteredItems;
}
