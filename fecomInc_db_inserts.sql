SET SQL_SAFE_UPDATES = 0;
SHOW VARIABLES LIKE 'secure_file_priv';
-- -------------------------------------------------------
-- Cargar datos en la tabla geolocations
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_geolocations.csv' INTO TABLE Geolocations CHARACTER -- MODIFICAR RUTA DE ARCHIVO
SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
  @Geo_Postal_Code,
  @Geo_Lat,
  @Geo_Lon,
  @Geolocation_City,
  @Geo_Country
)
SET Geo_Postal_Code = @Geo_Postal_Code,
  Geo_Lat = REPLACE (@Geo_Lat, ',', '.'),
  Geo_Lon = REPLACE (@Geo_Lon, ',', '.'),
  Geolocation_City = REPLACE (@Geolocation_City, "'", ''),
  Geo_Country = @Geo_Country;
-- -------------------------------------------------------
-- Cargar datos en la tabla products
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_products.csv' INTO TABLE products CHARACTER -- MODIFICAR RUTA DE ARCHIVO
SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (
  Product_ID,
  Product_Category_Name,
  @w,
  @l,
  @h,
  @d
)
SET Product_Weight_Gr = NULLIF (@w, ''),
  Product_Length_Cm = NULLIF (@l, ''),
  Product_Height_Cm = NULLIF (@h, ''),
  Product_Width_Cm = NULLIF (@d, '');
-- -------------------------------------------------------
-- Cargar datos en la tabla sellers
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_sellers.csv' INTO TABLE sellers CHARACTER -- MODIFICAR RUTA DE ARCHIVO
SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- -------------------------------------------------------
-- Cargar datos en la tabla customers
-- -------------------------------------------------------
CREATE TEMPORARY TABLE temp_customers LIKE customers;
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_customers.csv' INTO TABLE temp_customers CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS ( -- MODIFICAR RUTA DE ARCHIVO
  Customer_Trx_ID,
  Subscriber_ID,
  @sub_date,
  @first_order,
  Customer_Postal_Code,
  Age,
  Gender
)
SET Subscribe_Date = IF(
    @sub_date = '',
    NULL,
    STR_TO_DATE(@sub_date, '%Y-%m-%d')
  ),
  First_Order_Date = IF(
    @first_order = '',
    NULL,
    STR_TO_DATE(@first_order, '%Y-%m-%d')
  );
-- -------------------------------------------------------
DELETE FROM temp_customers
WHERE Customer_Trx_ID = ''
  OR Customer_Trx_ID IS NULL;
-- -------------------------------------------------------
INSERT IGNORE INTO customers
SELECT *
FROM temp_customers;
-- -------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_customers;
-- -------------------------------------------------------
-- Cargar datos en la tabla orders
-- -------------------------------------------------------
CREATE TEMPORARY TABLE temp_orders LIKE orders;
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_orders.csv' INTO TABLE temp_orders CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS ( -- MODIFICAR RUTA DE ARCHIVO
  Order_ID,
  Customer_Trx_ID,
  Order_Status,
  @purchase_ts,
  @approved_at,
  @deliv_carrier,
  @deliv_cust,
  @est_deliv
)
SET Order_Purchase_Timestamp = IF(
    @purchase_ts = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@purchase_ts, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Order_Approved_At = IF(
    @approved_at = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@approved_at, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Order_Delivered_Carrier_Date = IF(
    @deliv_carrier = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@deliv_carrier, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Order_Delivered_Customer_Date = IF(
    @deliv_cust = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@deliv_cust, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Order_Estimated_Delivery_Date = IF(
    @est_deliv = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@est_deliv, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  );
-- -------------------------------------------------------
DELETE t
FROM temp_orders t
  LEFT JOIN customers c ON t.Customer_Trx_ID = c.Customer_Trx_ID
WHERE c.Customer_Trx_ID IS NULL;
-- -------------------------------------------------------
INSERT INTO orders
SELECT *
FROM temp_orders;
-- -------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_orders;
-- -------------------------------------------------------
-- Cargar datos en la tabla order_reviews
-- -------------------------------------------------------
CREATE TEMPORARY TABLE temp_order_reviews LIKE order_reviews;
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_ordersReviews.csv' INTO TABLE temp_order_reviews CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS ( -- MODIFICAR RUTA DE ARCHIVO
  Review_ID,
  Order_ID,
  Review_Score,
  Review_Comment_Title_En,
  Review_Comment_Message_En,
  @rev_date,
  @ans_ts
)
SET Review_Creation_Date = IF(
    @rev_date = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@rev_date, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Review_Answer_Timestamp = IF(
    @ans_ts = '',
    NULL,
    STR_TO_DATE(
      REPLACE(REPLACE(@ans_ts, 'T', ' '), '.000Z', ''),
      '%Y-%m-%d %H:%i:%s'
    )
  );
-- -------------------------------------------------------
DELETE tor
FROM temp_order_reviews tor
  LEFT JOIN orders o ON tor.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;
-- -------------------------------------------------------
INSERT INTO order_reviews
SELECT *
FROM temp_order_reviews;
-- -------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_order_reviews;
-- -------------------------------------------------------
-- Cargar datos en la tabla order_payments
-- -------------------------------------------------------
CREATE TEMPORARY TABLE temp_order_payments LIKE order_payments;
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_ordersPayments.csv' INTO TABLE temp_order_payments CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS ( -- MODIFICAR RUTA DE ARCHIVO
  Order_ID,
  Payment_Sequential,
  Payment_Type,
  Payment_Installments,
  @payment_value
)
SET Payment_Value = CAST(@payment_value AS DECIMAL(12, 2));
-- -------------------------------------------------------
DELETE top
FROM temp_order_payments top
  LEFT JOIN orders o ON top.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;
-- -------------------------------------------------------
INSERT INTO order_payments
SELECT *
FROM temp_order_payments;
-- -------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_order_payments;
-- -------------------------------------------------------
-- Cargar datos en la tabla order_items
-- -------------------------------------------------------
CREATE TEMPORARY TABLE temp_order_items LIKE order_items;
-- -------------------------------------------------------
LOAD DATA INFILE '/var/lib/mysql-files/fecomInc_ordersItems.csv' INTO TABLE temp_order_items CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS ( -- MODIFICAR RUTA DE ARCHIVO
  Order_ID,
  Order_Item_ID,
  Product_ID,
  Seller_ID,
  @shipping_limit_date,
  @price,
  @freight_value
)
SET Shipping_Limit_Date = IF(
    @shipping_limit_date = '',
    NULL,
    STR_TO_DATE(
      REPLACE(
        REPLACE(@shipping_limit_date, 'T', ' '),
        '.000Z',
        ''
      ),
      '%Y-%m-%d %H:%i:%s'
    )
  ),
  Price = IF(
    @price = '',
    NULL,
    CAST(@price AS DECIMAL(12, 2))
  ),
  Freight_Value = IF(
    @freight_value = '',
    NULL,
    CAST(@freight_value AS DECIMAL(12, 2))
  );
-- -------------------------------------------------------
DELETE toi
FROM temp_order_items toi
  LEFT JOIN orders o ON toi.Order_ID = o.Order_ID
  LEFT JOIN products p ON toi.Product_ID = p.Product_ID
  LEFT JOIN sellers s ON toi.Seller_ID = s.Seller_ID
WHERE o.Order_ID IS NULL
  OR p.Product_ID IS NULL
  OR s.Seller_ID IS NULL;
-- -------------------------------------------------------
INSERT INTO order_items
SELECT *
FROM temp_order_items;
-- -------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS temp_order_items;