// lib/controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_services.dart';

// Sesuai modul, controller dipisah dari view
class ProductController extends GetxController {
  final ApiService apiService;
  ProductController({required this.apiService});

  // --- States untuk Data Produk ---
  var products = <Product>[].obs;
  var isLoading = false.obs;

  // --- States untuk Hasil Eksperimen 1 (HTTP vs Dio)  ---
  var httpResponseTime = 0.obs;
  var dioResponseTime = 0.obs;
  var httpError = ''.obs;
  var dioError = ''.obs;

  // --- States untuk Hasil Eksperimen 2 (Async Handling)  ---
  var asyncAwaitResult = ''.obs;
  var callbackChainResult = ''.obs;
  var asyncError = ''.obs;
  var callbackError = ''.obs;

  final stopwatch = Stopwatch(); // 

  // --- EKSPERIMEN 1: Uji Performa http ---
  Future<void> runHttpTest() async {
    isLoading.value = true;
    httpError.value = '';
    httpResponseTime.value = 0;
    stopwatch.reset();
    stopwatch.start();

    try {
      final result = await apiService.fetchProductsWithHttp();
      products.value = result;
    } catch (e) {
      httpError.value = e.toString();
      products.clear();
    } finally {
      stopwatch.stop();
      httpResponseTime.value = stopwatch.elapsedMilliseconds;
      isLoading.value = false;
    }
  }

  // --- EKSPERIMEN 1: Uji Performa Dio ---
  Future<void> runDioTest() async {
    isLoading.value = true;
    dioError.value = '';
    dioResponseTime.value = 0;
    stopwatch.reset();
    stopwatch.start();

    try {
      final result = await apiService.fetchProductsWithDio();
      products.value = result;
    } catch (e) {
      // DioException akan ditangkap di sini 
      dioError.value = e.toString();
      products.clear();
    } finally {
      stopwatch.stop();
      dioResponseTime.value = stopwatch.elapsedMilliseconds;
      isLoading.value = false;
    }
  }

  // --- EKSPERIMEN 2: Uji Chained Request via async-await ---
  //  Struktur kode linear dan mudah dipahami
  Future<void> runAsyncAwaitChain() async {
    isLoading.value = true;
    asyncError.value = '';
    asyncAwaitResult.value = 'Menjalankan...';

    try {
      // 1. Ambil list produk
      List<Product> productList = await apiService.fetchProductsWithDio();

      if (productList.isNotEmpty) {
        String firstProductId = productList.first.id;
        // 2. Ambil detail produk pertama (chained request) 
        Product detailProduct = await apiService.fetchProductDetail(firstProductId);
        asyncAwaitResult.value =
            'Deskripsi ${detailProduct.name}:\n${detailProduct.description?.substring(0, 100)}...';
      }
    } catch (e) {
      asyncError.value = e.toString();
      asyncAwaitResult.value = 'Gagal';
    } finally {
      isLoading.value = false;
    }
  }

  // --- EKSPERIMEN 2: Uji Chained Request via callback chaining ---
  //  Menggunakan fungsi bersarang (nested)
  void runCallbackChain() {
    isLoading.value = true;
    callbackError.value = '';
    callbackChainResult.value = 'Menjalankan...';

    apiService.fetchProductsWithDio().then((productList) {
      if (productList.isNotEmpty) {
        String firstProductId = productList.first.id;
        // 2. Ambil detail produk (nested call) 
        apiService.fetchProductDetail(firstProductId).then((detailProduct) {
          callbackChainResult.value =
              'Deskripsi ${detailProduct.name}:\n${detailProduct.description?.substring(0, 100)}...';
          isLoading.value = false;
        }).catchError((e) {
          // Inner catch
          callbackError.value = e.toString();
          callbackChainResult.value = 'Gagal (Inner)';
          isLoading.value = false;
        });
      }
    }).catchError((e) {
      // Outer catch
      callbackError.value = e.toString();
      callbackChainResult.value = 'Gagal (Outer)';
      isLoading.value = false;
    });
  }
}