-- -------------------------------------------------------
-- Crear la base de datos y usarla
-- -------------------------------------------------------
CREATE DATABASE fecom_inc;
USE fecom_inc;
-- -------------------------------------------------------
-- Tabla de Geolocalizaciones
-- -------------------------------------------------------
CREATE TABLE Geolocations (
    Geo_Postal_Code VARCHAR(255) PRIMARY KEY,
    Geo_Lat DECIMAL(9, 6),
    Geo_Lon DECIMAL(9, 6),
    Geolocation_City VARCHAR(255),
    Geo_Country VARCHAR(255)
);
-- -------------------------------------------------------
-- Tabla de Productos
-- -------------------------------------------------------
CREATE TABLE products (
    Product_ID VARCHAR(255) PRIMARY KEY,
    Product_Category_Name VARCHAR(255),
    Product_Weight_Gr DECIMAL(12, 2) NULL,
    Product_Length_Cm DECIMAL(12, 2) NULL,
    Product_Height_Cm DECIMAL(12, 2) NULL,
    Product_Width_Cm DECIMAL(12, 2) NULL
);
-- -------------------------------------------------------
-- Tabla de Vendedores
-- -------------------------------------------------------
CREATE TABLE sellers (
    Seller_ID VARCHAR(255) PRIMARY KEY,
    Seller_Name VARCHAR(255),
    Seller_Postal_Code VARCHAR(255),
    FOREIGN KEY (Seller_Postal_Code) REFERENCES Geolocations(Geo_Postal_Code)
);
-- -------------------------------------------------------
-- Tabla de Clientes
-- -------------------------------------------------------
CREATE TABLE customers (
    Customer_Trx_ID VARCHAR(255) PRIMARY KEY,
    Subscriber_ID VARCHAR(255),
    Subscribe_Date DATE,
    First_Order_Date DATE,
    Customer_Postal_Code VARCHAR(255),
    Age INT,
    Gender VARCHAR(255),
    FOREIGN KEY (Customer_Postal_Code) REFERENCES Geolocations(Geo_Postal_Code)
);
-- -------------------------------------------------------
-- Tabla de Pedidos
-- -------------------------------------------------------
CREATE TABLE orders (
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
-- -------------------------------------------------------
-- Tabla de Reseñas de Pedidos
-- -------------------------------------------------------
CREATE TABLE order_reviews (
    Review_ID VARCHAR(255) PRIMARY KEY,
    Order_ID VARCHAR(255),
    Review_Score INT,
    Review_Comment_Title_En TEXT,
    Review_Comment_Message_En TEXT,
    Review_Creation_Date DATETIME,
    Review_Answer_Timestamp DATETIME,
    FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID)
);
-- -------------------------------------------------------
-- Tabla de Pagos por Pedido
-- -------------------------------------------------------
CREATE TABLE order_payments (
    Order_ID VARCHAR(255),
    Payment_Sequential INT,
    Payment_Type VARCHAR(100),
    Payment_Installments INT,
    Payment_Value DECIMAL(12, 2),
    PRIMARY KEY (Order_ID, Payment_Sequential),
    FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID)
);
-- -------------------------------------------------------
-- Tabla de Items por Pedido
-- -------------------------------------------------------
CREATE TABLE order_items (
    Order_ID VARCHAR(255),
    Order_Item_ID INT,
    Product_ID VARCHAR(255),
    Seller_ID VARCHAR(255),
    Shipping_Limit_Date DATETIME,
    Price DECIMAL(12, 2),
    Freight_Value DECIMAL(12, 2),
    PRIMARY KEY (Order_ID, Order_Item_ID),
    FOREIGN KEY (Order_ID) REFERENCES orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES products(Product_ID),
    FOREIGN KEY (Seller_ID) REFERENCES sellers(Seller_ID)
);