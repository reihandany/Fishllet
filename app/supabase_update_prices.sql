-- Update harga produk di Supabase sesuai API
-- Jalankan di Supabase Dashboard > SQL Editor

-- Update harga satu per satu
UPDATE products SET price = 42000 WHERE id = '1';  -- Gurame
UPDATE products SET price = 78000 WHERE id = '2';  -- Udang
UPDATE products SET price = 75000 WHERE id = '3';  -- Cumi Ring
UPDATE products SET price = 74000 WHERE id = '4';  -- Cumi Tube
UPDATE products SET price = 33000 WHERE id = '5';  -- Dori
UPDATE products SET price = 58000 WHERE id = '6';  -- Gurita Cut
UPDATE products SET price = 66000 WHERE id = '7';  -- Kakap
UPDATE products SET price = 35000 WHERE id = '8';  -- Nila

-- Verifikasi hasil
SELECT id, name, price FROM products ORDER BY id;
