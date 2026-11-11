-- =============================================================
-- Seed de datos de prueba: cliente "Carlos Ramírez López"
-- Incluye su dirección, envíos (como remitente y destinatario),
-- paquetes, almacenes, ubicación de paquetes por almacén
-- (paquete_almacen) e historial de rastreo.
-- Los envíos abarcan sep-nov 2026 para probar
-- sp_reporte_mensual_cliente por mes/año.
--
-- Modelo de rastreo:
--   paquete_almacen  -> cada estancia de un paquete en un almacén
--                        (fecha_ingreso / fecha_salida; fecha_salida
--                        NULL = el paquete sigue en ese almacén).
--                        En la última estancia de un envío entregado,
--                        fecha_salida = momento de la entrega.
--   historial_rastreo -> cada evento apunta a un paquete_almacen
--                        (y al envío). Si un envío tiene varios
--                        paquetes, se registra el evento por paquete.
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

-- -------------------------------------------------------------
-- Envío 1: septiembre, ENTREGADO (GDL -> QRO -> CDMX)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 450.00, '2026-09-05 10:15:00', 'ENTREGADO');
SET @env1 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (2.5, 20, 30, 25, 'Libros de texto', @env1);
SET @paq1 = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq1, @alm_gdl, '2026-09-05 10:15:00', '2026-09-06 08:00:00');
SET @pa1_gdl = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq1, @alm_qro, '2026-09-07 07:30:00', '2026-09-07 21:00:00');
SET @pa1_qro = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq1, @alm_cdmx, '2026-09-08 05:30:00', '2026-09-08 14:20:00');
SET @pa1_cdmx = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-09-05 10:15:00', 'REGISTRADO',  'Envio registrado en sucursal', @pa1_gdl,  @env1),
    ('2026-09-06 08:00:00', 'EN_TRANSITO', 'Salida hacia Queretaro',       @pa1_gdl,  @env1),
    ('2026-09-07 07:30:00', 'EN_TRANSITO', 'Escala en Queretaro',          @pa1_qro,  @env1),
    ('2026-09-08 14:20:00', 'ENTREGADO',   'Recibido por destinatario',    @pa1_cdmx, @env1);

-- -------------------------------------------------------------
-- Envío 2: octubre, ENTREGADO (2 paquetes, GDL -> CDMX)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 1250.50, '2026-10-03 09:00:00', 'ENTREGADO');
SET @env2 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (8.0, 40, 50, 40, 'Monitor 27 pulgadas', @env2);
SET @paq2a = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (1.2, 10, 35, 15, 'Teclado y mouse', @env2);
SET @paq2b = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq2a, @alm_gdl, '2026-10-03 09:00:00', '2026-10-04 06:45:00');
SET @pa2a_gdl = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq2a, @alm_cdmx, '2026-10-05 05:00:00', '2026-10-05 16:10:00');
SET @pa2a_cdmx = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq2b, @alm_gdl, '2026-10-03 09:00:00', '2026-10-04 06:45:00');
SET @pa2b_gdl = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq2b, @alm_cdmx, '2026-10-05 05:00:00', '2026-10-05 16:10:00');
SET @pa2b_cdmx = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-10-03 09:00:00', 'REGISTRADO',  'Envio registrado en sucursal', @pa2a_gdl,  @env2),
    ('2026-10-03 09:00:00', 'REGISTRADO',  'Envio registrado en sucursal', @pa2b_gdl,  @env2),
    ('2026-10-04 06:45:00', 'EN_TRANSITO', 'Salida hacia CDMX',            @pa2a_gdl,  @env2),
    ('2026-10-04 06:45:00', 'EN_TRANSITO', 'Salida hacia CDMX',            @pa2b_gdl,  @env2),
    ('2026-10-05 16:10:00', 'ENTREGADO',   'Entregado en domicilio',       @pa2a_cdmx, @env2),
    ('2026-10-05 16:10:00', 'ENTREGADO',   'Entregado en domicilio',       @pa2b_cdmx, @env2);

-- -------------------------------------------------------------
-- Envío 3: octubre, EN_TRANSITO (GDL -> QRO, retenido; sigue en QRO)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 780.00, '2026-10-18 11:30:00', 'EN_TRANSITO');
SET @env3 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (5.4, 30, 40, 30, 'Ropa de temporada', @env3);
SET @paq3 = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq3, @alm_gdl, '2026-10-18 11:30:00', '2026-10-18 22:00:00');
SET @pa3_gdl = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq3, @alm_qro, '2026-10-19 07:00:00', NULL);
SET @pa3_qro = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-10-18 11:30:00', 'REGISTRADO',  'Envio registrado en sucursal',     @pa3_gdl, @env3),
    ('2026-10-19 07:00:00', 'EN_TRANSITO', 'En ruta, retenido por inventario', @pa3_qro, @env3);

-- -------------------------------------------------------------
-- Envío 4: octubre, CANCELADO (nunca salió de GDL; se devolvió
--          al remitente al cancelarse, por eso se cierra la estancia)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 320.00, '2026-10-25 13:00:00', 'CANCELADO');
SET @env4 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (0.8, 5, 25, 20, 'Documentos', @env4);
SET @paq4 = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq4, @alm_gdl, '2026-10-25 13:00:00', '2026-10-25 17:45:00');
SET @pa4_gdl = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-10-25 13:00:00', 'REGISTRADO', 'Envio registrado en sucursal',      @pa4_gdl, @env4),
    ('2026-10-25 17:45:00', 'CANCELADO',  'Cancelado a solicitud del cliente', @pa4_gdl, @env4);

-- -------------------------------------------------------------
-- Envío 5: noviembre, REGISTRADO (2 paquetes, siguen en GDL)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_cliente, @id_contraparte, 615.75, '2026-11-08 12:00:00', 'REGISTRADO');
SET @env5 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (3.3, 25, 35, 25, 'Articulos de cocina', @env5);
SET @paq5a = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (1.0, 15, 20, 15, 'Vajilla pequena', @env5);
SET @paq5b = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq5a, @alm_gdl, '2026-11-08 12:00:00', NULL);
SET @pa5a_gdl = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq5b, @alm_gdl, '2026-11-08 12:00:00', NULL);
SET @pa5b_gdl = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-11-08 12:00:00', 'REGISTRADO', 'Envio registrado en sucursal', @pa5a_gdl, @env5),
    ('2026-11-08 12:00:00', 'REGISTRADO', 'Envio registrado en sucursal', @pa5b_gdl, @env5);

-- -------------------------------------------------------------
-- Envío 6: octubre, el cliente es DESTINATARIO (CDMX -> GDL)
-- -------------------------------------------------------------
INSERT INTO envios (id_remitente, id_destinatario, costo_total, fecha, status_global)
VALUES (@id_contraparte, @id_cliente, 290.00, '2026-10-12 10:00:00', 'ENTREGADO');
SET @env6 = LAST_INSERT_ID();

INSERT INTO paquetes (peso, alto, largo, ancho, contenido, id_envio)
VALUES (1.5, 12, 30, 20, 'Regalo de cumpleanos', @env6);
SET @paq6 = LAST_INSERT_ID();

INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq6, @alm_cdmx, '2026-10-12 10:00:00', '2026-10-13 06:30:00');
SET @pa6_cdmx = LAST_INSERT_ID();
INSERT INTO paquete_almacen (id_paquete, id_almacen, fecha_ingreso, fecha_salida)
VALUES (@paq6, @alm_gdl, '2026-10-14 05:00:00', '2026-10-14 15:00:00');
SET @pa6_gdl = LAST_INSERT_ID();

INSERT INTO historial_rastreo (fecha, status_evento, observaciones, id_paquete_almacen, id_envio) VALUES
    ('2026-10-12 10:00:00', 'REGISTRADO',  'Envio registrado en sucursal', @pa6_cdmx, @env6),
    ('2026-10-13 06:30:00', 'EN_TRANSITO', 'Salida hacia Guadalajara',     @pa6_cdmx, @env6),
    ('2026-10-14 15:00:00', 'ENTREGADO',   'Recibido por destinatario',    @pa6_gdl,  @env6);

COMMIT;

-- auditoria_envios no se llena aquí: se espera que la pueble un trigger
-- (03_triggers.sql) al actualizar envios.costo_total.
