-- DatabaseSetup

-- in netbeans create database
-- put the name as Clothing_store2
-- username "root"
-- password "root"
-- just copy everything and paste in executable command 

-- 1. CREATE USERS TABLE
CREATE TABLE users (
  user_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1,INCREMENT BY 1),
  username VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'customer',
  address CLOB,
  phone VARCHAR(20) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  UNIQUE (username),
  UNIQUE (email)
);

-- 2. INSERT USERS DATA
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('john_doe','john@email.com','password123','customer','123 Main St, New York, NY 10001','555-0101',TIMESTAMP('2026-01-03 11:14:38'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('jane_smith','jane@email.com','password123','customer','456 Oak Ave, Los Angeles, CA 90001','555-0102',TIMESTAMP('2026-01-03 11:14:38'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('mike_wilson','mike@email.com','password123','customer','789 Pine Rd, Chicago, IL 60601','555-0103',TIMESTAMP('2026-01-03 11:14:38'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('sarah_jones','sarah@email.com','password123','customer','321 Elm St, Houston, TX 77001','555-0104',TIMESTAMP('2026-01-03 11:14:38'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('admin','admin@email.com','admin123','admin','999 Admin Blvd, Seattle, WA 98101','555-0100',TIMESTAMP('2026-01-03 11:14:38'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('a','a@gmail.com','a','customer','a',NULL,TIMESTAMP('2026-01-03 11:15:23'));
INSERT INTO users (username, email, password, role, address, phone, created_at) VALUES ('b','b@gmail.com','b','seller','b',NULL,TIMESTAMP('2026-01-03 11:27:45'));

-- 3. CREATE PRODUCTS TABLE
CREATE TABLE products (
  product_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image VARCHAR(500) DEFAULT NULL,
  seller_username VARCHAR(100) NOT NULL,
  category VARCHAR(100) DEFAULT NULL,
  description CLOB,
  stock_quantity INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  product_type VARCHAR(100) DEFAULT NULL,
  size VARCHAR(50) DEFAULT NULL,
  color VARCHAR(100) DEFAULT NULL,
  brand VARCHAR(100) DEFAULT NULL,
  material VARCHAR(100) DEFAULT NULL,
  rating DECIMAL(3,2) DEFAULT 0.00,
  in_stock SMALLINT DEFAULT 1,
  PRIMARY KEY (product_id),
  FOREIGN KEY (seller_username) REFERENCES users(username) ON DELETE CASCADE
);

CREATE INDEX idx_products_seller ON products(seller_username);
CREATE INDEX idx_products_category ON products(category);

-- 4. INSERT PRODUCTS DATA
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Classic White T-Shirt',29.99,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400','john_doe','Tops','Comfortable cotton t-shirt',50,TIMESTAMP('2026-01-03 11:14:38'),'Tops (T-shirts, Shirts, Blouses)','M','White','Generic','Cotton',4.50,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Black Denim Jeans',79.99,'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400','john_doe','Bottoms','Stylish black jeans',30,TIMESTAMP('2026-01-03 11:14:38'),'Bottoms (Jeans, Pants, Shorts, Skirts)','32','Black','Denim Co','Denim',4.80,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Casual Hoodie',49.99,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400','john_doe','Tops','Warm and cozy hoodie',40,TIMESTAMP('2026-01-03 11:14:38'),'Outerwear (Jackets, Coats, Hoodies)','L','Black','SportWear','Polyester',4.60,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Summer Dress',59.99,'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400','jane_smith','Dresses','Light summer dress',25,TIMESTAMP('2026-01-03 11:14:38'),'Dresses','M','Multi-color','Fashion Plus','Cotton',4.70,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Leather Jacket',149.99,'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400','jane_smith','Jackets','Premium leather jacket',15,TIMESTAMP('2026-01-03 11:14:38'),'Outerwear (Jackets, Coats, Hoodies)','L','Brown','Leather Elite','Leather',4.90,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Floral Skirt',39.99,'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=400','jane_smith','Bottoms','Beautiful floral pattern',35,TIMESTAMP('2026-01-03 11:14:38'),NULL,NULL,NULL,NULL,NULL,0.00,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Sneakers',89.99,'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400','mike_wilson','Shoes','Comfortable sneakers',60,TIMESTAMP('2026-01-03 11:14:38'),'Accessories (Hats, Scarves, Belts)','M','White','Nike','Polyester',4.80,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Running Shoes',119.99,'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400','mike_wilson','Shoes','Professional running shoes',45,TIMESTAMP('2026-01-03 11:14:38'),NULL,NULL,NULL,NULL,NULL,0.00,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Boots',139.99,'https://images.unsplash.com/photo-1605812860427-4024433a70fd?w=400','mike_wilson','Shoes','Durable winter boots',20,TIMESTAMP('2026-01-03 11:14:38'),NULL,NULL,NULL,NULL,NULL,0.00,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Wool Sweater',69.99,'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=400','sarah_jones','Tops','Warm wool sweater',30,TIMESTAMP('2026-01-03 11:14:38'),'Tops (T-shirts, Shirts, Blouses)','M','Gray','Wool Works','Wool',4.50,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Casual Shirt',39.99,'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400','sarah_jones','Tops','Everyday casual shirt',55,TIMESTAMP('2026-01-03 11:14:38'),'Tops (T-shirts, Shirts, Blouses)','M','Blue','Casual Wear','Cotton',4.40,1);
INSERT INTO products (name, price, image, seller_username, category, description, stock_quantity, created_at, product_type, size, color, brand, material, rating, in_stock) VALUES ('Winter Coat',179.99,'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400','sarah_jones','Jackets','Heavy winter coat',18,TIMESTAMP('2026-01-03 11:14:38'),NULL,NULL,NULL,NULL,NULL,0.00,1);

-- 5. CREATE CARTS TABLE
CREATE TABLE carts (
  cart_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  customer_username VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (cart_id),
  UNIQUE (customer_username),
  FOREIGN KEY (customer_username) REFERENCES users(username) ON DELETE CASCADE
);

-- 6. CREATE CART_ITEMS TABLE
CREATE TABLE cart_items (
  cart_item_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (cart_item_id),
  UNIQUE (cart_id, product_id),
  FOREIGN KEY (cart_id) REFERENCES carts(cart_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. CREATE ORDERS TABLE
CREATE TABLE orders (
  id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  user_username VARCHAR(100) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) NOT NULL,
  payment_method VARCHAR(50) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

-- 8. INSERT ORDERS DATA
INSERT INTO orders (user_username, total_amount, status, created_at) VALUES ('a',139.99,'Pending',TIMESTAMP('2026-01-03 15:03:11'));
INSERT INTO orders (user_username, total_amount, status, created_at) VALUES ('a',49.99,'Pending',TIMESTAMP('2026-01-03 16:16:33'));

-- 9. CREATE ORDER_ITEMS TABLE
CREATE TABLE order_items (
  id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  seller_username VARCHAR(100) DEFAULT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX fk_order_items_order ON order_items(order_id);

-- 10. INSERT ORDER_ITEMS DATA
INSERT INTO order_items (order_id, product_id, product_name, seller_username, quantity, price) VALUES (1,9,'Boots','',1,139.99);
INSERT INTO order_items (order_id, product_id, product_name, seller_username, quantity, price) VALUES (2,3,'Casual Hoodie','',1,49.99);

-- 11. CREATE PAYMENTS TABLE
CREATE TABLE payments (
  payment_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  order_id INT NOT NULL,
  payment_method VARCHAR(10) NOT NULL CHECK (payment_method IN ('online','cash')),
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(10) DEFAULT 'pending' CHECK (status IN ('pending','completed','failed')),
  paid_at TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (payment_id),
  FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 12. CREATE CASH_PAYMENTS TABLE
CREATE TABLE cash_payments (
  cash_payment_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  payment_id INT NOT NULL,
  cash_tendered DECIMAL(10,2) DEFAULT NULL,
  PRIMARY KEY (cash_payment_id),
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

-- 13. CREATE ONLINE_PAYMENTS TABLE
CREATE TABLE online_payments (
  online_payment_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  payment_id INT NOT NULL,
  bank_name VARCHAR(100) DEFAULT NULL,
  account_number VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (online_payment_id),
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

-- 14. CREATE REVIEWS TABLE
CREATE TABLE reviews (
  review_id INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  product_id INT NOT NULL,
  user_id INT NOT NULL,
  rating INT DEFAULT NULL CHECK (rating BETWEEN 1 AND 5),
  comment CLOB,
  review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (review_id),
  UNIQUE (product_id, user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE ORDER_TRACKING (
    TRACKING_ID INT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) PRIMARY KEY,
    ORDER_ID INT NOT NULL,
    CURRENT_LOCATION VARCHAR(200),
    ESTIMATED_DELIVERY TIMESTAMP,
    LAST_UPDATED TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);