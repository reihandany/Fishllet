# 📦 ORDERS PAGE - COMPREHENSIVE GUIDE

## 🎯 Overview
File `orders_page.dart` telah di-upgrade menjadi halaman riwayat pesanan yang lengkap dan professional dengan 7 fitur utama yang diminta.

---

## ✅ Fitur yang Sudah Diimplementasikan

### 1. **List Semua Pesanan** 📋
```dart
_buildOrdersList()
```
- ✅ Display semua order dari OrdersController
- ✅ Menggunakan sorted list (bisa di-sort)
- ✅ ListView.builder untuk efficient rendering
- ✅ Reactive dengan Obx() wrapper
- ✅ Data structure: orderId, orderDate, status, items, totalPrice, customerName, deliveryAddress, paymentMethod

### 2. **CircularProgressIndicator saat Loading** ⏳
```dart
_buildLoadingState()
```
- ✅ Full-screen loading indicator
- ✅ Loading message: "Loading orders..."
- ✅ Reactive dengan isLoading observable
- ✅ Ocean blue color (#2380c4)
- ✅ Triggered saat loadOrders() dipanggil

### 3. **Detail Order** 📝
```dart
_showOrderDetail(order)
```
- ✅ Bottom sheet dengan detail lengkap:
  - Order ID
  - Tanggal pemesanan (formatted: "27 Oct 2025, 14:30")
  - Status dengan warna & icon
  - Customer name
  - Delivery address
  - Payment method
  - List items dengan quantity & subtotal
  - Total price (formatted dengan separator)
- ✅ Action buttons (jika status = pending):
  - Cancel Order (red outlined button)
  - Process Order (blue elevated button)
- ✅ Scrollable untuk banyak items
- ✅ Close button di header

### 4. **Navigasi ke Detail Order** 🔀
```dart
InkWell onTap: () => _showOrderDetail(order)
TextButton "View Details"
```
- ✅ Tap pada card untuk buka detail
- ✅ "View Details" button di card
- ✅ Bottom sheet untuk detail (lebih baik dari full page)
- ✅ Smooth animation

### 5. **Filter/Sort Orders** 🔄
```dart
_showSortOptions()
```
- ✅ 4 opsi sorting:
  - **Newest First** (date_desc) - Default
  - **Oldest First** (date_asc)
  - **Highest Price** (price_desc)
  - **Lowest Price** (price_asc)
- ✅ Bottom sheet dengan list options
- ✅ Icon untuk tiap opsi (arrow_downward, arrow_upward, trending_up, trending_down)
- ✅ Visual feedback (check mark) untuk selected option
- ✅ Sort button di AppBar
- ✅ Reactive sorting dengan sortedOrders computed property

### 6. **Empty State** 🎨
```dart
_buildEmptyState()
```
- ✅ Icon besar (receipt_long_outlined)
- ✅ Title: "No Orders Yet"
- ✅ Description message
- ✅ "Start Shopping" button untuk navigate back
- ✅ Beautiful design dengan proper spacing
- ✅ Centered layout

### 7. **Pull-to-Refresh** 🔃
```dart
RefreshIndicator(onRefresh: () async {})
```
- ✅ RefreshIndicator wrapper di ListView
- ✅ Trigger loadOrders() saat pull down
- ✅ Ocean blue color
- ✅ Async/await pattern
- ✅ Loading state selama refresh

---

## 🎨 Design Features

### Order Card Design
```
┌─────────────────────────────────────┐
│ Order #ORD-xxx        [Status Badge]│
│                                     │
│ 📅 27 Oct 2025, 14:30               │
│ 🛍️ 3 items                          │
│ ─────────────────────────────────   │
│ Total:           Rp 1.500.000       │
│                      [View Details →]│
└─────────────────────────────────────┘
```

### Status Badges
- ✅ **Pending**: Orange dengan schedule icon
- ✅ **Processing**: Blue dengan autorenew icon
- ✅ **Shipped**: Purple dengan local_shipping icon
- ✅ **Delivered**: Green dengan check_circle icon
- ✅ **Cancelled**: Red dengan cancel icon
- ✅ Rounded border dengan background color opacity
- ✅ Status text dengan matching color

### Bottom Sheet Detail
```
┌─────────────────────────────────────┐
│ Order #ORD-xxx                   ✕  │
│ ─────────────────────────────────   │
│ 📅 Date:      27 Oct 2025, 14:30    │
│ ℹ️ Status:    Processing            │
│ 👤 Customer:  John Doe              │
│ 📍 Address:   123 Main St...        │
│ 💳 Payment:   Credit Card           │
│                                     │
│ Items                               │
│ - Product A × 2     Rp 500.000      │
│ - Product B × 1     Rp 1.000.000    │
│ ─────────────────────────────────   │
│ Total Amount       Rp 1.500.000     │
│                                     │
│ [Cancel]          [Process Order]   │
└─────────────────────────────────────┘
```

---

## 🏗️ Struktur UI

```
OrdersPage
├── AppBar
│   ├── Title: "Order History"
│   ├── Subtitle: "X orders"
│   └── Sort Button
│
├── Body (Obx)
│   ├── Loading State (if isLoading)
│   │   ├── CircularProgressIndicator
│   │   └── "Loading orders..."
│   │
│   ├── Empty State (if orders.isEmpty)
│   │   ├── Icon
│   │   ├── Title & Message
│   │   └── "Start Shopping" Button
│   │
│   └── Orders List (if orders.isNotEmpty)
│       └── RefreshIndicator
│           └── ListView.builder
│               └── Order Cards
│
├── Sort Bottom Sheet
│   └── 4 Sort Options
│
└── Detail Bottom Sheet
    ├── Header (Order ID + Close)
    ├── Order Info (6 fields)
    ├── Items List
    ├── Total Price
    └── Action Buttons (if pending)
```

---

## 🔗 Controller Integration

### OrdersController
```dart
final OrdersController ordersController = Get.find<OrdersController>();
```

**Properties:**
- `orders`: Observable list of all orders
- `isLoading`: Loading state
- `sortBy`: Current sort method
- `sortedOrders`: Computed sorted list
- `totalOrders`: Total count
- `totalRevenue`: Sum of all orders

**Methods:**
- `loadOrders()`: Fetch orders from API/local
- `addOrder(order)`: Add new order
- `changeSortBy(newSort)`: Change sorting
- `updateOrderStatus(orderId, status)`: Update status
- `cancelOrder(orderId)`: Cancel order
- `deleteOrder(orderId)`: Delete order

---

## 📊 Data Structure

### Order Object
```dart
{
  'orderId': 'ORD-1698417234567',
  'orderDate': DateTime(2025, 10, 27, 14, 30),
  'status': 'Pending', // Pending, Processing, Shipped, Delivered, Cancelled
  'customerName': 'John Doe',
  'deliveryAddress': '123 Main Street, City',
  'paymentMethod': 'Credit Card',
  'totalPrice': 1500000.0,
  'items': [
    {
      'name': 'Product A',
      'quantity': 2,
      'price': 250000.0,
      'imageUrl': 'https://...'
    },
    {
      'name': 'Product B',
      'quantity': 1,
      'price': 1000000.0,
      'imageUrl': 'https://...'
    }
  ]
}
```

---

## 🎯 Helper Methods

### Date Formatting
```dart
String _formatDate(DateTime date)
// Output: "27 Oct 2025, 14:30"
```

### Price Formatting
```dart
String _formatPrice(double price)
// Output: "Rp 1.500.000"
// Menggunakan regex untuk separator ribuan
```

### Status Styling
```dart
Color _getStatusColor(String status)
IconData _getStatusIcon(String status)
```

---

## 📱 User Flow

1. **User buka Orders Page**
2. **Loading state** muncul (1 detik)
3. **Data loaded**:
   - Jika kosong: Empty state + "Start Shopping" button
   - Jika ada: List of order cards
4. **User lihat list orders** (sorted by newest first)
5. **User tap sort button** di AppBar
6. **Sort options bottom sheet** muncul
7. **User pilih sort option** (e.g., Highest Price)
8. **List di-sort ulang** secara reactive
9. **User tap order card** atau "View Details"
10. **Detail bottom sheet** muncul
11. **User lihat detail lengkap** (date, status, items, total)
12. **User bisa**:
    - Cancel order (jika pending)
    - Process order (jika pending)
    - Close detail
13. **User pull down** untuk refresh
14. **Data di-reload** dari server

---

## ⚡ Key Features

### Reactive State Management
- Semua data menggunakan `Obx()` wrapper
- Auto-update saat orders berubah
- No manual setState()

### Date Formatting
- Package: `intl` (installed)
- Format: "dd MMM yyyy, HH:mm"
- Readable & localized

### Price Formatting
- Separator ribuan dengan regex
- Format: "Rp 1.500.000"
- Consistent di semua tempat

### Status Management
- Color-coded badges
- Icon per status
- Visual feedback

### Bottom Sheet Navigation
- Better UX daripada full page
- Smooth animation
- Scrollable content
- Close on swipe down

### Pull-to-Refresh
- Standard gesture
- Loading feedback
- Async operation

---

## 🔧 Technical Implementation

### Reactive List Rendering
```dart
Obx(() {
  final orders = ordersController.sortedOrders;
  return ListView.builder(...);
})
```

### Date Formatting with intl
```dart
import 'package:intl/intl.dart';

DateFormat('dd MMM yyyy, HH:mm').format(date);
```

### Price Formatting with Regex
```dart
price.toStringAsFixed(0).replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (Match m) => '${m[1]}.',
)
```

### Bottom Sheet Pattern
```dart
Get.bottomSheet(
  Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: ...
  ),
  isScrollControlled: true,
)
```

### RefreshIndicator Pattern
```dart
RefreshIndicator(
  onRefresh: () async {
    await ordersController.loadOrders();
  },
  child: ListView.builder(...),
)
```

---

## 🧪 Testing Checklist

- [ ] Empty state displays correctly (no orders)
- [ ] Loading state shows during data fetch
- [ ] Order cards render with correct data
- [ ] Status badges show correct color & icon
- [ ] Date formatting correct
- [ ] Price formatting correct (separator)
- [ ] Sort button opens bottom sheet
- [ ] All 4 sort options work
- [ ] Sort selection visual feedback works
- [ ] Tap card opens detail bottom sheet
- [ ] "View Details" button works
- [ ] Detail shows all order info
- [ ] Items list renders correctly
- [ ] Cancel button works (pending orders)
- [ ] Process button works (pending orders)
- [ ] Pull-to-refresh works
- [ ] Refresh shows loading state
- [ ] AppBar shows correct order count
- [ ] Back button works

---

## 📚 Dependencies

- `get`: ^4.6.6 - State management & navigation
- `intl`: ^0.20.2 - Date formatting (NEW)
- `OrdersController`: Order data & business logic

---

## 🎯 Next Steps

✅ **Task 6 COMPLETED**: Orders Page dengan 7 fitur lengkap

**Selanjutnya**:
- [ ] Task 7: Polish navigation flow (back button, route history)
- [ ] Task 8: Add CircularProgressIndicator di pages lain (Product list, etc.)
- [ ] Extra: Integrate dengan real API (jika ada)
- [ ] Extra: Add filters (status filter, date range)

---

## 💡 Tips

1. **Testing Empty State**: Jangan buat order dulu, langsung buka Orders Page
2. **Testing Loading**: Perhatikan loading saat pertama kali buka page
3. **Testing Sort**: Buat beberapa order dengan harga berbeda, test sorting
4. **Testing Detail**: Tap card & tap "View Details" button
5. **Testing Status**: Order status akan berubah saat di-process/cancel
6. **Testing Refresh**: Pull down list untuk reload data
7. **Testing Actions**: Cancel/Process button hanya muncul jika status = Pending

---

## ✨ Best Practices Applied

✅ Separation of concerns (UI & Logic)  
✅ Reactive programming dengan Obx()  
✅ Loading states untuk async operations  
✅ Empty state untuk better UX  
✅ Bottom sheet untuk detail (better than full page)  
✅ Pull-to-refresh untuk data update  
✅ Status color coding untuk visual feedback  
✅ Price & date formatting untuk readability  
✅ Sort functionality untuk user control  
✅ Proper error handling  
✅ Clean navigation flow  
✅ Consistent design system  
✅ Performance optimization (ListView.builder)

---

## 🎨 Design Details

### Color Scheme
- **Primary**: `#2380c4` (Ocean Blue)
- **Pending**: Orange
- **Processing**: Blue
- **Shipped**: Purple
- **Delivered**: Green
- **Cancelled**: Red
- **Background**: White
- **Text**: Black / Grey

### Typography
- **AppBar Title**: 20px, w600
- **AppBar Subtitle**: 12px, w400
- **Order ID**: 16px, Bold, Primary
- **Status**: 12px, w600
- **Total Price**: 18px, Bold, Primary
- **Body Text**: 13-15px

### Spacing
- Card margin: 16px
- Card padding: 16px
- Section gap: 12px
- Divider gap: 12px

### Border Radius
- Cards: 12px
- Bottom sheet: 20px (top only)
- Status badge: 20px
- Buttons: 12px

---

**🎉 Orders Page is now COMPLETE with all 7 features!**

**Total Progress: 6/8 Tasks Completed!** 🚀
