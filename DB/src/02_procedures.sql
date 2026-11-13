USE logiexpress;

-- Procedimiento 1

DROP PROCEDURE IF EXISTS sp_reporte_mensual_cliente;

DELIMITER //

CREATE PROCEDURE sp_reporte_mensual_cliente(
    IN p_id_cliente INT,
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT (
		SELECT SUM(costo_total)
        FROM envios
        WHERE YEAR(fecha) = p_anio
        AND MONTH(fecha) = p_mes
        AND id_remitente = p_id_cliente
        AND status_global != "CANCELADO"
    ) AS total_facturado, (
		SELECT COUNT(*)
        FROM envios
        WHERE YEAR(fecha) = p_anio
        AND MONTH(fecha) = p_mes
        AND id_remitente = p_id_cliente
        AND status_global = "ENTREGADO"
    ) AS envios_entregados, (
		SELECT AVG(TIMESTAMPDIFF(HOUR, e.fecha, hr.fecha))
        FROM envios e 
        JOIN historial_rastreo hr 
        ON e.id = hr.id_envio
        WHERE YEAR(e.fecha) = p_anio
        AND MONTH(e.fecha) = p_mes
        AND e.id_remitente = p_id_cliente
        AND hr.status_evento = "ENTREGADO"
    ) AS tiempo_promedio;
END //

DELIMITER ;

-- Procedimiento 2

DROP PROCEDURE IF EXISTS sp_obtener_hoja_ruta_envio;

DELIMITER //

CREATE PROCEDURE sp_obtener_hoja_ruta_envio(IN p_envio_id INT)
BEGIN
    SELECT e.id AS id_envio,
        e.status_global,
        CONCAT(rem.nombres, ' ', rem.apellidos) AS remitente,
        CONCAT(des.nombres, ' ', des.apellidos) AS destinatario,
        p.id AS id_paquete,
        p.contenido,
        p.peso,
        p.alto,
        p.largo,
        p.ancho,
        a.nombre AS almacen_actual
    FROM envios e
    JOIN clientes rem ON e.id_remitente = rem.id
    JOIN clientes des ON e.id_destinatario = des.id
    LEFT JOIN paquetes p ON p.id_envio = e.id
    LEFT JOIN almacenes a ON p.id_almacen = a.id
    WHERE e.id = p_envio_id
    ORDER BY p.id;

    SELECT hr.fecha,
        hr.ubicacion_actual,
        hr.status_evento,
        hr.observaciones
    FROM historial_rastreo hr
    WHERE hr.id_envio = p_envio_id
    ORDER BY hr.fecha, hr.id;
END //

DELIMITER ;