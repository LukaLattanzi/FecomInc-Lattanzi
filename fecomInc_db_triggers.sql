-- -------------------------------------------------------
-- Trigger 1: Registro de fecha de modificación en tabla orders cuando cambia el estado
-- -------------------------------------------------------
DELIMITER $$
CREATE TRIGGER tr_actualizar_fecha_orden
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    -- Si el status cambió, actualizamos la fecha de aprobación
    IF NEW.Order_Status <> OLD.Order_Status THEN
        SET NEW.Order_Approved_At = NOW();
    END IF;
END$$
DELIMITER ;
-- -------------------------------------------------------
-- Trigger 2: Evitar que se inserten órdenes sin cliente asociado
-- -------------------------------------------------------
DELIMITER $$
CREATE TRIGGER tr_validar_cliente_en_orden
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    -- Validamos que el campo Customer_ID no sea nulo o vacío
    IF NEW.Customer_Trx_ID IS NULL OR TRIM(NEW.Customer_Trx_ID) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede crear una orden sin un cliente asociado.';
    END IF;
END$$
DELIMITER ;