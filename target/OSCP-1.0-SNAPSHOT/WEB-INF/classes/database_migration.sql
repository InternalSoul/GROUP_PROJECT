-- Migration script to add payment_method column to orders table
-- Run this if you already have the database setup and need to add the payment_method column

-- Add payment_method column to orders table if it doesn't exist
ALTER TABLE orders ADD COLUMN payment_method VARCHAR(50) DEFAULT NULL;

-- Update carts table to use customer_username instead of user_id
-- Note: If your carts table already has data, you may need to migrate the data first
-- This script assumes you're starting fresh or can recreate the table

-- Drop existing carts table if needed
-- DROP TABLE IF EXISTS cart_items;
-- DROP TABLE IF EXISTS carts;

-- Recreate carts table with correct structure
-- CREATE TABLE carts (
--   cart_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
--   customer_username VARCHAR(100) NOT NULL,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--   PRIMARY KEY (cart_id),
--   UNIQUE (customer_username),
--   FOREIGN KEY (customer_username) REFERENCES users(username) ON DELETE CASCADE
-- );
