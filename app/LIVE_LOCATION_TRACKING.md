# 📍 Live Location Tracking - Fishllet App

## ✅ Fitur Live Location Tracking dengan Flutter Map (OpenStreetMap)

### 🎯 Fitur yang Diimplementasikan:

#### 1. **🗺️ Flutter Map Integration (OpenStreetMap)**
- **NO API KEY REQUIRED!** - 100% Gratis selamanya
- **Real-time Map Display**: Menampilkan peta dengan OpenStreetMap tiles
- **Custom Markers**: 
  - 🏠 **Home Icon (Green)** - Alamat pengiriman (user)
  - 🚚 **Delivery Icon (Blue)** - Posisi kurir
- **Route Visualization**: Dotted polyline menghubungkan kurir dan tujuan
- **Interactive Map**: Zoom, pan, dan gestures support

#### 2. **📡 Real-time Location Updates**
- **Periodic Updates**: Update posisi kurir setiap 5 detik
- **Live Movement**: Kurir bergerak menuju alamat pengiriman
- **Auto Refresh**: Location tracking otomatis update

#### 3. **📊 Distance & ETA Calculation**
- **Distance Calculator**: 
  - Menggunakan Haversine Formula
  - Akurat menghitung jarak antar koordinat
  - Ditampilkan dalam kilometer (2 desimal)
- **ETA Calculator**:
  - Estimated Time of Arrival
  - Berdasarkan jarak dan kecepatan rata-rata (30 km/h)
  - Ditampilkan dalam format jam & menit

#### 4. **🎨 Beautiful UI Design**
- **Info Cards di Bottom Sheet**:
  - 📍 Distance Card (gradient biru)
  - ⏰ ETA Card (gradient orange)
  - 🚚 Status Card dengan "LIVE" indicator
- **Map Controls**:
  - Fit Bounds button
  - Center on Courier button
  - Center on User button
- **Responsive Layout**: Safe area untuk notch devices

#### 5. **🔐 Location Permissions**
- **Android Permissions**:
  - `ACCESS_FINE_LOCATION`
  - `ACCESS_COARSE_LOCATION`
  - `ACCESS_BACKGROUND_LOCATION`
- **Runtime Permission Handling**
- **Permission Denied Handling** dengan user-friendly messages

---

## 📁 Files Created/Modified:

### **Created Files**:
1. **`lib/controllers/location_controller.dart`**
   - GPS tracking logic
   - Distance & ETA calculations
   - Map markers & polylines management
   - Periodic location updates
   - Camera controls

2. **`lib/views/location_tracking_page.dart`**
   - Google Maps display
   - Live tracking UI
   - Info cards
   - Map controls

### **Modified Files**:
1. **`lib/views/my_orders_page.dart`**
   - Added "Track Live Location" button for **pending** orders
   - Integration dengan LocationTrackingPage
   - Visual indicator untuk pending status

2. **`pubspec.yaml`**
   - Added dependencies:
     - `flutter_map: ^6.1.0` (OpenStreetMap)
     - `latlong2: ^0.9.0` (Coordinates)
     - `geolocator: ^10.1.0` (GPS)
     - `geocoding: ^2.1.1` (Address conversion)

3. **`android/app/src/main/AndroidManifest.xml`**
   - Added location permissions
   - **NO Google Maps API key needed!**

---

## 🚀 Cara Menggunakan:

### 1. **Langsung Run - Tidak Perlu Setup Apapun!**

**Flutter Map menggunakan OpenStreetMap yang 100% GRATIS!**

Tidak perlu:
- ❌ Google Maps API Key
- ❌ Setup Cloud Console
- ❌ Billing Account
- ❌ Payment Method

Langsung jalankan:
```powershell
flutter run
```

### 2. **Test Live Tracking**

1. Jalankan aplikasi: `flutter run`
2. Login dan buat order
3. Di **MyOrdersPage**, lihat order dengan status **"Pending"**
4. Tap button **"Track Live Location"** 
5. Map akan terbuka menampilkan:
   - Posisi kurir (marker biru)
   - Alamat pengiriman (marker hijau)
   - Jarak dan ETA
   - Live indicator

### 3. **Simulasi Kurir Bergerak**

Kurir akan otomatis bergerak menuju alamat pengiriman:
- Update setiap 5 detik
- Distance berkurang
- ETA berkurang
- Polyline terupdate

---

## 🎯 Fitur Detail:

### **LocationController Methods**:

```dart
// Start tracking
startTracking(String orderId, LatLng deliveryAddress)

// Stop tracking
stopTracking()

// Get user location
_getUserLocation()

// Calculate distance (Haversine formula)
_calculateDistance(lat1, lon1, lat2, lon2)

// Map camera controls
fitMapBounds()
centerOnCourier()
centerOnUser()
```

### **Distance Calculation**:
- Menggunakan **Haversine Formula**
- Akurat untuk jarak jauh
- Return dalam kilometer

### **ETA Calculation**:
```dart
ETA (minutes) = (distance / average_speed) * 60
Average speed = 30 km/h (courier)
```

---

## 📊 UI Components:

### **Info Cards**:
1. **Distance Card** (Gradient Biru)
   - Icon: Location Pin
   - Value: X.XX km
   - Real-time update

2. **ETA Card** (Gradient Orange)
   - Icon: Clock
   - Value: Xh Ym atau Ym
   - Real-time calculation

3. **Status Card** (Green Border)
   - Icon: Delivery bike
   - Text: "Kurir sedang dalam perjalanan"
   - **LIVE** badge (red)

### **Map Controls** (FAB):
1. **Fit Bounds** - Zoom untuk lihat kedua marker
2. **Center on Courier** - Focus ke kurir
3. **Center on User** - Focus ke alamat pengiriman

---

## 🔧 Technical Implementation:

### **Haversine Formula**:
```dart
double _calculateDistance(lat1, lon1, lat2, lon2) {
  const earthRadius = 6371; // km
  
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  
  final a = (sin(dLat / 2) * sin(dLat / 2)) +
      (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
       sin(dLon / 2) * sin(dLon / 2));
  
  final c = 2 * asin(sqrt(a));
  
  return earthRadius * c;
}
```

### **Courier Movement Simulation**:
```dart
void _moveCourierTowardsUser() {
  // Calculate direction
  final latDiff = user.latitude - courier.latitude;
  final lngDiff = user.longitude - courier.longitude;
  
  // Move ~11 meters per update
  const moveStep = 0.0001;
  
  courierLocation.value = LatLng(
    courier.latitude + (latDiff > 0 ? moveStep : -moveStep),
    courier.longitude + (lngDiff > 0 ? moveStep : -moveStep),
  );
}
```

---

## ⚠️ Important Notes:

### **OpenStreetMap - Gratis Selamanya!**:
- ✅ **Tidak perlu API key**
- ✅ **Tidak ada quota limit**
- ✅ **Tidak ada billing**
- ✅ **Open source & free forever**
- ✅ **Community driven**

### **Tile Server**:
- Default: `https://tile.openstreetmap.org`
- Alternative tiles tersedia (Mapbox, Stadia Maps, dll)
- Bisa custom tile server sendiri

### **Location Permissions**:
- Pastikan user memberikan permission
- Test di real device (tidak sempurna di emulator)
- Background location untuk tracking saat app di background

### **Simulation Mode**:
- Saat ini menggunakan **simulated courier location**
- Untuk production: integrate dengan backend API
- Backend mengirim real courier GPS coordinates

---

## 🎓 Integration dengan Backend (Future):

Untuk real tracking, Anda perlu:

1. **Backend API** yang mengirim courier location
2. **WebSocket** atau **Firebase Realtime Database** untuk real-time updates
3. **Courier Mobile App** yang mengirim GPS coordinates

Contoh flow:
```
Courier App → Backend API → Your App
   (GPS)     (Save to DB)    (Display)
```

---

## 🆚 Flutter Map vs Google Maps:

| Feature | Flutter Map | Google Maps |
|---------|-------------|-------------|
| **API Key** | ❌ Tidak perlu | ✅ Wajib |
| **Biaya** | 🆓 Gratis | 💰 Berbayar (setelah quota) |
| **Setup** | ⚡ Instant | 🐌 Ribet (Cloud Console) |
| **Quota** | ♾️ Unlimited | ⚠️ 28,500/month |
| **Tiles** | 🗺️ OpenStreetMap | 🗺️ Google |
| **Customization** | ✨ Sangat fleksibel | 🔒 Terbatas |
| **Offline** | ✅ Bisa | ⚠️ Kompleks |
| **Performance** | ⚡ Ringan | 🐘 Lebih berat |

---

## 📱 User Flow:

1. User membuat order
2. Order dimulai dengan status **"Pending"**
3. User buka **Pesanan Saya**
4. Tap **"Track Live Location"** (hanya muncul di status Pending)
5. Map terbuka dengan live tracking
6. User bisa lihat:
   - Posisi kurir real-time
   - Jarak yang tersisa
   - Estimasi waktu tiba
7. Auto-update setiap 5 detik

---

## ✨ Features Summary:

✅ Flutter Map integration (OpenStreetMap)
✅ **NO API KEY REQUIRED!**
✅ Real-time courier tracking
✅ Distance calculation (Haversine)
✅ ETA calculation
✅ Beautiful UI dengan gradient cards
✅ Map controls (zoom, center)
✅ Live indicator
✅ Permission handling
✅ Auto-refresh every 5 seconds
✅ Smooth animations
✅ Responsive design
✅ **100% Gratis selamanya**

---

**Version**: 1.3.0 (with Flutter Map - OpenStreetMap)
**Last Updated**: November 30, 2025
**Developer**: Fishllet Team 🐟🗺️

**Maps Provider**: OpenStreetMap (Free & Open Source)
