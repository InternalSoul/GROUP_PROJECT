-- =====================================================
-- OSCP - Online Shopping Clothing Platform
-- Database Setup Script for Apache Derby
-- =====================================================
-- 
-- To run this script in Derby:
-- 1. Start Derby Network Server
-- 2. Connect to the database using ij tool or NetBeans
-- 3. Execute this script
--
-- Connection URL: jdbc:derby://localhost:1527/Clothing_store
-- User: ROOT
-- Password: root
-- =====================================================

-- Create USERS table
CREATE TABLE USERS (
    USER_ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    USERNAME VARCHAR(50) NOT NULL UNIQUE,
    EMAIL VARCHAR(100) NOT NULL,
    PASSWORD VARCHAR(255) NOT NULL,
    ROLE VARCHAR(20) DEFAULT 'customer',
    ADDRESS VARCHAR(500)
);

-- Create PRODUCTS table
CREATE TABLE PRODUCTS (
    PRODUCT_ID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    PRICE DOUBLE NOT NULL,
    IMAGE VARCHAR(500)
);

-- Insert sample users
-- Password is stored as plain text for demo purposes
-- In production, use proper password hashing!
INSERT INTO USERS (USERNAME, EMAIL, PASSWORD, ROLE, ADDRESS) VALUES 
('admin', 'admin@oscp.com', 'admin123', 'seller', '123 Admin Street'),
('customer1', 'customer1@email.com', 'pass123', 'customer', '456 Customer Lane'),
('seller1', 'seller1@email.com', 'pass123', 'seller', '789 Seller Road');

-- Insert sample clothing products
INSERT INTO PRODUCTS (NAME, PRICE, IMAGE) VALUES 
('Cotton T-Shirt', 29.90, ''),
('Denim Jeans', 89.90, ''),
('Summer Dress', 59.90, ''),
('Casual Hoodie', 79.90, ''),
('Sports Shorts', 39.90, ''),
('Formal Shirt', 69.90, ''),
('Maxi Skirt', 49.90, ''),
('Winter Jacket', 149.90, ''),
('Polo Shirt', 45.90, ''),
('Cargo Pants', 75.90, '');

-- Verify data
-- SELECT * FROM USERS;
-- SELECT * FROM PRODUCTS;
