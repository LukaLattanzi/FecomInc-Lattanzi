-- -------------------------------------------------------
-- Vista 1: Información completa de clientes con su ubicación
-- -------------------------------------------------------
CREATE VIEW vista_clientes_ubicacion AS
SELECT c.Customer_Trx_ID,
    c.Age,
    c.Gender,
    c.Subscribe_Date,
    c.First_Order_Date,
    g.Geolocation_City,
    g.Geo_Country
FROM customers c
    JOIN Geolocations g ON c.Customer_Postal_Code = g.Geo_Postal_Code;
-- -------------------------------------------------------
-- Vista 2: Vendedores y su ubicación detallada
-- -------------------------------------------------------
CREATE VIEW vista_vendedores_ubicacion AS
SELECT s.Seller_ID,
    s.Seller_Name,
    g.Geolocation_City,
    g.Geo_Country,
    g.Geo_Lat,
    g.Geo_Lon
FROM sellers s
    JOIN Geolocations g ON s.Seller_Postal_Code = g.Geo_Postal_Code;
-- -------------------------------------------------------
-- Vista 3: Productos con volumen y peso
-- -------------------------------------------------------
CREATE VIEW vista_productos_detalle AS
SELECT Product_ID,
    Product_Category_Name,
    Product_Weight_Gr,
    Product_Length_Cm,
    Product_Height_Cm,
    Product_Width_Cm,
    (
        Product_Length_Cm * Product_Height_Cm * Product_Width_Cm
    ) AS Volumen_Cubico_cm3
FROM products;
-- -------------------------------------------------------
-- Vista 4: Clientes por rango etario
-- -------------------------------------------------------
CREATE VIEW vista_clientes_rango_etario AS
SELECT CASE
        WHEN Age < 18 THEN 'Menor de edad'
        WHEN Age BETWEEN 18 AND 29 THEN '18-29'
        WHEN Age BETWEEN 30 AND 44 THEN '30-44'
        WHEN Age BETWEEN 45 AND 60 THEN '45-60'
        ELSE '60+'
    END AS Rango_Edad,
    COUNT(*) AS Cantidad_Clientes
FROM customers
GROUP BY Rango_Edad;
-- -------------------------------------------------------
-- Vista 5: Clientes con tiempo de conversión desde suscripción a primera orden
-- -------------------------------------------------------
CREATE VIEW vista_tiempo_conversion AS
SELECT Customer_Trx_ID,
    DATEDIFF(First_Order_Date, Subscribe_Date) AS Dias_Hasta_Primera_Compra
FROM customers
WHERE First_Order_Date IS NOT NULL
    AND Subscribe_Date IS NOT NULL;