# 📱 Supabase Integration - Dokumentasi Lengkap

Panduan lengkap untuk implementasi Supabase di aplikasi Fishllet, meliputi autentikasi, database management, file storage, dan real-time synchronization.

---

## 📋 Daftar Isi

1. [Setup Awal](#setup-awal)
2. [1. Supabase Auth (Login/Register)](#1-supabase-auth-loginregister)
3. [2. Menyimpan Data Fish Items](#2-menyimpan-data-fish-items)
4. [3. Upload Foto ke Storage](#3-upload-foto-ke-storage)
5. [4. Real-time Synchronization](#4-real-time-synchronization)
6. [API Reference](#api-reference)
7. [Troubleshooting](#troubleshooting)

---

## 🚀 Setup Awal

### 1. Install Dependencies

Tambahkan paket Supabase ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5
  http: ^0.13.5
  dio: ^5.0.0
  shared_preferences: ^2.1.2
  cupertino_icons: ^1.0.8
  intl: ^0.20.2
  # Supabase Integration
  supabase_flutter: ^2.11.0
  image_picker: ^1.1.1
  permission_handler: ^11.4.4
```

Kemudian jalankan:

```bash
flutter pub get
```

### 2. Setup Supabase Project

1. Buat akun di [supabase.com](https://supabase.com)
2. Buat project baru
3. Dapatkan credentials:
   - **Project URL** (SUPABASE_URL)
   - **Anon Key** (SUPABASE_ANON_KEY)

Credentials ada di: **Settings > API**

### 3. Konfigurasi di Aplikasi

Edit file `lib/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

### 4. Inisialisasi di main.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  // ... rest of setup code
  runApp(const MyApp());
}
```

### 5. Update AppBindings

Edit `lib/utils/app__bindings.dart`:

```dart
import '../config/supabase_config.dart';
import '../controllers/supabase_auth_controller.dart';
import '../controllers/supabase_fish_items_controller.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_fish_items_service.dart';
import '../services/supabase_storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // ... existing code ...
    
    // Supabase Services
    Get.lazyPut<SupabaseAuthService>(() => SupabaseAuthService(), fenix: true);
    Get.lazyPut<SupabaseFishItemsService>(() => SupabaseFishItemsService(), fenix: true);
    Get.lazyPut<SupabaseStorageService>(() => SupabaseStorageService(), fenix: true);
    
    // Supabase Controllers
    Get.put<SupabaseAuthController>(SupabaseAuthController(), permanent: true);
    Get.lazyPut<SupabaseFishItemsController>(() => SupabaseFishItemsController(), fenix: true);
  }
}
```

---

## 1️⃣ Supabase Auth (Login/Register)

### A. Konsep

Supabase menyediakan managed authentication dengan:
- Email + Password
- User metadata untuk data tambahan
- Session management otomatis
- Password reset functionality

### B. Database Schema

Supabase otomatis membuat tabel `auth.users` untuk user authentication. Untuk user profile tambahan, buat tabel:

```sql
-- Buat tabel di Supabase SQL Editor
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  phone TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users bisa read profile mereka sendiri
CREATE POLICY "Users can read own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users bisa update profile mereka sendiri
CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);
```

### C. Sign Up

```dart
// Di UI/Page
final authCtrl = Get.find<SupabaseAuthController>();

ElevatedButton(
  onPressed: () async {
    final success = await authCtrl.signUp(
      email: 'user@example.com',
      password: 'password123',
      fullName: 'John Doe',
    );
    
    if (success) {
      Get.to(() => VerifyEmailPage());
    }
  },
  child: const Text('Sign Up'),
)
```

**Service Implementation** (`SupabaseAuthService`):

```dart
Future<User?> signUp({
  required String email,
  required String password,
  Map<String, dynamic>? metadata,
}) async {
  final response = await _client.auth.signUp(
    email: email,
    password: password,
    data: metadata, // Disimpan di user metadata
  );
  
  return response.user;
}
```

### D. Login

```dart
final authCtrl = Get.find<SupabaseAuthController>();

ElevatedButton(
  onPressed: () async {
    final success = await authCtrl.login(
      email: 'user@example.com',
      password: 'password123',
    );
    
    if (success) {
      Get.offAll(() => ProductListPage());
    }
  },
  child: const Text('Login'),
)
```

**Service Implementation**:

```dart
Future<User?> login({
  required String email,
  required String password,
}) async {
  final response = await _client.auth.signInWithPassword(
    email: email,
    password: password,
  );
  
  return response.user;
}
```

### E. Logout

```dart
final authCtrl = Get.find<SupabaseAuthController>();

await authCtrl.logout();
// Session cleared, user redirected ke login page
```

### F. Get Current User

```dart
final authCtrl = Get.find<SupabaseAuthController>();

// Get user object
User? user = authCtrl.currentUser.value;

// Get user ID
String? userId = authCtrl.userId;

// Get user email
String? email = authCtrl.userEmail;

// Get user metadata
String? fullName = authCtrl.userFullName;

// Check authentication status
bool isAuthenticated = authCtrl.isAuthenticated.value;
```

### G. Listen Auth State Changes

```dart
final authCtrl = Get.find<SupabaseAuthController>();

// Automatically handled di controller
// Tapi bisa juga access langsung:
authCtrl.isAuthenticated.listen((isAuth) {
  if (isAuth) {
    Get.off(() => ProductListPage());
  } else {
    Get.off(() => LoginPage());
  }
});
```

### H. Password Reset

```dart
final authCtrl = Get.find<SupabaseAuthController>();

bool success = await authCtrl.resetPassword('user@example.com');
if (success) {
  // Email reset sent
}
```

---

## 2️⃣ Menyimpan Data Fish Items

### A. Database Schema

Buat tabel untuk menyimpan data ikan user:

```sql
CREATE TABLE public.fish_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  description TEXT,
  quantity DECIMAL(10,2),
  quantity_unit TEXT,
  price DECIMAL(12,2),
  photo_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT valid_name CHECK (name != ''),
  CONSTRAINT valid_species CHECK (species != '')
);

-- Enable RLS
ALTER TABLE public.fish_items ENABLE ROW LEVEL SECURITY;

-- Policy: Users hanya bisa see/edit item mereka sendiri
CREATE POLICY "Users can see own fish items"
  ON public.fish_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own fish items"
  ON public.fish_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own fish items"
  ON public.fish_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own fish items"
  ON public.fish_items FOR DELETE
  USING (auth.uid() = user_id);

-- Create index untuk performance
CREATE INDEX idx_fish_items_user_id ON public.fish_items(user_id);
CREATE INDEX idx_fish_items_created_at ON public.fish_items(created_at DESC);
```

### B. Model (FishItem)

```dart
class FishItem {
  final String? id;
  final String userId;
  final String name;
  final String species;
  final String? description;
  final double? quantity;
  final String? quantityUnit;
  final double? price;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;

  FishItem({
    this.id,
    required this.userId,
    required this.name,
    required this.species,
    // ... other fields
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'species': species,
      // ... other fields
    };
  }

  factory FishItem.fromJson(Map<String, dynamic> json) {
    return FishItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      // ... other fields
    );
  }
}
```

### C. CRUD Operations

#### INSERT (Create)

```dart
final fishCtrl = Get.find<SupabaseFishItemsController>();

final newItem = FishItem(
  userId: fishCtrl._authController.userId!,
  name: 'Koi Kohaku',
  species: 'Koi',
  quantity: 5,
  quantityUnit: 'ekor',
  price: 150000,
  description: 'Koi premium dari Japan',
);

bool success = await fishCtrl.addFishItem(newItem);
```

**Service Level**:

```dart
Future<FishItem> addFishItem(FishItem fishItem) async {
  final data = fishItem.toJson();
  data.remove('id');

  final response = await _client
      .from('fish_items')
      .insert([data])
      .select()
      .single();

  return FishItem.fromJson(response);
}
```

#### SELECT (Read)

```dart
// Get semua items
final fishCtrl = Get.find<SupabaseFishItemsController>();
await fishCtrl.loadFishItems();

print('Total items: ${fishCtrl.totalFishItems}');
print('Items: ${fishCtrl.fishItems}');

// Get item specific
FishItem? item = await fishCtrl.getFishItemById('item-id-123');
```

**Service Level**:

```dart
Future<List<FishItem>> getFishItemsByUser(String? userId) async {
  final uid = userId ?? SupabaseConfig.userId;
  
  final response = await _client
      .from('fish_items')
      .select()
      .eq('user_id', uid)
      .eq('is_active', true)
      .order('created_at', ascending: false);

  return (response as List)
      .map((e) => FishItem.fromJson(e))
      .toList();
}
```

#### UPDATE

```dart
final fishCtrl = Get.find<SupabaseFishItemsController>();

final updatedItem = existingItem.copyWith(
  name: 'Koi Kohaku Premium',
  quantity: 10,
  price: 200000,
);

bool success = await fishCtrl.updateFishItem(updatedItem);
```

**Service Level**:

```dart
Future<FishItem> updateFishItem(FishItem fishItem) async {
  final data = fishItem.toJson();
  data.remove('id');
  data.remove('user_id');
  data.remove('created_at');
  data['updated_at'] = DateTime.now().toIso8601String();

  final response = await _client
      .from('fish_items')
      .update(data)
      .eq('id', fishItem.id!)
      .select()
      .single();

  return FishItem.fromJson(response);
}
```

#### DELETE

```dart
final fishCtrl = Get.find<SupabaseFishItemsController>();

bool success = await fishCtrl.deleteFishItem('item-id-123');
// Soft delete (set is_active = false)
```

**Service Level**:

```dart
Future<void> deleteFishItem(String itemId) async {
  // Soft delete
  await _client
      .from('fish_items')
      .update({'is_active': false})
      .eq('id', itemId);
}

Future<void> hardDeleteFishItem(String itemId) async {
  // Hard delete (permanent)
  await _client
      .from('fish_items')
      .delete()
      .eq('id', itemId);
}
```

### D. Search

```dart
final fishCtrl = Get.find<SupabaseFishItemsController>();

// Search by name atau species
await fishCtrl.searchFishItems('Koi');

// Get filtered results
List<FishItem> results = fishCtrl.filteredItems;
```

### E. List UI Example

```dart
Obx(() {
  final fishCtrl = Get.find<SupabaseFishItemsController>();
  
  if (fishCtrl.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }

  final items = fishCtrl.displayedItems;

  if (items.isEmpty) {
    return Center(
      child: Text('No fish items'),
    );
  }

  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return FishItemCard(
        item: item,
        onEdit: () => editFishItem(item),
        onDelete: () => deleteFishItem(item.id!),
      );
    },
  );
})
```

---

## 3️⃣ Upload Foto ke Storage

### A. Storage Setup

1. Buat bucket di Supabase: **Storage > Buckets > New bucket**
2. Nama bucket: `fish-photos`
3. Set akses: **Public** (agar foto bisa diakses public)

### B. Security Policy

Setup RLS policy di storage:

```sql
-- Di Supabase SQL Editor, jalankan:
-- Policy untuk public read
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'fish-photos');

-- Policy untuk user upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'fish-photos'
  AND auth.role() = 'authenticated'
);

-- Policy untuk delete own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'fish-photos'
  AND owner = auth.uid()
);
```

### C. Upload Foto

```dart
import 'package:image_picker/image_picker.dart';

// Pick image
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  // Upload
  final storageCtrl = Get.find<SupabaseStorageService>();
  String publicUrl = await storageCtrl.uploadFishPhoto(
    image.path,
    fileName: 'fish_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );
  
  print('Uploaded: $publicUrl');
  
  // Simpan URL ke database
  final newItem = FishItem(
    userId: userId,
    name: 'My Fish',
    species: 'Koi',
    photoUrl: publicUrl, // ← Simpan URL
  );
  
  await fishCtrl.addFishItem(newItem);
}
```

**Service Implementation**:

```dart
Future<String> uploadFishPhoto(
  String filePath, {
  String? fileName,
}) async {
  final file = File(filePath);
  
  final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
  final path = 'fish-photos/${SupabaseConfig.userId}/$name';

  // Upload file
  await _client.storage
      .from(_bucketName)
      .upload(path, file);

  // Get public URL
  final publicUrl = _client.storage
      .from(_bucketName)
      .getPublicUrl(path);

  return publicUrl;
}
```

### D. Delete Foto

```dart
final storageCtrl = Get.find<SupabaseStorageService>();

// Hapus by URL
await storageCtrl.deleteFishPhotoByUrl(
  'https://project.supabase.co/storage/v1/object/public/fish-photos/...'
);

// Hapus dan fish item
bool success = await fishCtrl.deleteFishItem(itemId);
```

### E. Batch Upload

```dart
final storageCtrl = Get.find<SupabaseStorageService>();
final List<String> imagePaths = [/* ... */];

Map<String, String> results = await storageCtrl.uploadMultipleFishPhotos(imagePaths);

// results: { 'fish1.jpg': 'public_url_1', 'fish2.jpg': 'public_url_2' }
```

### F. Display Foto

```dart
Obx(() {
  final item = fishCtrl.currentItem.value;
  
  if (item?.photoUrl == null) {
    return PlaceholderImage();
  }

  return CachedNetworkImage(
    imageUrl: item!.photoUrl!,
    placeholder: (context, url) => ShimmerLoading(),
    errorWidget: (context, url, error) => ErrorImage(),
  );
})
```

---

## 4️⃣ Real-time Synchronization

### A. Konsep

Real-time sync memungkinkan data terupdate otomatis di semua device tanpa perlu refresh manual.

### B. Aktivasi Realtime

Di Supabase Dashboard:

1. Buka **Realtime** tab
2. Enable realtime untuk tabel `fish_items`
3. Pastikan RLS policies sudah setup

### C. Implementation

```dart
// Di controller
Stream<List<FishItem>> getFishItemsStream() {
  final userId = _authController.userId;
  if (userId == null) throw Exception('User not authenticated');

  return _service.getFishItemsStream(userId);
}

// Di service
Stream<List<FishItem>> getFishItemsStream(String userId) {
  return _client
      .from('fish_items')
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
```

### D. UI with Realtime

```dart
// Auto-update UI ketika data berubah di Supabase
StreamBuilder<List<FishItem>>(
  stream: fishCtrl.getFishItemsStream(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }

    final items = snapshot.data ?? [];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FishItemCard(item: items[index]);
      },
    );
  },
)
```

### E. Multi-device Sync Example

**Device A**: User update fish item quantity 5 → 10
```
| Time | Device A | Device B | Supabase |
|------|----------|----------|----------|
| T0   | qty: 5   | qty: 5   | qty: 5   |
| T1   | qty: 10  | qty: 5   | qty: 10  | (A send update)
| T2   | qty: 10  | qty: 10  | qty: 10  | (B receive via realtime)
```

### F. Conflict Resolution

Jika terjadi conflict (update dari 2 device bersamaan):

```dart
// Strategy 1: Last Write Wins (Default)
// Update terakhir yang disimpan

// Strategy 2: Custom conflict resolution
Future<void> syncWithConflictResolution() async {
  try {
    final localVersion = getLocalFishItem(itemId);
    final remoteVersion = await getFishItemById(itemId);

    if (localVersion.updatedAt.isBefore(remoteVersion.updatedAt)) {
      // Remote lebih baru, gunakan remote
      updateLocalFishItem(remoteVersion);
    } else {
      // Local lebih baru, push ke remote
      await updateFishItem(localVersion);
    }
  } catch (e) {
    // Handle conflict
    showConflictDialog();
  }
}
```

---

## API Reference

### SupabaseAuthService

```dart
// Sign up
Future<User?> signUp({
  required String email,
  required String password,
  Map<String, dynamic>? metadata,
})

// Login
Future<User?> login({
  required String email,
  required String password,
})

// Logout
Future<void> logout()

// Get current user
User? getCurrentUser()
String? getCurrentUserId()
String? getCurrentUserEmail()

// Auth state
bool isAuthenticated()
Map<String, dynamic>? getUserMetadata()
Stream<AuthState> get authStateChanges

// Password management
Future<void> updatePassword(String newPassword)
Future<void> resetPassword(String email)
```

### SupabaseFishItemsService

```dart
// CRUD
Future<FishItem> addFishItem(FishItem fishItem)
Future<List<FishItem>> getFishItemsByUser(String? userId)
Future<FishItem?> getFishItemById(String itemId)
Future<FishItem> updateFishItem(FishItem fishItem)
Future<void> deleteFishItem(String itemId)

// Advanced
Future<List<FishItem>> searchFishItems(String query, String userId)
Future<List<FishItem>> addMultipleFishItems(List<FishItem> items)
Stream<List<FishItem>> getFishItemsStream(String userId)
```

### SupabaseStorageService

```dart
// Upload
Future<String> uploadFishPhoto(String filePath, {String? fileName})
Future<String> uploadFishPhotoReplace(String filePath, {required String fileName})

// Delete
Future<void> deleteFishPhoto(String fileName)
Future<void> deleteFishPhotoByUrl(String publicUrl)

// Batch
Future<Map<String, String>> uploadMultipleFishPhotos(List<String> filePaths)

// List & Info
Future<List<FileObject>> listFishPhotos()
String getPublicUrl(String fileName)
Future<bool> isBucketAccessible()
```

---

## 🐛 Troubleshooting

### 1. Error: "Unauthorized" saat upload/read data

**Penyebab**: RLS policies tidak diatur atau user tidak authenticated

**Solusi**:
```sql
-- Check RLS policy
SELECT * FROM pg_policies WHERE tablename = 'fish_items';

-- Reset policies (dangerous, hanya untuk development)
DROP POLICY "Users can see own fish items" ON public.fish_items;

-- Recreate dengan benar
CREATE POLICY "Users can see own fish items"
  ON public.fish_items FOR SELECT
  USING (auth.uid() = user_id);
```

### 2. Error: "auth.uid() IS NULL"

**Penyebab**: User belum login atau session expired

**Solusi**:
```dart
if (SupabaseConfig.currentUser == null) {
  // Redirect ke login
  Get.to(() => LoginPage());
  return;
}
```

### 3. Foto tidak bisa diupload

**Penyebab**: Bucket tidak public atau storage policy salah

**Solusi**:
1. Pastikan bucket `fish-photos` **Public**
2. Check storage policy di Supabase console
3. Verify permissions di `storage.objects` table

### 4. Real-time tidak jalan

**Penyebab**: Realtime tidak diaktifkan atau browser belum connect

**Solusi**:
```dart
// Check Realtime connection
final realtime = _client.realtimeClient;
print('Connection state: ${realtime.isConnected}');

// Manual reconnect
await realtime.reconnect();
```

### 5. Data tidak sinkron antar device

**Penyebab**: Realtime belum diaktifkan atau polling interval terlalu lama

**Solusi**:
```dart
// Aktifkan Realtime subscription
Stream<List<FishItem>> getFishItemsStream(String userId) {
  return _client
      .from('fish_items')
      .stream(primaryKey: ['id']) // ← Penting!
      .eq('user_id', userId)
      .map(/*...*/);
}

// Atau gunakan polling sebagai fallback
Timer.periodic(Duration(seconds: 30), (_) async {
  await loadFishItems();
});
```

### 6. Session lost setelah app restart

**Penyebab**: Session tidak di-persist dengan baik

**Solusi**:
```dart
// Di main.dart
@override
void onInit() {
  super.onInit();
  
  // Check existing session
  _checkCurrentUser();
  
  // Persist session
  final user = SupabaseConfig.currentUser;
  if (user != null) {
    // Save to SharedPreferences
    prefs.setString('user_id', user.id);
  }
}
```

### 7. Networking error

**Penyebab**: Network timeout atau Supabase server down

**Solusi**:
```dart
Future<void> loadFishItemsWithRetry({int maxRetries = 3}) async {
  int retries = 0;
  
  while (retries < maxRetries) {
    try {
      await loadFishItems();
      break;
    } catch (e) {
      retries++;
      if (retries >= maxRetries) {
        errorMessage.value = 'Network error. Please check your connection.';
        throw Exception('Max retries exceeded');
      }
      // Wait before retry
      await Future.delayed(Duration(seconds: 2 * retries));
    }
  }
}
```

---

## 📚 File Structure

```
lib/
├── config/
│   └── supabase_config.dart        # Konfigurasi Supabase
├── controllers/
│   ├── supabase_auth_controller.dart
│   └── supabase_fish_items_controller.dart
├── models/
│   └── fish_item.dart
├── services/
│   ├── supabase_auth_service.dart
│   ├── supabase_fish_items_service.dart
│   └── supabase_storage_service.dart
└── views/
    ├── auth/
    │   ├── login_page.dart
    │   └── signup_page.dart
    └── fish_items/
        ├── fish_list_page.dart
        ├── add_fish_page.dart
        └── fish_detail_page.dart
```

---

## ✅ Checklist

- [ ] Supabase account created
- [ ] Project credentials saved
- [ ] Dependencies installed (`flutter pub get`)
- [ ] `supabase_config.dart` configured
- [ ] `main.dart` initialized with Supabase
- [ ] `app_bindings.dart` updated
- [ ] Database tables created (user_profiles, fish_items)
- [ ] RLS policies setup
- [ ] Storage bucket created and public
- [ ] UI pages created (login, signup, fish list, add fish)
- [ ] Auth controller integrated
- [ ] Fish items CRUD tested
- [ ] Photo upload tested
- [ ] Real-time sync verified

---

## 🔗 Useful Links

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/reference/flutter)
- [Authentication Guide](https://supabase.com/docs/guides/auth)
- [Database Guide](https://supabase.com/docs/guides/database)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Realtime Guide](https://supabase.com/docs/guides/realtime)

---

**Last Updated**: November 2024  
**Version**: 1.0
