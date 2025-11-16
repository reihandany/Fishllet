# 🛠️ API Reference & Best Practices

Dokumentasi lengkap API Supabase services dan best practices untuk Fishllet.

---

## 📚 API Reference

### SupabaseAuthService

**File**: `lib/services/supabase_auth_service.dart`

#### Sign Up

```dart
Future<User?> signUp({
  required String email,
  required String password,
  Map<String, dynamic>? metadata,
})
```

**Parameters**:
- `email` (String): Email user yang unik
- `password` (String): Password minimum 6 karakter
- `metadata` (Map): Data tambahan (nama, dll) - optional

**Returns**: `User?` - Supabase User object atau null jika gagal

**Throws**: `AuthException`

**Example**:
```dart
final user = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  metadata: {
    'full_name': 'John Doe',
    'created_at': DateTime.now().toIso8601String(),
  },
);
```

---

#### Login

```dart
Future<User?> login({
  required String email,
  required String password,
})
```

**Parameters**:
- `email` (String): Email user
- `password` (String): Password

**Returns**: `User?` - Supabase User object atau null jika gagal

**Throws**: `AuthException` - jika credential salah

**Example**:
```dart
final user = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);
```

---

#### Logout

```dart
Future<void> logout()
```

**Side Effects**:
- Menghapus session token
- Clear cached user data
- Destroy refresh token

**Example**:
```dart
await authService.logout();
```

---

#### Get Current User

```dart
User? getCurrentUser()
String? getCurrentUserId()
String? getCurrentUserEmail()
bool isAuthenticated()
```

**Returns**:
- `getCurrentUser()`: `User?` object
- `getCurrentUserId()`: User ID (UUID)
- `getCurrentUserEmail()`: User email
- `isAuthenticated()`: boolean

**Example**:
```dart
final user = authService.getCurrentUser();
final userId = authService.getCurrentUserId();
final isAuth = authService.isAuthenticated();

if (isAuth) {
  print('User: ${authService.getCurrentUserEmail()}');
}
```

---

#### Reset Password

```dart
Future<void> resetPassword(String email)
```

**Parameters**:
- `email` (String): User email

**Side Effects**:
- Kirim email dengan reset link
- Email berlaku 24 jam

**Example**:
```dart
await authService.resetPassword('user@example.com');
// User akan terima email dengan link reset
```

---

#### Update Password

```dart
Future<void> updatePassword(String newPassword)
```

**Parameters**:
- `newPassword` (String): Password baru (min 6 karakter)

**Requires**: User harus sudah login

**Example**:
```dart
await authService.updatePassword('newPassword123');
```

---

#### Auth State Changes

```dart
Stream<AuthState> get authStateChanges
```

**Returns**: Stream yang emit setiap ada perubahan auth state

**Example**:
```dart
authService.authStateChanges.listen((state) {
  if (state.session != null) {
    print('User logged in: ${state.session!.user.email}');
  } else {
    print('User logged out');
  }
});
```

---

### SupabaseFishItemsService

**File**: `lib/services/supabase_fish_items_service.dart`

#### Add Fish Item

```dart
Future<FishItem> addFishItem(FishItem fishItem)
```

**Parameters**:
- `fishItem` (FishItem): Object dengan data item ikan

**Returns**: `FishItem` - Item yang sudah disimpan dengan ID dari database

**Throws**: `PostgrestException` jika error di database

**Example**:
```dart
final item = FishItem(
  userId: userId,
  name: 'Koi Kohaku',
  species: 'Koi',
  quantity: 5,
  quantityUnit: 'ekor',
  price: 150000,
);

final savedItem = await fishService.addFishItem(item);
print('Saved with ID: ${savedItem.id}');
```

---

#### Get Fish Items By User

```dart
Future<List<FishItem>> getFishItemsByUser(String? userId)
```

**Parameters**:
- `userId` (String?): User ID - jika null pakai current user ID

**Returns**: `List<FishItem>` - List item user (hanya yang is_active=true)

**Throws**: `PostgrestException` atau Exception jika user tidak authenticated

**Example**:
```dart
final items = await fishService.getFishItemsByUser(userId);
print('Total items: ${items.length}');

// Atau pakai current user
final myItems = await fishService.getFishItemsByUser(null);
```

---

#### Get Fish Item By ID

```dart
Future<FishItem?> getFishItemById(String itemId)
```

**Parameters**:
- `itemId` (String): ID dari fish item

**Returns**: `FishItem?` - Item object atau null jika tidak ditemukan

**Example**:
```dart
final item = await fishService.getFishItemById('item-id-123');

if (item != null) {
  print('Found: ${item.name}');
} else {
  print('Item not found');
}
```

---

#### Update Fish Item

```dart
Future<FishItem> updateFishItem(FishItem fishItem)
```

**Parameters**:
- `fishItem` (FishItem): Object dengan data terupdate (HARUS punya ID)

**Returns**: `FishItem` - Item yang sudah diupdate

**Throws**: `PostgrestException` atau Exception jika ID null

**Example**:
```dart
final updated = item.copyWith(
  quantity: 10,
  price: 200000,
);

final result = await fishService.updateFishItem(updated);
```

---

#### Delete Fish Item

```dart
Future<void> deleteFishItem(String itemId)
Future<void> hardDeleteFishItem(String itemId)
```

**Parameters**:
- `itemId` (String): ID dari fish item

**Soft Delete** (default): Set `is_active = false`
- Item tetap di database
- Bisa di-restore

**Hard Delete**: Permanent delete dari database
- Data tidak bisa di-recover

**Example**:
```dart
// Soft delete (recommended)
await fishService.deleteFishItem('item-id-123');

// Hard delete (permanent)
await fishService.hardDeleteFishItem('item-id-123');
```

---

#### Search Fish Items

```dart
Future<List<FishItem>> searchFishItems(String query, String userId)
```

**Parameters**:
- `query` (String): Search keyword (nama atau species)
- `userId` (String): User ID

**Returns**: `List<FishItem>` - Items yang match dengan query

**Search Fields**: `name`, `species`, `description`

**Example**:
```dart
final results = await fishService.searchFishItems('Koi', userId);
// Hasil: items dengan nama atau species mengandung 'Koi'
```

---

#### Batch Add Multiple Items

```dart
Future<List<FishItem>> addMultipleFishItems(List<FishItem> items)
```

**Parameters**:
- `items` (List<FishItem>): List item untuk diinsert

**Returns**: `List<FishItem>` - Items yang sudah disimpan dengan ID

**Use Case**: Import data dari file atau bulk operations

**Example**:
```dart
final items = [
  FishItem(userId: uid, name: 'Koi 1', species: 'Koi'),
  FishItem(userId: uid, name: 'Cupang 1', species: 'Cupang'),
  FishItem(userId: uid, name: 'Arwana 1', species: 'Arwana'),
];

final saved = await fishService.addMultipleFishItems(items);
print('Saved ${saved.length} items');
```

---

#### Fish Items Stream (Real-time)

```dart
Stream<List<FishItem>> getFishItemsStream(String userId)
```

**Parameters**:
- `userId` (String): User ID

**Returns**: `Stream<List<FishItem>>` - Stream yang emit list items setiap ada perubahan

**Real-time Updates**:
- Insert/Update/Delete dari device lain → otomatis update
- Interval: Real-time (milliseconds)

**Example**:
```dart
fishService.getFishItemsStream(userId).listen((items) {
  print('Items updated: ${items.length}');
  // Update UI with items
});

// Atau di StreamBuilder:
StreamBuilder<List<FishItem>>(
  stream: fishService.getFishItemsStream(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(snapshot.data![index].name));
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### SupabaseStorageService

**File**: `lib/services/supabase_storage_service.dart`

#### Upload Fish Photo

```dart
Future<String> uploadFishPhoto(
  String filePath, {
  String? fileName,
})
```

**Parameters**:
- `filePath` (String): Path lokal file (absolute path)
- `fileName` (String?): Custom filename - optional, auto-generate jika kosong

**Returns**: `String` - Public URL dari file yang diupload

**Throws**: `StorageException` jika file tidak ditemukan atau upload gagal

**Supported Formats**: JPG, PNG, GIF, WebP (recommended max 5MB)

**Example**:
```dart
final publicUrl = await storageService.uploadFishPhoto(
  '/data/user/0/my.app/cache/image_picker_123456.jpg',
  fileName: 'koi_kohaku_01.jpg',
);

print('Uploaded: $publicUrl');
// https://project.supabase.co/storage/v1/object/public/fish-photos/user-id/koi_kohaku_01.jpg
```

---

#### Upload with Replace (Upsert)

```dart
Future<String> uploadFishPhotoReplace(
  String filePath, {
  required String fileName,
})
```

**Parameters**:
- `filePath` (String): Path lokal file
- `fileName` (String): Nama file (akan replace file lama jika ada)

**Returns**: `String` - Public URL

**Use Case**: Update photo item yang sudah ada

**Example**:
```dart
// Replace foto lama dengan foto baru
final newUrl = await storageService.uploadFishPhotoReplace(
  imagePath,
  fileName: 'item-123-photo.jpg',
);
```

---

#### Delete Photo

```dart
Future<void> deleteFishPhoto(String fileName)
Future<void> deleteFishPhotoByUrl(String publicUrl)
```

**Parameters**:
- `deleteFishPhoto`: `fileName` - nama file di storage
- `deleteFishPhotoByUrl`: `publicUrl` - full public URL

**Example**:
```dart
// Delete by filename
await storageService.deleteFishPhoto('koi_kohaku_01.jpg');

// Delete by URL
await storageService.deleteFishPhotoByUrl(
  'https://project.supabase.co/storage/v1/object/public/fish-photos/...'
);
```

---

#### Batch Upload

```dart
Future<Map<String, String>> uploadMultipleFishPhotos(List<String> filePaths)
```

**Parameters**:
- `filePaths` (List<String>): List path file lokal

**Returns**: `Map<String, String>` - Map dari filename ke public URL

**Behavior**: Upload semua file, skip yang error dan lanjut

**Example**:
```dart
final paths = ['/path/to/fish1.jpg', '/path/to/fish2.jpg'];

final results = await storageService.uploadMultipleFishPhotos(paths);

results.forEach((filename, url) {
  print('$filename → $url');
});
```

---

#### List Photos

```dart
Future<List<FileObject>> listFishPhotos()
```

**Returns**: `List<FileObject>` - Semua file di folder user

**Example**:
```dart
final files = await storageService.listFishPhotos();

for (var file in files) {
  print('${file.name} - ${file.updatedAt}');
}
```

---

#### Get Public URL

```dart
String getPublicUrl(String fileName)
```

**Parameters**:
- `fileName` (String): Nama file

**Returns**: `String` - Public URL (tidak perlu upload lagi)

**Use Case**: Generate URL dari filename yang sudah ada

**Example**:
```dart
final url = storageService.getPublicUrl('photo.jpg');
// https://...
```

---

#### Check Bucket Access

```dart
Future<bool> isBucketAccessible()
```

**Returns**: `bool` - true jika bucket accessible

**Use Case**: Verify connection saat app start

**Example**:
```dart
final accessible = await storageService.isBucketAccessible();

if (!accessible) {
  print('Storage not accessible');
}
```

---

## 🎯 Best Practices

### 1. Error Handling

❌ **Don't**:
```dart
await authService.login(email: email, password: password);
// No error handling!
```

✅ **Do**:
```dart
try {
  await authService.login(email: email, password: password);
} on AuthException catch (e) {
  // Handle auth-specific errors
  print('Auth error: ${e.message}');
  Get.snackbar('Login Failed', e.message);
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
  Get.snackbar('Error', 'Something went wrong');
}
```

---

### 2. Validation

❌ **Don't**:
```dart
// No validation
final item = FishItem(
  userId: userId,
  name: '',  // ← Invalid!
  species: '',  // ← Invalid!
);
```

✅ **Do**:
```dart
bool isValidItem(FishItem item) {
  if (item.name.trim().isEmpty) return false;
  if (item.species.trim().isEmpty) return false;
  if (item.quantity != null && item.quantity! < 0) return false;
  return true;
}

if (isValidItem(item)) {
  await addFishItem(item);
}
```

---

### 3. Performance - Use Pagination

❌ **Don't** (untuk user dengan banyak items):
```dart
// Load semua data sekaligus
final items = await fishService.getFishItemsByUser(userId);
// Slow & memory intensive!
```

✅ **Do** (dengan pagination):
```dart
// Load 20 items pertama
var items = await fishService.getFishItemsByUser(userId);
items = items.take(20).toList();

// Load more saat scroll
// Gunakan StreamBuilder dengan pagination limit
```

---

### 4. Caching

❌ **Don't**:
```dart
// Network request setiap kali
await loadFishItems();
await loadFishItems();
await loadFishItems();
```

✅ **Do**:
```dart
// Cache dengan timestamp
var _cachedItems = <FishItem>[];
var _cacheTimestamp = DateTime.now();

Future<List<FishItem>> getFishItemsCached() async {
  // Return cache jika masih fresh (< 5 menit)
  if (DateTime.now().difference(_cacheTimestamp).inMinutes < 5) {
    return _cachedItems;
  }
  
  // Refresh dari server
  _cachedItems = await fishService.getFishItemsByUser(userId);
  _cacheTimestamp = DateTime.now();
  return _cachedItems;
}
```

---

### 5. Real-time Sync Best Practices

❌ **Don't**:
```dart
// Poll every second (battery drain!)
Timer.periodic(Duration(seconds: 1), (_) {
  loadFishItems();
});
```

✅ **Do**:
```dart
// Gunakan Realtime
fishService.getFishItemsStream(userId).listen((items) {
  // Auto update UI
  updateUI(items);
});

// Fallback polling jika realtime error
Timer.periodic(Duration(seconds: 30), (_) {
  if (!isRealtimeConnected()) {
    loadFishItems();
  }
});
```

---

### 6. Photo Upload Optimization

❌ **Don't**:
```dart
// Upload full resolution photo
await storageService.uploadFishPhoto(imagePath);
```

✅ **Do**:
```dart
import 'package:image/image.dart' as img;
import 'dart:io';

Future<String> uploadOptimizedPhoto(String imagePath) async {
  // Compress image first
  final file = File(imagePath);
  var image = img.decodeImage(file.readAsBytesSync());
  
  // Resize ke max 1024x1024
  var resized = img.copyResize(image!,
    width: 1024,
    height: 1024,
  );
  
  // Save compressed
  final compressed = File('${imagePath}_compressed.jpg');
  compressed.writeAsBytesSync(
    img.encodeJpg(resized, quality: 85),
  );
  
  // Upload
  return await storageService.uploadFishPhoto(compressed.path);
}
```

---

### 7. Session Management

❌ **Don't**:
```dart
// Hard assume user login after restart
if (SupabaseConfig.currentUser != null) {
  // Maybe stale data!
}
```

✅ **Do**:
```dart
Future<bool> checkAuthOnAppStart() async {
  final user = SupabaseConfig.currentUser;
  
  if (user == null) return false;
  
  // Verify session masih valid
  try {
    await SupabaseConfig.client.auth.refreshSession();
    return true;
  } catch (e) {
    // Session expired, logout
    await logout();
    return false;
  }
}
```

---

### 8. Data Consistency

❌ **Don't**:
```dart
// Langsung update UI sebelum server confirm
item.name = 'New Name';
updateLocalUI(item);  // ← Premature!

await updateFishItem(item);  // Server error → UI inconsistent!
```

✅ **Do**:
```dart
try {
  final updated = await updateFishItem(item);
  // Update UI hanya setelah server confirm
  updateLocalUI(updated);
} catch (e) {
  // Error → rollback
  showError('Update failed');
}
```

---

### 9. Logout Cleanup

❌ **Don't**:
```dart
await authService.logout();
// Forget to clear local data!
Get.off(() => LoginPage());
```

✅ **Do**:
```dart
Future<void> logout() async {
  // Clear auth
  await authService.logout();
  
  // Clear cached data
  fishCtrl.clearFishItems();
  
  // Clear preferences
  await prefs.clear();
  
  // Redirect
  Get.offAll(() => LoginPage());
}
```

---

### 10. Connection Handling

❌ **Don't**:
```dart
// No internet check
await fishService.getFishItemsByUser(userId);
// Crash jika offline!
```

✅ **Do**:
```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasInternet() async {
  final connectivity = Connectivity();
  final result = await connectivity.checkConnectivity();
  return result != ConnectivityResult.none;
}

Future<void> loadFishItemsSafely() async {
  if (!await hasInternet()) {
    Get.snackbar(
      'Offline',
      'Please check your internet connection',
    );
    return;
  }
  
  await loadFishItems();
}
```

---

## 🔐 Security Best Practices

1. **Never hardcode credentials** - Use environment variables
2. **Enable RLS** - Restrict data access per user
3. **Validate input** - Check email, password, filename format
4. **Use HTTPS only** - Supabase always uses HTTPS
5. **Rotate keys regularly** - Update API keys periodically
6. **Limit upload file size** - Prevent abuse
7. **Scan uploaded files** - Check for malware
8. **Use strong passwords** - Enforce min 8 characters + special chars

---

**Last Updated**: November 2024
