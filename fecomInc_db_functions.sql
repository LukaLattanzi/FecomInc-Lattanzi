-- -------------------------------------------------------
-- Función 1: Calcular volumen de un producto
-- -------------------------------------------------------
DELIMITER $$ CREATE FUNCTION calcular_volumen_producto(producto_id VARCHAR(255)) RETURNS DECIMAL(12, 2) DETERMINISTIC BEGIN
DECLARE largo DECIMAL(12, 2);
DECLARE alto DECIMAL(12, 2);
DECLARE ancho DECIMAL(12, 2);
DECLARE volumen DECIMAL(12, 2);
SELECT IFNULL(Product_Length_Cm, 0),
    IFNULL(Product_Height_Cm, 0),
    IFNULL(Product_Width_Cm, 0) INTO largo,
    alto,
    ancho
FROM products
WHERE Product_ID = producto_id;
SET volumen = largo * alto * ancho;
RETURN volumen;
END $$ DELIMITER;
-- -------------------------------------------------------
-- Función 2: Obtener el país de un cliente
-- -------------------------------------------------------
DELIMITER $$ CREATE FUNCTION obtener_pais_cliente(trx_id VARCHAR(255)) RETURNS VARCHAR(255) DETERMINISTIC BEGIN
DECLARE codigo_postal VARCHAR(255);
DECLARE pais VARCHAR(255);
SELECT Customer_Postal_Code INTO codigo_postal
FROM customers
WHERE Customer_Trx_ID = trx_id;
SELECT Geo_Country INTO pais
FROM Geolocations
WHERE Geo_Postal_Code = codigo_postal;
RETURN pais;
END $$ DELIMITER;