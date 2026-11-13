-- =============================================================
-- Seed de datos de prueba: cliente "Carlos Ramírez López"
-- Incluye su dirección, envíos (como remitente y destinatario),
-- paquetes, almacenes e historial de rastreo.
-- Los envíos abarcan sep-nov 2026 para probar
-- sp_reporte_mensual_cliente por mes/año.
--
-- Modelo de rastreo:
--   paquetes.id_almacen -> almacén donde está el paquete AHORA
--                          (NULL = entregado, cancelado o en ruta).
--                          El trigger before_insert_paquete_almacen
--                          valida la capacidad al insertar.
--   historial_rastreo   -> un evento por envío con fecha,
--                          ubicacion_actual, estado y observaciones.
-- =============================================================
SET NAMES utf8mb4;
USE logiexpress;

START TRANSACTION;

-- -------------------------------------------------------------
-- Clientes
-- -------------------------------------------------------------
-- Cliente principal de prueba
INSERT INTO clientes (nombres, apellidos, status_, limite_credito)
VALUES ('Carlos', 'Ramirez Lopez', 'ACTIVO', 50000.00);
SET @id_cliente = LAST_INSERT_ID();

-- Contraparte necesaria: envios exige remitente y destinatario (FK a clientes)
INSERT INTO clientes (nombres, apellidos, status_, limite_credito)
VALUES ('Ana', 'Torres Mendez', 'ACTIVO', 20000.00);
SET @id_contraparte = LAST_INSERT_ID();

-- -------------------------------------------------------------
-- Direcciones (respetando longitudes: calle 10, fracc/ciudad/estado 20)
-- -------------------------------------------------------------
INSERT INTO direcciones (calle, fraccionamiento, ciudad, estado, codigo_postal, id_cliente)
VALUES ('Hidalgo 45', 'Las Palmas', 'Guadalajara', 'Jalisco', '44100', @id_cliente);

INSERT INTO direcciones (calle, fraccionamiento, ciudad, estado, codigo_postal, id_cliente)
VALUES ('Reforma 12', 'Del Valle', 'Ciudad de Mexico', 'CDMX', '03100', @id_contraparte);

-- -------------------------------------------------------------
-- Almacenes
-- -------------------------------------------------------------
INSERT INTO almacenes (nombre, ubicacion, capacidad_maxima)
VALUES ('CEDIS Guadalajara', 'Av. Lopez Mateos Sur 2077, Zapopan, Jalisco', 5000);
SET @alm_gdl = LAST_INSERT_ID();

INSERT INTO almacenes (nombre, ubicacion, capacidad_maxima)
VALUES ('CEDIS Queretaro', 'Carretera 57 Km 12, El Marques, Queretaro', 3500);
SET @alm_qro = LAST_INSERT_ID();

INSERT INTO almacenes (nombre, ubicacion, capacidad_maxima)
VALUES ('CEDIS Ciudad de Mexico', 'Calz. de Tlalpan 1500, Coyoacan, CDMX', 8000);
SET @alm_cdmx = LAST_INSERT_ID();

-- Almacén pequeño (capacidad 2) para probar el error 45000 -> HTTP 400
INSERT INTO almacenes (nombre, ubicacion, capacidad_maxima)
VALUES ('Bodega Express Zapopan', 'Calle Industria 8, Zapopan, Jalisco', 2);
SET @alm_mini = LAST_INSERT_ID();

-- -------------------------------------------------------------
-- Envío 1: septiembre, ENTREGADO (GDL -> QRO -> CDMX)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 450.00, '2026-09-05 10:15:00', 'ENTREGADO');
SET @env1 = LAST_INSERT_ID();

-- Entregado: ya no ocupa lugar en ningún almacén
INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen)
VALUES (2.5, 20, 30, 25, 'Libros de texto', @env1, NULL);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-09-05 10:15:00', 'CEDIS Guadalajara',      'REGISTRADO',  'Envio registrado en sucursal', @env1),
    ('2026-09-06 08:00:00', 'CEDIS Guadalajara',      'EN_TRANSITO', 'Salida hacia Queretaro',       @env1),
    ('2026-09-07 07:30:00', 'CEDIS Queretaro',        'EN_TRANSITO', 'Escala en Queretaro',          @env1),
    ('2026-09-08 14:20:00', 'Ciudad de Mexico, CDMX', 'ENTREGADO',   'Recibido por destinatario',    @env1);

-- -------------------------------------------------------------
-- Envío 2: octubre, ENTREGADO (2 paquetes, GDL -> CDMX)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 1250.50, '2026-10-03 09:00:00', 'ENTREGADO');
SET @env2 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen) VALUES
    (8.0, 40, 50, 40, 'Monitor 27 pulgadas', @env2, NULL),
    (1.2, 10, 35, 15, 'Teclado y mouse',     @env2, NULL);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-10-03 09:00:00', 'CEDIS Guadalajara',      'REGISTRADO',  'Envio registrado en sucursal', @env2),
    ('2026-10-04 06:45:00', 'CEDIS Guadalajara',      'EN_TRANSITO', 'Salida hacia CDMX',            @env2),
    ('2026-10-05 05:00:00', 'CEDIS Ciudad de Mexico', 'EN_TRANSITO', 'Llegada a CEDIS CDMX',         @env2),
    ('2026-10-05 16:10:00', 'Ciudad de Mexico, CDMX', 'ENTREGADO',   'Entregado en domicilio',       @env2);

-- -------------------------------------------------------------
-- Envío 3: octubre, EN_TRANSITO (GDL -> QRO, retenido; sigue en QRO)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 780.00, '2026-10-18 11:30:00', 'EN_TRANSITO');
SET @env3 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen)
VALUES (5.4, 30, 40, 30, 'Ropa de temporada', @env3, @alm_qro);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-10-18 11:30:00', 'CEDIS Guadalajara', 'REGISTRADO',  'Envio registrado en sucursal',     @env3),
    ('2026-10-18 22:00:00', 'CEDIS Guadalajara', 'EN_TRANSITO', 'Salida hacia Queretaro',           @env3),
    ('2026-10-19 07:00:00', 'CEDIS Queretaro',   'EN_TRANSITO', 'En ruta, retenido por inventario', @env3);

-- -------------------------------------------------------------
-- Envío 4: octubre, CANCELADO (nunca salió de GDL; se devolvió
--          al remitente, por eso el paquete ya no está en almacén)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 320.00, '2026-10-25 13:00:00', 'CANCELADO');
SET @env4 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen)
VALUES (0.8, 5, 25, 20, 'Documentos', @env4, NULL);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-10-25 13:00:00', 'CEDIS Guadalajara', 'REGISTRADO', 'Envio registrado en sucursal',      @env4),
    ('2026-10-25 17:45:00', 'CEDIS Guadalajara', 'CANCELADO',  'Cancelado a solicitud del cliente', @env4);

-- -------------------------------------------------------------
-- Envío 5: noviembre, REGISTRADO (2 paquetes en la bodega pequeña:
--          la deja llena para probar el trigger de capacidad)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 615.75, '2026-11-08 12:00:00', 'REGISTRADO');
SET @env5 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen) VALUES
    (3.3, 25, 35, 25, 'Articulos de cocina', @env5, @alm_mini),
    (1.0, 15, 20, 15, 'Vajilla pequena',     @env5, @alm_mini);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-11-08 12:00:00', 'Bodega Express Zapopan', 'REGISTRADO', 'Envio registrado en sucursal', @env5);

-- -------------------------------------------------------------
-- Envío 6: octubre, el cliente es DESTINATARIO (CDMX -> GDL)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_contraparte, @id_cliente, 290.00, '2026-10-12 10:00:00', 'ENTREGADO');
SET @env6 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio, id_almacen)
VALUES (1.5, 12, 30, 20, 'Regalo de cumpleanos', @env6, NULL);

INSERT INTO historial_rastreo (fecha, ubicacion_actual, status_evento, observaciones, id_envio) VALUES
    ('2026-10-12 10:00:00', 'CEDIS Ciudad de Mexico', 'REGISTRADO',  'Envio registrado en sucursal', @env6),
    ('2026-10-13 06:30:00', 'CEDIS Ciudad de Mexico', 'EN_TRANSITO', 'Salida hacia Guadalajara',     @env6),
    ('2026-10-14 05:00:00', 'CEDIS Guadalajara',      'EN_TRANSITO', 'Llegada a CEDIS Guadalajara',  @env6),
    ('2026-10-14 15:00:00', 'Guadalajara, Jalisco',   'ENTREGADO',   'Recibido por destinatario',    @env6);

COMMIT;

-- auditoria_envios no se llena aquí: la pobla el trigger
-- after_update_envio_costo (03_triggers.sql) al actualizar envios.costo_total.
