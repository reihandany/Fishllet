# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Notifikasi Pesanan

Cara sederhana agar notifikasi muncul ketika pesanan dibuat:

- Pada `lib/services/fcm_service.dart` terdapat helper untuk menampilkan notifikasi lokal: `FCMService.showLocalNotification(...)`.
- Kami telah menambahkan pemanggilan notifikasi pada `OrdersController.addOrder(...)` sehingga setiap kali pesanan dibuat (mis. setelah checkout berhasil), notifikasi lokal akan muncul di perangkat.

Langkah pengujian:

1. Jalankan aplikasi pada perangkat/emulator (pastikan Firebase FCM terinisialisasi saat `main.dart` memanggil `FCMService.initializeFCM()`).
2. Beri izin notifikasi (terutama pada iOS atau Android 13+).
3. Buat pesanan melalui alur checkout aplikasi; notifikasi lokal akan tampil ketika pesanan berhasil disimpan.

Jika ingin notifikasi cross-device (mis. notifikasi ke penjual atau admin), gunakan Firebase Cloud Messaging (server-side):

- Simpan FCM token setiap pengguna di database.
- Dari server (atau Supabase Function), panggil Firebase Admin SDK untuk mengirim pesan ke token pengguna tertentu ketika ada pesanan baru.
- App akan menerima notifikasi FCM dan menampilkannya via `FCMService`.

Hubungi saya jika Anda ingin menambahkan alur server-side notifikasi (kirim pesan ke admin/pedagang ketika pesanan baru masuk). 
