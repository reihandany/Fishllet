-- Migration: Add updated_at column to products table
-- Date: 2025-12-19
-- Description: Menambahkan kolom updated_at untuk tracking perubahan data produk

-- 1. Tambahkan kolom updated_at jika belum ada
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Update existing records dengan timestamp sekarang
UPDATE products 
SET updated_at = NOW() 
WHERE updated_at IS NULL;

-- 3. Buat fungsi untuk auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 4. Buat trigger untuk auto-update saat UPDATE
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
CREATE TRIGGER update_products_updated_at 
BEFORE UPDATE ON products 
FOR EACH ROW 
EXECUTE FUNCTION update_updated_at_column();

-- 5. Verifikasi kolom sudah ditambahkan
-- Jalankan query ini untuk cek:
-- SELECT column_name, data_type, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'products';

-- ✅ Migration selesai!
-- Sekarang setiap kali product di-update, updated_at akan otomatis ter-update
