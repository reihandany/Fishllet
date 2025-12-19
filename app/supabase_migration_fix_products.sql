-- ═══════════════════════════════════════════════════════════════════════════
-- SUPABASE SQL: Update Products Table untuk Custom API
-- ═══════════════════════════════════════════════════════════════════════════
-- Run di Supabase SQL Editor

-- 1. Alter products table - ubah id jadi TEXT (bukan BIGINT)
-- Karena Custom API pakai ID string ("1", "2", dll)

-- Backup data existing dulu (opsional)
-- CREATE TABLE products_backup AS SELECT * FROM products;

-- Drop foreign keys dulu
ALTER TABLE cart_items DROP CONSTRAINT IF EXISTS cart_items_product_id_fkey;
ALTER TABLE order_items DROP CONSTRAINT IF EXISTS order_items_product_id_fkey;

-- DROP IDENTITY constraint dulu (ini yang penting!)
ALTER TABLE products ALTER COLUMN id DROP IDENTITY IF EXISTS;
ALTER TABLE products ALTER COLUMN id DROP DEFAULT;

-- Sekarang baru bisa ubah jadi TEXT
ALTER TABLE products ALTER COLUMN id TYPE TEXT USING id::text;

-- Tambah column category jika belum ada
ALTER TABLE products ADD COLUMN IF NOT EXISTS category TEXT;

-- Recreate foreign keys dengan TEXT
ALTER TABLE cart_items 
  ALTER COLUMN product_id TYPE TEXT,
  ADD CONSTRAINT cart_items_product_id_fkey 
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE order_items 
  ALTER COLUMN product_id TYPE TEXT,
  ADD CONSTRAINT order_items_product_id_fkey 
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

-- Update RLS policies (jika ada)
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON products;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON products;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON products;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON products;

-- Create new policies
CREATE POLICY "Enable read access for all users" 
  ON products FOR SELECT 
  USING (true);

CREATE POLICY "Enable insert for authenticated users only" 
  ON products FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users only" 
  ON products FOR UPDATE 
  USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users only" 
  ON products FOR DELETE 
  USING (auth.role() = 'authenticated');

-- ═══════════════════════════════════════════════════════════════════════════
-- Selesai!
-- ═══════════════════════════════════════════════════════════════════════════

-- Test query:
-- SELECT * FROM products;
