-- -------------------------------------------------------
-- Stored Procedure 1: Listar productos con ordenamiento dinámico
-- -------------------------------------------------------
DELIMITER $$ CREATE PROCEDURE sp_listar_productos_ordenados (
    IN campo_orden VARCHAR(255),
    -- Campo por el cual se desea ordenar
    IN tipo_orden VARCHAR(10) -- 'ASC' para ascendente o 'DESC' para descendente
) BEGIN -- Procedimiento que devuelve todos los productos, ordenados dinámicamente
-- según el campo y el tipo de orden indicados como parámetros.
SET @query = CONCAT(
        'SELECT Product_ID, Product_Category_Name, Product_Weight_Gr, ',
        'Product_Length_Cm, Product_Height_Cm, Product_Width_Cm ',
        'FROM products ORDER BY ',
        campo_orden,
        ' ',
        tipo_orden,
        ';'
    );
PREPARE stmt
FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END $$ DELIMITER;
-- -------------------------------------------------------
-- Stored Procedure 2: Actualizar el peso de un producto con control de valores inválidos
-- -------------------------------------------------------
DELIMITER $$ CREATE PROCEDURE sp_actualizar_peso_producto (
    IN producto_id VARCHAR(255),
    IN nuevo_peso DECIMAL(12, 2)
) BEGIN -- Este procedimiento actualiza el peso de un producto,
-- siempre que el nuevo peso sea positivo y el producto exista.
DECLARE existe INT;
-- Verificamos si el producto existe
SELECT COUNT(*) INTO existe
FROM products
WHERE Product_ID = producto_id;
IF existe = 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Error: El producto no existe.';
ELSEIF nuevo_peso <= 0 THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Error: El peso debe ser mayor a cero.';
ELSE
UPDATE products
SET Product_Weight_Gr = nuevo_peso
WHERE Product_ID = producto_id;
END IF;
END $$ DELIMITER;
-- -------------------------------------------------------
CALL sp_listar_productos_ordenados('Product_Weight_Gr', 'DESC');
CALL sp_listar_productos_ordenados('Product_Length_Cm', 'ASC');
CALL sp_actualizar_peso_producto('7bb6f29c2be57716194f96496660c7c2', 500.00);
-- -------------------------------------------------------