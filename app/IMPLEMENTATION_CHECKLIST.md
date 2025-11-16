# ✅ Supabase Implementation Checklist

Checklist lengkap untuk implementasi Supabase Fishllet.

---

## 📋 Phase 1: Project Setup (30 menit)

### 1.1 Supabase Project Creation
- [ ] Buat akun di supabase.com
- [ ] Buat project baru bernama "Fishllet"
- [ ] Pilih region (Singapore recommended untuk Indonesia)
- [ ] Save database password di tempat aman
- [ ] Tunggu project initialization selesai (2-3 menit)

### 1.2 Get Credentials
- [ ] Buka Settings > API
- [ ] Copy Project URL
- [ ] Copy Anon Key (public key, aman untuk frontend)
- [ ] Simpan di file `.env` atau secure notes

### 1.3 Update Config
- [ ] Edit `lib/config/supabase_config.dart`
- [ ] Paste URL di `supabaseUrl`
- [ ] Paste Anon Key di `supabaseAnonKey`
- [ ] Verify format URL (harus ada `.supabase.co`)

### 1.4 Install Dependencies
```bash
cd app
flutter pub get
```
- [ ] Pastikan tidak ada error
- [ ] Tunggu packages terinstall (~2 menit)

### 1.5 Update main.dart
- [ ] Import `supabase_flutter`
- [ ] Import `supabase_config`
- [ ] Add `await SupabaseConfig.initialize()` di main()
- [ ] Ensure WidgetsFlutterBinding initialized

### 1.6 Update AppBindings
- [ ] Add Supabase services (lazy put)
- [ ] Add Supabase controllers
- [ ] Verify no import errors

---

## 📊 Phase 2: Database Setup (20 menit)

### 2.1 Create Tables
Di Supabase SQL Editor:
- [ ] Copy SQL script dari SUPABASE_QUICK_START.md
- [ ] Paste ke SQL Editor
- [ ] Run script
- [ ] Verify tables created (check Table Editor)

### 2.2 Verify Tables
Buka Table Editor:
- [ ] ✅ `auth.users` exists (default)
- [ ] ✅ `fish_items` exists
- [ ] ✅ Columns sesuai schema

### 2.3 Enable RLS
- [ ] Buka `fish_items` table
- [ ] Check "RLS enabled"
- [ ] Verify 4 policies exist:
  - [ ] `Users can see own fish items`
  - [ ] `Users can insert own fish items`
  - [ ] `Users can update own fish items`
  - [ ] `Users can delete own fish items`

### 2.4 Create Indexes
- [ ] Run index creation commands
- [ ] Verify di Table Editor > Indexes

---

## 💾 Phase 3: Storage Setup (10 menit)

### 3.1 Create Bucket
- [ ] Storage > Buckets > New bucket
- [ ] Name: `fish-photos`
- [ ] ✅ Make it public
- [ ] Create bucket

### 3.2 Verify Bucket
- [ ] Bucket appears di Storage tab
- [ ] Status: Public ✅
- [ ] Can upload test file

### 3.3 Setup Policies
Di SQL Editor:
- [ ] Jalankan storage policy script
- [ ] Verify policies exist di storage.objects RLS

---

## 🔐 Phase 4: Authentication Implementation (45 menit)

### 4.1 Services & Controllers
- [ ] ✅ `supabase_auth_service.dart` created
- [ ] ✅ `supabase_auth_controller.dart` created
- [ ] ✅ Both files compile tanpa error

### 4.2 Test Sign Up
- [ ] Create test sign up page dengan form
- [ ] Call `authCtrl.signUp()`
- [ ] Check Supabase Auth tab untuk new user
- [ ] Verify metadata saved dengan nama user

### 4.3 Test Login
- [ ] Create test login page
- [ ] Call `authCtrl.login()`
- [ ] Verify `isAuthenticated.value = true`
- [ ] Check user object populated

### 4.4 Test Logout
- [ ] Call `authCtrl.logout()`
- [ ] Verify `isAuthenticated.value = false`
- [ ] Verify user cleared dari memory
- [ ] Verify session destroyed

### 4.5 Test Auth State
- [ ] Restart app dengan user logged in
- [ ] Verify user masih authenticated
- [ ] Check stream listener bekerja

### 4.6 Test Current User Info
- [ ] Get userId: `authCtrl.userId`
- [ ] Get email: `authCtrl.userEmail`
- [ ] Get metadata: `authCtrl.userFullName`
- [ ] All return correct values ✅

---

## 🐟 Phase 5: Fish Items CRUD (60 menit)

### 5.1 Setup Services & Controllers
- [ ] ✅ `supabase_fish_items_service.dart` created
- [ ] ✅ `supabase_fish_items_controller.dart` created
- [ ] ✅ `fish_item.dart` model created
- [ ] ✅ All files compile

### 5.2 Test INSERT
```dart
var item = FishItem(
  userId: userId,
  name: 'Koi Kohaku',
  species: 'Koi',
  quantity: 5,
  quantityUnit: 'ekor',
  price: 150000,
);
await fishCtrl.addFishItem(item);
```
- [ ] Item tersimpan di Supabase
- [ ] ID auto-generated
- [ ] Timestamp created_at auto-set
- [ ] Check di Table Editor > fish_items

### 5.3 Test READ
```dart
await fishCtrl.loadFishItems();
print(fishCtrl.fishItems); // Should have 1 item
```
- [ ] Items loaded dari database
- [ ] List tidak kosong
- [ ] Data valid (name, species, price, dll)

### 5.4 Test UPDATE
```dart
var updated = item.copyWith(
  name: 'Koi Kohaku Premium',
  quantity: 10,
);
await fishCtrl.updateFishItem(updated);
```
- [ ] Item updated di database
- [ ] `updated_at` auto-updated
- [ ] Changes reflect di UI

### 5.5 Test DELETE
```dart
await fishCtrl.deleteFishItem(item.id!);
```
- [ ] Item soft-deleted (is_active = false)
- [ ] Item hidden dari list
- [ ] Check di Table Editor (toggle "include inactive")

### 5.6 Test SEARCH
```dart
await fishCtrl.searchFishItems('Koi');
print(fishCtrl.filteredItems);
```
- [ ] Search bekerja di name
- [ ] Search bekerja di species
- [ ] Search case-insensitive
- [ ] Returns correct results

### 5.7 Test Bulk Insert
- [ ] Create 3-5 sample items
- [ ] Use `addMultipleFishItems(list)`
- [ ] All items saved
- [ ] Performance acceptable

### 5.8 Test Error Handling
- [ ] Try insert dengan name kosong (should fail)
- [ ] Try update item yang tidak exist (should fail)
- [ ] Try delete dengan invalid ID (should fail)
- [ ] Snackbar error message muncul ✅

---

## 📸 Phase 6: Photo Upload & Storage (45 menit)

### 6.1 Setup Service
- [ ] ✅ `supabase_storage_service.dart` created
- [ ] ✅ File compiles

### 6.2 Setup Dependencies
```bash
flutter pub add image_picker permission_handler
```
- [ ] Dependencies added
- [ ] Run `flutter pub get`

### 6.3 Test Single Upload
```dart
final imagePicker = ImagePicker();
final image = await imagePicker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final url = await storageService.uploadFishPhoto(image.path);
  print('Uploaded: $url');
}
```
- [ ] Image selected dari gallery
- [ ] Upload successful
- [ ] Public URL returned
- [ ] URL valid (buka di browser)

### 6.4 Test with Custom Filename
- [ ] Upload dengan custom filename
- [ ] Filename sesuai di storage
- [ ] URL mengandung custom filename

### 6.5 Test Upload Replace
- [ ] Upload foto pertama dengan filename "test.jpg"
- [ ] Upload foto lain dengan filename "test.jpg" (upsert)
- [ ] File lama ter-replace
- [ ] Hanya 1 file "test.jpg" di storage

### 6.6 Test Photo Delete
```dart
await storageService.deleteFishPhoto('filename.jpg');
```
- [ ] File deleted dari storage
- [ ] File tidak muncul di list
- [ ] Storage space freed

### 6.7 Test Delete by URL
```dart
await storageService.deleteFishPhotoByUrl(publicUrl);
```
- [ ] File deleted by URL
- [ ] Works dengan full URL

### 6.8 Test Batch Upload
```dart
final urls = await storageService.uploadMultipleFishPhotos([path1, path2, path3]);
```
- [ ] Multiple files uploaded
- [ ] Returns map dengan all URLs
- [ ] Performance acceptable

### 6.9 Test List Photos
```dart
final files = await storageService.listFishPhotos();
```
- [ ] All photos user ter-list
- [ ] File metadata returned
- [ ] Correct user folder

### 6.10 Integration with Fish Items
- [ ] Add fish item dengan photo
- [ ] Photo URL saved ke database
- [ ] Display photo di list
- [ ] Photo load dengan caching

### 6.11 Permissions
- [ ] Android: Permissions asked on first upload
- [ ] iOS: Permissions asked on first access
- [ ] User grants permission
- [ ] Upload proceeds

---

## ⚡ Phase 7: Real-time Synchronization (30 menit)

### 7.1 Enable Realtime
Di Supabase:
- [ ] Buka `fish_items` table
- [ ] Realtime should be enabled (check)
- [ ] If not, enable it

### 7.2 Test Realtime Stream
```dart
final stream = fishCtrl.getFishItemsStream();
stream.listen((items) {
  print('Items updated: ${items.length}');
  // Update UI
});
```
- [ ] Stream initialized
- [ ] Emits initial list
- [ ] No errors

### 7.3 Test Real-time Updates (Device A)
- [ ] Open app di device A
- [ ] Subscribe ke stream
- [ ] Add fish item dari device A
- [ ] Check device A updates immediately

### 7.4 Test Real-time Updates (Device B)
- [ ] Open app di device B (different browser/device)
- [ ] Subscribe ke same stream
- [ ] Add fish item dari device B
- [ ] Check device A mendapat update automatically

### 7.5 Test Real-time Delete
- [ ] Delete item dari device B
- [ ] Check device A melihat item dihapus (auto-refresh)

### 7.6 Test Real-time Update
- [ ] Update item quantity dari device A
- [ ] Check device B melihat quantity terupdate

### 7.7 Test Realtime Connection
- [ ] Close app
- [ ] Reopen
- [ ] Stream reconnect automatically
- [ ] No manual retry needed

### 7.8 Test Fallback
- [ ] Disable internet
- [ ] Try add item
- [ ] Error shown
- [ ] Enable internet
- [ ] Retry (or auto-retry)
- [ ] Item synced

### 7.9 Test Performance
- [ ] 100+ items di database
- [ ] Stream still responsive
- [ ] No lag/stutter

---

## 🎨 Phase 8: UI Integration (90 menit)

### 8.1 Auth Pages
- [ ] ✅ Login page created
- [ ] ✅ Sign up page created
- [ ] ✅ Form validation working
- [ ] ✅ Error messages display
- [ ] ✅ Loading states working

### 8.2 Login Flow
- [ ] User sign up → verify email (optional)
- [ ] User login → navigated ke home
- [ ] Credentials saved
- [ ] Logout → back ke login
- [ ] Auto-login on app restart

### 8.3 Fish Items Pages
- [ ] ✅ List page created
- [ ] ✅ Add/Create page created
- [ ] ✅ Edit page created
- [ ] ✅ Detail page created

### 8.4 Fish Items List UI
- [ ] Display semua items
- [ ] Show photo thumbnail
- [ ] Show name, species, quantity, price
- [ ] Search bar working
- [ ] Search filter working real-time
- [ ] Delete button working
- [ ] Edit button working

### 8.5 Add Fish Item UI
- [ ] Form fields: name, species, quantity, price, description
- [ ] Photo picker integration
- [ ] Submit button
- [ ] Validation sebelum submit
- [ ] Loading state during save
- [ ] Success message after save
- [ ] Return ke list

### 8.6 Edit Fish Item UI
- [ ] Form pre-filled dengan current data
- [ ] Photo bisa diganti
- [ ] Update button
- [ ] Delete button
- [ ] Success message after update

### 8.7 Detail Page
- [ ] Display item info
- [ ] Display photo (full size)
- [ ] Show all attributes
- [ ] Edit button
- [ ] Delete button

### 8.8 Responsive Design
- [ ] UI works di phone (small screen)
- [ ] UI works di tablet (large screen)
- [ ] Portrait orientation OK
- [ ] Landscape orientation OK

### 8.9 Error Handling UI
- [ ] Empty state ketika no items
- [ ] Loading skeleton/spinner
- [ ] Error message display
- [ ] Retry button
- [ ] Dismiss error

### 8.10 Accessibility
- [ ] Text readable
- [ ] Buttons easy to tap (min 48dp)
- [ ] Colors have contrast
- [ ] Forms have labels
- [ ] Keyboard navigation working

---

## 🧪 Phase 9: Testing (60 menit)

### 9.1 Unit Tests
```dart
// lib/test/services/supabase_auth_service_test.dart
// lib/test/models/fish_item_test.dart
```
- [ ] Test FishItem.toJson()
- [ ] Test FishItem.fromJson()
- [ ] Test FishItem.copyWith()
- [ ] Test auth service methods (mock Supabase)

### 9.2 Widget Tests
```dart
// lib/test/views/login_page_test.dart
```
- [ ] Test form validation
- [ ] Test button clicks
- [ ] Test error display
- [ ] Test navigation

### 9.3 Integration Tests
- [ ] Test complete auth flow
- [ ] Test complete CRUD flow
- [ ] Test photo upload
- [ ] Test realtime updates

### 9.4 Manual Testing Scenarios

#### Scenario 1: New User Flow
- [ ] Launch app
- [ ] Sign up dengan email baru
- [ ] Verify email (if required)
- [ ] Login dengan credentials baru
- [ ] See empty fish items list

#### Scenario 2: Add Item Flow
- [ ] Login
- [ ] Click add item button
- [ ] Fill form fields
- [ ] Pick photo dari gallery
- [ ] Click save
- [ ] Item muncul di list
- [ ] Photo tersimpan

#### Scenario 3: Search Flow
- [ ] Add 5+ items dengan berbagai species
- [ ] Type search keyword
- [ ] Results filter correctly
- [ ] Clear search
- [ ] All items kembali

#### Scenario 4: Multi-device Flow
- [ ] Login device A
- [ ] Add item di device A
- [ ] Check device B (updated real-time)
- [ ] Edit item di device B
- [ ] Check device A (updated real-time)
- [ ] Delete item di device A
- [ ] Check device B (item disappears)

#### Scenario 5: Offline Flow
- [ ] Login
- [ ] Go offline
- [ ] Try add item → error shown
- [ ] Go online
- [ ] Retry → item saved
- [ ] List updated

#### Scenario 6: Session Flow
- [ ] Login
- [ ] Close app completely
- [ ] Reopen app
- [ ] User masih logged in
- [ ] Data masih visible

#### Scenario 7: Error Flow
- [ ] Try logout user dari Supabase dashboard
- [ ] App detects error
- [ ] Shows error message
- [ ] Redirects ke login

### 9.5 Performance Testing
- [ ] App load time < 3 seconds
- [ ] List loads < 500ms
- [ ] Search response < 200ms
- [ ] Photo upload < 5 seconds
- [ ] Real-time update < 100ms

### 9.6 Security Testing
- [ ] Can't access other user's items
- [ ] Can't update other user's items
- [ ] Can't delete other user's items
- [ ] Credentials tidak stored in plain text
- [ ] Session tokens valid

---

## 🚀 Phase 10: Deployment Prep (30 menit)

### 10.1 Code Review
- [ ] No hardcoded credentials
- [ ] No debug print statements (remove or use debugPrint)
- [ ] No placeholder comments
- [ ] Code formatted (dart format .)
- [ ] No linting errors (flutter analyze)

### 10.2 Environment Setup
- [ ] Create `.env` file (don't commit!)
- [ ] Store Supabase credentials di environment
- [ ] Load credentials dari env (use flutter_dotenv)

### 10.3 Build for Android
```bash
flutter build apk
```
- [ ] Build successful
- [ ] No errors or warnings
- [ ] APK generated

### 10.4 Build for iOS
```bash
flutter build ios
```
- [ ] Build successful (requires macOS)
- [ ] No errors
- [ ] App archive created

### 10.5 Pre-launch Checklist
- [ ] Version updated (pubspec.yaml)
- [ ] App name correct
- [ ] App icon added
- [ ] Splash screen configured
- [ ] Privacy policy written
- [ ] Terms of service written
- [ ] App description completed
- [ ] Screenshots prepared

### 10.6 Testing on Real Device
- [ ] Test Android build on real device
- [ ] Test iOS build on real device (if available)
- [ ] Test all features
- [ ] Performance acceptable
- [ ] No crashes

---

## 📋 Final Verification

### All Features Working
- [x] ✅ Sign up / Register
- [x] ✅ Login
- [x] ✅ Logout
- [x] ✅ Get current user
- [x] ✅ Add fish item
- [x] ✅ List fish items
- [x] ✅ Get single item
- [x] ✅ Update item
- [x] ✅ Delete item
- [x] ✅ Search items
- [x] ✅ Upload photo
- [x] ✅ Delete photo
- [x] ✅ Real-time sync
- [x] ✅ Error handling
- [x] ✅ Loading states

### Documentation Complete
- [x] ✅ SUPABASE_QUICK_START.md
- [x] ✅ SUPABASE_INTEGRATION_GUIDE.md
- [x] ✅ DATABASE_SCHEMA.md
- [x] ✅ UI_IMPLEMENTATION_EXAMPLES.md
- [x] ✅ API_REFERENCE_AND_BEST_PRACTICES.md
- [x] ✅ DOCUMENTATION_INDEX.md
- [x] ✅ This checklist

### Code Quality
- [ ] No hardcoded values
- [ ] No unused imports
- [ ] No linting errors
- [ ] Proper error handling
- [ ] RLS policies enforced
- [ ] Input validation
- [ ] Code comments helpful

---

## 🎉 Launch Checklist

- [ ] All tests passing
- [ ] Performance acceptable
- [ ] Security verified
- [ ] Documentation complete
- [ ] Team trained on codebase
- [ ] Backup strategy defined
- [ ] Monitoring setup (optional)
- [ ] Go-live decision approved

---

**Status**: ✅ Ready for Implementation

**Next Step**: Start dengan Phase 1, ikuti secara berurutan!

---

**Last Updated**: November 2024
