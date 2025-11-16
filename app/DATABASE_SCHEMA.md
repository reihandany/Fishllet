# 🗄️ Database Schema Documentation

Dokumentasi lengkap schema database Fishllet di Supabase.

---

## 📋 Daftar Tabel

1. `auth.users` - Managed by Supabase Auth
2. `public.fish_items` - User's fish items/notes
3. `public.user_profiles` - User profile data (optional)

---

## 1️⃣ Table: auth.users

**Managed by**: Supabase Auth (automatic)

**Columns**:
```
id (UUID)              - Unique identifier
email (TEXT)           - User email (unique)
encrypted_password     - Encrypted password
email_confirmed_at     - Confirmation timestamp
phone                  - User phone
confirmed_at           - Email confirmed timestamp
last_sign_in_at        - Last login timestamp
raw_app_meta_data      - App metadata (JSON)
raw_user_meta_data     - User metadata (JSON)
created_at             - Account creation time
updated_at             - Last update time
```

**User Metadata Fields** (disimpan di `raw_user_meta_data`):
```json
{
  "full_name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Sample Queries**:
```sql
-- Get user by email
SELECT * FROM auth.users WHERE email = 'user@example.com';

-- Get user metadata
SELECT id, email, raw_user_meta_data FROM auth.users;
```

---

## 2️⃣ Table: fish_items

**Purpose**: Menyimpan data ikan/catatan ikan milik user

**SQL Definition**:
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
```

**Column Details**:

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Unique identifier |
| `user_id` | UUID | NO | - | Reference ke `auth.users.id` |
| `name` | TEXT | NO | - | Nama ikan (e.g., "Koi Kohaku") |
| `species` | TEXT | NO | - | Jenis/spesies (e.g., "Koi", "Cupang") |
| `description` | TEXT | YES | NULL | Deskripsi tambahan |
| `quantity` | DECIMAL | YES | NULL | Jumlah/stok |
| `quantity_unit` | TEXT | YES | NULL | Satuan (e.g., "ekor", "kg", "liter") |
| `price` | DECIMAL | YES | NULL | Harga per unit |
| `photo_url` | TEXT | YES | NULL | URL foto dari Storage |
| `is_active` | BOOLEAN | NO | `true` | Status item (untuk soft delete) |
| `created_at` | TIMESTAMP | NO | `NOW()` | Waktu pembuatan |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Waktu update terakhir |

**Indexes**:
```sql
CREATE INDEX idx_fish_items_user_id ON public.fish_items(user_id);
CREATE INDEX idx_fish_items_created_at ON public.fish_items(created_at DESC);
```

**RLS Policies**:
```sql
-- SELECT
CREATE POLICY "Users can see own fish items"
  ON public.fish_items FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT
CREATE POLICY "Users can insert own fish items"
  ON public.fish_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE
CREATE POLICY "Users can update own fish items"
  ON public.fish_items FOR UPDATE
  USING (auth.uid() = user_id);

-- DELETE
CREATE POLICY "Users can delete own fish items"
  ON public.fish_items FOR DELETE
  USING (auth.uid() = user_id);
```

**Sample Data**:
```sql
-- Insert sample fish item
INSERT INTO public.fish_items (
  user_id, name, species, description, quantity,
  quantity_unit, price, is_active
) VALUES (
  'user-uuid-here',
  'Koi Kohaku',
  'Koi',
  'Premium quality from Japan',
  5,
  'ekor',
  150000,
  true
);

-- Update quantity
UPDATE public.fish_items
SET quantity = 10, updated_at = NOW()
WHERE id = 'item-id-here';

-- Soft delete (set inactive)
UPDATE public.fish_items
SET is_active = false
WHERE id = 'item-id-here';

-- Get user's fish items
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true
ORDER BY created_at DESC;
```

---

## 3️⃣ Table: user_profiles (Optional)

**Purpose**: Menyimpan profile user yang lebih detail

**SQL Definition** (optional, untuk future enhancement):
```sql
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  phone TEXT,
  location TEXT,
  website TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);
```

---

## 📦 Storage Buckets

### fish-photos

**Path Structure**:
```
fish-photos/
├── {user_id}/
│   ├── fish_1234567890_photo1.jpg
│   ├── fish_1234567890_photo2.jpg
│   └── ...
```

**Public URL Format**:
```
https://project.supabase.co/storage/v1/object/public/fish-photos/{user_id}/{filename}
```

**Security**:
- Bucket: **Public** (anyone can read)
- Upload: Only authenticated users
- Delete: Only the file owner

**RLS Policies**:
```sql
-- Public read access
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'fish-photos');

-- Authenticated upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'fish-photos'
  AND auth.role() = 'authenticated'
);

-- Users can delete own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'fish-photos'
  AND owner = auth.uid()
);
```

---

## 🔍 Useful Queries

### Authentication

```sql
-- Count total users
SELECT COUNT(*) as total_users FROM auth.users;

-- Find user by email
SELECT id, email, created_at FROM auth.users 
WHERE email = 'user@example.com';

-- Get users created in last 7 days
SELECT email, created_at FROM auth.users
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;
```

### Fish Items

```sql
-- Get all fish items of specific user
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true
ORDER BY created_at DESC;

-- Get total value of user's stock
SELECT 
  user_id,
  SUM(quantity * price) as total_value,
  COUNT(*) as item_count
FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true
GROUP BY user_id;

-- Find items by species
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND species ILIKE 'Koi'
  AND is_active = true;

-- Get items added in last 30 days
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND created_at >= NOW() - INTERVAL '30 days'
  AND is_active = true
ORDER BY created_at DESC;

-- Get low stock items (quantity < 5)
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND quantity < 5
  AND is_active = true;

-- Get items with photos
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND photo_url IS NOT NULL
  AND is_active = true;
```

### Statistics

```sql
-- User stats
SELECT 
  COUNT(*) as total_items,
  COUNT(DISTINCT species) as unique_species,
  SUM(quantity) as total_quantity,
  AVG(price) as avg_price,
  SUM(quantity * price) as total_value
FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true;

-- Most expensive species
SELECT 
  species,
  MAX(price) as max_price,
  AVG(price) as avg_price,
  COUNT(*) as count
FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true
GROUP BY species
ORDER BY avg_price DESC;
```

---

## 🚨 Maintenance

### Backup & Recovery

```sql
-- Export all fish items (backup)
SELECT * FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = true
ORDER BY created_at DESC;

-- Restore soft-deleted items
UPDATE public.fish_items
SET is_active = true
WHERE user_id = 'user-uuid'
  AND is_active = false
  AND updated_at >= NOW() - INTERVAL '7 days';
```

### Data Cleanup

```sql
-- Delete permanently all items soft-deleted more than 90 days ago
DELETE FROM public.fish_items
WHERE user_id = 'user-uuid'
  AND is_active = false
  AND updated_at < NOW() - INTERVAL '90 days';

-- Cleanup orphaned records (shouldn't happen with FK)
DELETE FROM public.fish_items
WHERE user_id NOT IN (SELECT id FROM auth.users);
```

---

## 📊 Data Relationships

```
auth.users (1)
    ↓
    └─→ public.fish_items (Many)
        - One user can have many fish items
        - Foreign key: user_id → auth.users.id
        - Cascade delete: delete user → delete all items
```

---

## 🔐 Security Checklist

- [x] RLS enabled on fish_items table
- [x] Policies restrict users to their own data
- [x] Foreign key constraints set
- [x] Indexes created for performance
- [x] Storage bucket public with upload restrictions
- [x] Soft delete pattern (is_active flag)
- [x] Audit fields (created_at, updated_at)

---

**Last Updated**: November 2024
