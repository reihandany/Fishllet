# 🧪 QUICK PERFORMANCE TEST GUIDE

## Langkah Cepat untuk Testing Performance

### 1️⃣ Setup Performance Monitoring (5 menit)

#### A. Tambahkan Logging di Controllers

**Edit `app/lib/controllers/product_controller.dart`:**

Tambahkan di bagian atas:
```dart
import '../utils/performance_utils.dart';
```

Update method `fetchProducts()`:
```dart
Future<void> fetchProducts() async {
  try {
    isLoading.value = true;
    
    // ✅ Measure performance
    final products = await PerformanceUtils.measureAsync(
      'ProductController.fetchProducts',
      () async {
        await Future.delayed(const Duration(seconds: 2));
        return await _productService.getProducts();
      },
    );
    
    this.products.value = products;
    
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to load products: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}
```

Tambahkan lifecycle logging:
```dart
@override
void onInit() {
  super.onInit();
  print('🟢 [ProductController] Initialized');
  fetchProducts();
}

@override
void onClose() {
  print('🔴 [ProductController] Disposed');
  super.onClose();
}
```

#### B. Tambahkan di OrdersController

**Edit `app/lib/controllers/orders_controller.dart`:**

```dart
import '../utils/performance_utils.dart';

// Update loadOrders method
Future<void> loadOrders() async {
  try {
    isLoading.value = true;
    
    final fetchedOrders = await PerformanceUtils.measureAsync(
      'OrdersController.loadOrders',
      () async {
        await Future.delayed(const Duration(seconds: 1));
        return await _orderService.getOrders();
      },
    );
    
    orders.value = fetchedOrders;
    
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to load orders: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

@override
void onInit() {
  super.onInit();
  print('🟢 [OrdersController] Initialized');
  loadOrders();
}

@override
void onClose() {
  print('🔴 [OrdersController] Disposed');
  super.onClose();
}
```

#### C. Tambahkan Navigation Timing

**Edit `app/lib/views/product_list_page.dart`:**

```dart
import '../utils/performance_utils.dart';

// Update navigation methods
void openCart() {
  PerformanceUtils.startTimer('Navigation: ProductList → Cart');
  
  Get.to(
    () => CartPage(),
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: 300),
  )?.then((_) {
    PerformanceUtils.stopTimer('Navigation: ProductList → Cart');
  });
}

void openOrders() {
  PerformanceUtils.startTimer('Navigation: ProductList → Orders');
  
  Get.to(
    () => OrdersPage(),
    transition: Transition.downToUp,
    duration: const Duration(milliseconds: 350),
  )?.then((_) {
    PerformanceUtils.stopTimer('Navigation: ProductList → Orders');
  });
}

void openDetail(Product productData) {
  PerformanceUtils.startTimer('Navigation: ProductList → Detail');
  
  Get.to(
    () => ProductDetailPage(product: productData),
    transition: Transition.fade,
    duration: const Duration(milliseconds: 250),
  )?.then((_) {
    PerformanceUtils.stopTimer('Navigation: ProductList → Detail');
  });
}
```

---

### 2️⃣ Run Testing (10 menit)

#### A. Clean Build & Run
```bash
# Terminal
flutter clean
flutter pub get
flutter run
```

#### B. Test Flow & Catat Console Output

**Test Sequence:**
1. App launch → Login
2. Login → ProductList (watch for "Fetch Products" timing)
3. ProductList → Cart (watch navigation timing)
4. Cart → Back
5. ProductList → Orders (watch "Load Orders" timing)
6. Orders → Back
7. ProductList → ProductDetail
8. Detail → Back

**Expected Console Output:**
```
🟢 [AuthController] Initialized
🟢 [ProductController] Initialized
⏱️  [ProductController.fetchProducts] Starting...
✅ [ProductController.fetchProducts] Completed in 2015ms (Acceptable)
🟢 [CartController] Initialized
⏱️  [Navigation: ProductList → Cart] Timer started
⏹️  [Navigation: ProductList → Cart] Timer stopped: 305ms
⏱️  [Navigation: ProductList → Orders] Timer started
🟢 [OrdersController] Initialized
⏱️  [OrdersController.loadOrders] Starting...
✅ [OrdersController.loadOrders] Completed in 1008ms (Fast)
⏹️  [Navigation: ProductList → Orders] Timer stopped: 352ms
```

---

### 3️⃣ Analyze Results (5 menit)

#### A. Fill This Table

| Operation | Time (ms) | Status |
|-----------|-----------|--------|
| App Launch | ? | ⏳ |
| fetchProducts | ? | ⏳ |
| loadOrders | ? | ⏳ |
| Nav: ProductList → Cart | ? | ⏳ |
| Nav: ProductList → Orders | ? | ⏳ |
| Nav: ProductList → Detail | ? | ⏳ |

**Status Guide:**
- ✅ < 300ms (navigation) or < 2000ms (data loading)
- ⚠️ 300-500ms (navigation) or 2000-3000ms (data loading)
- ❌ > 500ms (navigation) or > 3000ms (data loading)

#### B. Check for Issues

**Look for these in console:**
- ❌ Red "Failed" messages → Error tidak handled
- ❌ Times > 3000ms → Too slow
- ❌ Missing controller lifecycle logs → Memory leak?
- ❌ Navigation > 500ms → Jank/lag

---

### 4️⃣ Quick DevTools Check (5 menit)

#### Open DevTools
```bash
# Terminal kedua
flutter pub global activate devtools
flutter pub global run devtools
```

1. Open browser (http://127.0.0.1:9100)
2. Connect to running app
3. Go to **Performance** tab
4. Click **Record**
5. Navigate through app
6. Click **Stop**
7. Check for red bars (janky frames)

**Pass Criteria:**
- ✅ Most frames < 16ms
- ✅ Few or no red bars
- ✅ Smooth graph

#### Memory Check
1. Go to **Memory** tab
2. Click **Snapshot**
3. Navigate through all pages
4. Return to home
5. Click **Snapshot** again
6. Compare sizes

**Pass Criteria:**
- ✅ Memory < 150MB
- ✅ Increase < 50MB after full navigation

---

### 5️⃣ Final Checklist

Quick verification:

- [ ] ✅ All controllers show "🟢 Initialized" log
- [ ] ✅ All async operations show timing logs
- [ ] ✅ All timings < 3 seconds
- [ ] ✅ Navigation < 500ms
- [ ] ✅ No errors in console
- [ ] ✅ DevTools shows green frames
- [ ] ✅ Memory usage reasonable
- [ ] ✅ App feels smooth

---

## 📊 Report Template

**Copy this and fill in your results:**

```markdown
# Fishllet Performance Test Results

**Date:** [Today's Date]
**Tester:** [Your Name]
**Device:** [Phone/Emulator Name]

## Timing Results

### Data Loading
- Product List Load: ____ms ✅/⚠️/❌
- Orders List Load: ____ms ✅/⚠️/❌

### Navigation
- ProductList → Cart: ____ms ✅/⚠️/❌
- ProductList → Orders: ____ms ✅/⚠️/❌
- ProductList → Detail: ____ms ✅/⚠️/❌

### DevTools Analysis
- Average Frame Time: ____ms
- Janky Frames: ____
- Memory Usage: ____MB
- Memory After Navigation: ____MB

## Issues Found
1. 
2. 
3. 

## Recommendations
1. 
2. 
3. 

## Overall Assessment
- Performance Grade: ____/10
- Ready for Demo: Yes/No
- Needs Optimization: Yes/No
```

---

## 🎯 Common Issues & Solutions

### Issue: "fetchProducts takes > 3 seconds"
**Solution:**
```dart
// Add timeout
Future<void> fetchProducts() async {
  try {
    isLoading.value = true;
    
    final products = await _productService.getProducts()
      .timeout(const Duration(seconds: 5));
    
    this.products.value = products;
  } catch (e) {
    // Handle error
  } finally {
    isLoading.value = false;
  }
}
```

### Issue: "Navigation feels janky"
**Solution:**
```dart
// Reduce transition duration
Get.to(
  () => CartPage(),
  transition: Transition.fade,  // Try different transition
  duration: const Duration(milliseconds: 200),  // Faster
);
```

### Issue: "Memory increasing"
**Solution:**
```dart
// Add proper cleanup in controllers
@override
void onClose() {
  products.clear();
  cart.clear();
  orders.clear();
  super.onClose();
}
```

### Issue: "Controller not disposed"
**Expected Behavior:**
```
With fenix: true in AppBindings, controllers WON'T dispose immediately.
This is NORMAL and actually GOOD for performance.
They'll be recreated when needed.
```

---

## 💡 Pro Tips

1. **Always test in Release mode for real performance:**
   ```bash
   flutter run --release
   ```

2. **Use Profile mode for DevTools:**
   ```bash
   flutter run --profile
   ```

3. **Test on real device, not just emulator**

4. **Test with slow network simulation**

5. **Test with many items (50+ products, 20+ orders)**

---

## ✅ Done!

Setelah complete quick test ini, Anda akan punya:
- ✅ Clear understanding of app performance
- ✅ Timing data untuk semua operations
- ✅ DevTools metrics
- ✅ List of issues (if any)
- ✅ Confidence untuk demo

**Total Time: ~25 minutes**

Good luck! 🚀
