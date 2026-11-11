USE logiexpress;

DROP TRIGGER IF EXISTS after_update_envio_costo;

DELIMITER //

CREATE TRIGGER after_update_envio_costo
AFTER UPDATE ON envios
FOR EACH ROW
BEGIN
    IF OLD.costo_total != NEW.costo_total THEN
        INSERT INTO auditoria_envios (id_envio, costo_anterior, costo_nuevo, fecha_modificacion)
        VALUES (OLD.id, OLD.costo_total, NEW.costo_total, CURDATE());
    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS before_insert_paquete_almacen;

DELIMITER //

CREATE TRIGGER before_insert_paquete_almacen
BEFORE INSERT ON paquete_almacen
FOR EACH ROW
BEGIN
    DECLARE v_ocupacion INT;
    DECLARE v_capacidad INT;

    IF NEW.fecha_salida IS NULL THEN

        SELECT COUNT(*) INTO v_ocupacion
        FROM paquete_almacen
        WHERE id_almacen = NEW.id_almacen
        AND fecha_salida IS NULL;

        SELECT capacidad_maxima INTO v_capacidad
        FROM almacenes
        WHERE id = NEW.id_almacen;

        IF v_ocupacion >= v_capacidad THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'El almacen alcanzo su capacidad maxima';
        END IF;

    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS after_insert_historial_rastreo;

DELIMITER //

CREATE TRIGGER after_insert_historial_rastreo
AFTER INSERT ON historial_rastreo
FOR EACH ROW
BEGIN
    IF NEW.status_evento = "ENTREGADO" THEN
        UPDATE envios 
        SET status_global = "ENTREGADO" 
        WHERE id = NEW.id_envio 
    END IF;
END //

DELIMITER ;