-- -------------------------------------------------------
-- Crear la base de datos y usarla
-- -------------------------------------------------------
CREATE DATABASE fecom_inc;
USE fecom_inc;

-- Mostrar la ubicación de la carpeta segura para archivos
SHOW VARIABLES LIKE 'secure_file_priv';

-- Desactivar las actualizaciones seguras temporalmente
SET SQL_SAFE_UPDATES
= 0;

-- -------------------------------------------------------
-- Tabla de Geolocalizaciones
-- -------------------------------------------------------
CREATE TABLE Geolocations
(
  Geo_Postal_Code VARCHAR(255) PRIMARY KEY,
  Geo_Lat DECIMAL(9,6),
  Geo_Lon DECIMAL(9,6),
  Geolocation_City VARCHAR(255),
  Geo_Country VARCHAR(255)
);

-- Cargar datos en la tabla Geolocations
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-geolocations-2025-04-10.csv'
INTO TABLE Geolocations
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@Geo_Postal_Code, @Geo_Lat, @Geo_Lon, @Geolocation_City, @Geo_Country)
SET 
  Geo_Postal_Code
= @Geo_Postal_Code,
  Geo_Lat = REPLACE
(@Geo_Lat, ',', '.'),
  Geo_Lon = REPLACE
(@Geo_Lon, ',', '.'),
  Geolocation_City = REPLACE
(@Geolocation_City, "'", ''),
  Geo_Country = @Geo_Country;

-- -------------------------------------------------------
-- Tabla de Productos
-- -------------------------------------------------------
CREATE TABLE products
(
  Product_ID VARCHAR(255) PRIMARY KEY,
  Product_Category_Name VARCHAR(255),
  Product_Weight_Gr DECIMAL(12,2) NULL,
  Product_Length_Cm DECIMAL(12,2) NULL,
  Product_Height_Cm DECIMAL(12,2) NULL,
  Product_Width_Cm DECIMAL(12,2) NULL
);

-- Cargar datos en la tabla Products
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-products-2025-04-10.csv'
INTO TABLE products
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Product_ID, Product_Category_Name, @w, @l, @h, @d)
SET 
  Product_Weight_Gr
= NULLIF
(@w, ''),
  Product_Length_Cm = NULLIF
(@l, ''),
  Product_Height_Cm = NULLIF
(@h, ''),
  Product_Width_Cm  = NULLIF
(@d, '');

-- -------------------------------------------------------
-- Tabla de Vendedores
-- -------------------------------------------------------
CREATE TABLE sellers
(
  Seller_ID VARCHAR(255) PRIMARY KEY,
  Seller_Name VARCHAR(255),
  Seller_Postal_Code VARCHAR(255),
  FOREIGN KEY (Seller_Postal_Code) REFERENCES Geolocations(Geo_Postal_Code)
);

-- Cargar datos en la tabla Sellers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-sellers-list-2025-04-10.csv'
INTO TABLE sellers
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- -------------------------------------------------------
-- Tabla de Clientes
-- -------------------------------------------------------
CREATE TABLE customers
(
  Customer_Trx_ID VARCHAR(255) PRIMARY KEY,
  Subscriber_ID VARCHAR(255),
  Subscribe_Date DATE,
  First_Order_Date DATE,
  Customer_Postal_Code VARCHAR(255),
  Age INT,
  Gender VARCHAR(255),
  FOREIGN KEY (Customer_Postal_Code) REFERENCES Geolocations(Geo_Postal_Code)
);

-- Cargar datos en la tabla Customers
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-customer-list-2025-04-10.csv'
INTO TABLE customers
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_Trx_ID, Subscriber_ID, @sub_date, @first_order, Customer_Postal_Code, Age, Gender)
SET
  Subscribe_Date
=
IF(@sub_date = '', NULL, STR_TO_DATE
(@sub_date, '%Y-%m-%d')),
  First_Order_Date =
IF(@first_order = '', NULL, STR_TO_DATE
(@first_order, '%Y-%m-%d'));

-- -------------------------------------------------------
-- Tabla de Pedidos
-- -------------------------------------------------------
CREATE TABLE orders
(
  Order_ID VARCHAR(255) PRIMARY KEY,
  Customer_Trx_ID VARCHAR(255),
  Order_Status VARCHAR(255),
  Order_Purchase_Timestamp DATETIME,
  Order_Approved_At DATETIME,
  Order_Delivered_Carrier_Date DATETIME,
  Order_Delivered_Customer_Date DATETIME,
  Order_Estimated_Delivery_Date DATETIME,
  FOREIGN KEY (Customer_Trx_ID) REFERENCES customers(Customer_Trx_ID)
);

-- Crear tabla temporal para cargar datos de pedidos
CREATE TEMPORARY TABLE temp_orders LIKE orders;

-- Cargar datos en la tabla temporal de pedidos
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-orders-2025-04-10.csv'
INTO TABLE temp_orders
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Customer_Trx_ID, Order_Status, @purchase_ts, @approved_at, @deliv_carrier, @deliv_cust, @est_deliv)
SET
  Order_Purchase_Timestamp
=
IF(@purchase_ts = '', NULL, STR_TO_DATE
(@purchase_ts, '%Y-%m-%d %H:%i:%s')),
  Order_Approved_At =
IF(@approved_at = '', NULL, STR_TO_DATE
(@approved_at, '%Y-%m-%d %H:%i:%s')),
  Order_Delivered_Carrier_Date =
IF(@deliv_carrier = '', NULL, STR_TO_DATE
(@deliv_carrier, '%Y-%m-%d %H:%i:%s')),
  Order_Delivered_Customer_Date =
IF(@deliv_cust = '', NULL, STR_TO_DATE
(@deliv_cust, '%Y-%m-%d %H:%i:%s')),
  Order_Estimated_Delivery_Date =
IF(@est_deliv = '', NULL, STR_TO_DATE
(@est_deliv, '%Y-%m-%d %H:%i:%s'));

-- Eliminar registros con Customer_Trx_ID inexistentes
DELETE temp_orders
FROM temp_orders
  LEFT JOIN customers ON temp_orders.Customer_Trx_ID = customers.Customer_Trx_ID
WHERE customers.Customer_Trx_ID IS NULL;

-- Insertar datos válidos en la tabla real de pedidos
INSERT INTO orders
SELECT *
FROM temp_orders;

-- -------------------------------------------------------
-- Tabla de Reseñas de Pedidos
-- -------------------------------------------------------
CREATE TABLE order_reviews
(
  Review_ID VARCHAR(255) PRIMARY KEY,
  Order_ID VARCHAR(255),
  Review_Score INT,
  Review_Comment_Title_En TEXT,
  Review_Comment_Message_En TEXT,
  Review_Creation_Date DATETIME,
  Review_Answer_Timestamp DATETIME,
  FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID)
);

-- Crear tabla temporal para cargar datos de reseñas
CREATE TEMPORARY TABLE temp_order_reviews LIKE order_reviews;

-- Cargar datos en la tabla temporal de reseñas
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-order-reviews-no-emojis-2025-04-10.csv'
INTO TABLE temp_order_reviews
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Review_ID, Order_ID, Review_Score, Review_Comment_Title_En, Review_Comment_Message_En, @rev_date, @ans_ts)
SET
  Review_Creation_Date
=
IF(@rev_date = '', NULL, STR_TO_DATE
(@rev_date, '%Y-%m-%d %H:%i:%s')),
  Review_Answer_Timestamp =
IF(@ans_ts = '', NULL, STR_TO_DATE
(@ans_ts, '%Y-%m-%d %H:%i:%s'));

-- Eliminar registros con Order_ID inexistentes
DELETE temp_order_reviews
FROM temp_order_reviews
  LEFT JOIN orders ON temp_order_reviews.Order_ID = orders.Order_ID
WHERE orders.Order_ID IS NULL;

-- Insertar datos válidos en la tabla real de reseñas
INSERT INTO order_reviews
SELECT *
FROM temp_order_reviews;

-- -------------------------------------------------------
-- Tabla de Pagos por Pedido
-- -------------------------------------------------------
CREATE TABLE order_payments
(
  Order_ID VARCHAR(255),
  Payment_Sequential INT,
  Payment_Type VARCHAR(100),
  Payment_Installments INT,
  Payment_Value DECIMAL(12,2),
  PRIMARY KEY (Order_ID, Payment_Sequential),
  FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID)
);

-- Crear tabla temporal para cargar datos de pagos
CREATE TEMPORARY TABLE temp_order_payments LIKE order_payments;

-- Cargar datos en la tabla temporal de pagos
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-order-payments-2025-04-10.csv'
INTO TABLE temp_order_payments
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Payment_Sequential, Payment_Type, Payment_Installments, Payment_Value);

-- Eliminar registros con Order_ID inexistentes
DELETE temp_order_payments
FROM temp_order_payments
  LEFT JOIN orders ON temp_order_payments.Order_ID = orders.Order_ID
WHERE orders.Order_ID IS NULL;

-- Insertar datos válidos en la tabla real de pagos
INSERT INTO order_payments
SELECT *
FROM temp_order_payments;

-- -------------------------------------------------------
-- Tabla de Items por Pedido
-- -------------------------------------------------------
CREATE TABLE order_items
(
  Order_ID VARCHAR(255),
  Order_Item_ID INT,
  Product_ID VARCHAR(255),
  Seller_ID VARCHAR(255),
  Shipping_Limit_Date DATETIME,
  Price DECIMAL(12,2),
  Freight_Value DECIMAL(12,2),
  PRIMARY KEY (Order_ID, Order_Item_ID),
  FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID),
  FOREIGN KEY (Product_ID) REFERENCES products(Product_ID),
  FOREIGN KEY (Seller_ID) REFERENCES sellers(Seller_ID)
);

-- Crear tabla temporal para cargar datos de items
CREATE TEMPORARY TABLE temp_order_items LIKE order_items;

-- Cargar datos en la tabla temporal de items
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fecom_inc_db/fecom-inc-order-items-2025-04-10.csv'
INTO TABLE temp_order_items
CHARACTER
SET utf8mb4
FIELDS
TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Order_Item_ID, Product_ID, Seller_ID, Shipping_Limit_Date, Price, Freight_Value);

-- Eliminar registros con claves foráneas inválidas
DELETE temp_order_items
FROM temp_order_items
  LEFT JOIN orders ON temp_order_items.Order_ID = orders.Order_ID
  LEFT JOIN products ON temp_order_items.Product_ID = products.Product_ID
  LEFT JOIN sellers ON temp_order_items.Seller_ID = sellers.Seller_ID
WHERE orders.Order_ID IS NULL
  OR products.Product_ID IS NULL
  OR sellers.Seller_ID IS NULL;

-- Insertar datos válidos en la tabla real de items
INSERT INTO order_items
SELECT *
FROM temp_order_items;
