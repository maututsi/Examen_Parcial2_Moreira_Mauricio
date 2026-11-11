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
    SELECT e.id as id_envio, 
    c.nombres AS nombre_remitente, 
    c.apellidos AS apellidos_remitente, 
    (SELECT nombres FROM clientes WHERE id = e.id_destinatario) AS nombre_destinatario, 
    (SELECT apellidos FROM clientes WHERE id = e.id_destinatario) AS apellidos_destinatario, 
    hr.fecha,
    a.id AS id_almacen_actual,
    a.nombre AS almacen_actual,
    hr.status_evento,
    hr.observaciones,
    p.id AS id_paquete,
    p.contenido,
    p.peso,
    p.alto,
    p.largo,
    p.ancho
    FROM historial_rastreo hr
    JOIN paquete_almacen pa ON hr.id_paquete_almacen = pa.id
    JOIN paquetes p ON pa.id_paquete = p.id
    JOIN almacenes a ON pa.id_almacen = a.id
    JOIN envios e ON hr.id_envio = e.id
    JOIN clientes c ON e.id_remitente = c.id
    WHERE e.id = p_envio_id
    ORDER BY hr.fecha, p.id;
END //

DELIMITER ;