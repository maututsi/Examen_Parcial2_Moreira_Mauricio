USE logiexpress;

DROP TRIGGER IF EXISTS after_update_envio_costo;

DELIMITER //

CREATE TRIGGER after_update_envio_costo
AFTER UPDATE ON envios
FOR EACH ROW
BEGIN
    IF OLD.costo_total != NEW.costo_total THEN
        INSERT INTO auditoria_envios (id_envio, costo_anterior, costo_nuevo, usuario, fecha_modificacion)
        VALUES (OLD.id, OLD.costo_total, NEW.costo_total, CURRENT_USER(), NOW());
    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS before_insert_paquete_almacen;

DELIMITER //

CREATE TRIGGER before_insert_paquete_almacen
BEFORE INSERT ON paquetes
FOR EACH ROW
BEGIN
    DECLARE v_ocupacion INT;
    DECLARE v_capacidad INT;

    IF NEW.id_almacen IS NOT NULL THEN

        SELECT COUNT(*) INTO v_ocupacion
        FROM paquetes
        WHERE id_almacen = NEW.id_almacen;

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
        WHERE id = NEW.id_envio;

        UPDATE paquetes
        SET id_almacen = NULL
        WHERE id_envio = NEW.id_envio;
    END IF;
END //

DELIMITER ;