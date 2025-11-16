# 🚀 Supabase Quick Start Guide

Panduan cepat setup Supabase untuk Fishllet dalam 5 menit.

---

## Step 1: Siapkan Supabase Project (2 menit)

1. Buka [supabase.com](https://supabase.com) → Sign In/Sign Up
2. Klik **"New Project"**
3. Isi:
   - **Project name**: `Fishllet`
   - **Database password**: (buat password kuat, simpan di tempat aman!)
   - **Region**: Pilih yang paling dekat (misal: Singapore)
4. Klik **"Create new project"** dan tunggu ~2 menit

## Step 2: Dapatkan Credentials (1 menit)

1. Setelah project created, buka **Settings > API**
2. Copy credentials:
   ```
   Project URL:  https://YOUR_PROJECT.supabase.co
   Anon Key:     YOUR_ANON_KEY_HERE
   ```

3. Edit file `lib/config/supabase_config.dart`:
   ```dart
   static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```

## Step 3: Setup Database (2 menit)

Buka **SQL Editor** di Supabase, jalankan script ini:

```sql
-- 1. Create fish_items table
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
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.fish_items ENABLE ROW LEVEL SECURITY;

-- 3. Create RLS policies
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

-- 4. Create indexes
CREATE INDEX idx_fish_items_user_id ON public.fish_items(user_id);
CREATE INDEX idx_fish_items_created_at ON public.fish_items(created_at DESC);
```

## Step 4: Setup Storage (1 menit)

1. Buka **Storage** tab
2. Klik **"New bucket"**
3. Isi:
   - **Name**: `fish-photos`
   - **Public bucket**: ✅ Centang ini
4. Klik **"Create bucket"**

## Step 5: Update Code

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Update `main.dart`:
   ```dart
   import 'package:supabase_flutter/supabase_flutter.dart';
   import 'config/supabase_config.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await SupabaseConfig.initialize();
     // ... rest of code
     runApp(const MyApp());
   }
   ```

3. Update `app__bindings.dart` (refer ke dokumentasi utama)

## ✅ Selesai!

Sekarang Anda siap untuk:
- ✅ Auth (Sign up / Login / Logout)
- ✅ CRUD Fish Items
- ✅ Upload Foto
- ✅ Real-time Sync

---

## Next Steps

1. Buat UI pages untuk Auth
2. Test sign up & login
3. Buat UI untuk fish items list & CRUD
4. Test upload foto
5. Setup real-time monitoring

Lihat `SUPABASE_INTEGRATION_GUIDE.md` untuk detail lengkap!
