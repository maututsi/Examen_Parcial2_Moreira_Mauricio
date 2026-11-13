DROP DATABASE IF EXISTS logiexpress;

CREATE DATABASE logiexpress;
USE logiexpress;

CREATE TABLE clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    status_ ENUM('ACTIVO', 'INACTIVO') NOT NULL,
    limite_credito DECIMAL(15, 2) NOT NULL
);

CREATE TABLE direcciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    calle VARCHAR(10),
    fraccionamiento VARCHAR(20),
    ciudad VARCHAR(20),
    estado VARCHAR(20),
    codigo_postal VARCHAR(10),
    id_cliente INT NOT NULL UNIQUE,

    CONSTRAINT fk_direcciones_clientes
        FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE TABLE envios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_remitente INT NOT NULL,
    id_destinatario INT NOT NULL,
    costo_total decimal(15, 2) NOT NULL,
    fecha DATETIME NOT NULL,
    status_global ENUM(
        'REGISTRADO',
        'EN_TRANSITO',
        'ENTREGADO',
        'CANCELADO'
    ) NOT NULL,

    CONSTRAINT fk_envios_remitente
        FOREIGN KEY (id_remitente) REFERENCES clientes(id),

    CONSTRAINT fk_envios_destinatario
        FOREIGN KEY (id_destinatario) REFERENCES clientes(id)
);

CREATE TABLE almacenes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad_maxima INT NOT NULL
);

-- almacenes se crea antes que paquetes porque paquetes.id_almacen la referencia
CREATE TABLE paquetes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    peso FLOAT NOT NULL,
    alto FLOAT NOT NULL,
    largo FLOAT NOT NULL,
    ancho FLOAT NOT NULL,
    contenido VARCHAR(100) NOT NULL,
    id_envio INT,
    -- Almacén donde está el paquete ahora; NULL = fuera de almacén (en ruta o entregado)
    id_almacen INT NULL,

    CONSTRAINT fk_paquetes_envios
        FOREIGN KEY (id_envio) REFERENCES envios(id),

    CONSTRAINT fk_paquetes_almacenes
        FOREIGN KEY (id_almacen) REFERENCES almacenes(id)
);

CREATE TABLE historial_rastreo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATETIME NOT NULL,
    ubicacion_actual VARCHAR(150) NOT NULL,
    status_evento ENUM(
        'REGISTRADO',
        'EN_TRANSITO',
        'ENTREGADO',
        'CANCELADO'
    ) NOT NULL,
    observaciones VARCHAR(200),
    id_envio INT NOT NULL,

    CONSTRAINT fk_historial_envios
        FOREIGN KEY (id_envio) REFERENCES envios(id)
);

CREATE TABLE auditoria_envios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_envio INT NOT NULL,
    costo_anterior DECIMAL(15, 2) NOT NULL,
    costo_nuevo DECIMAL(15, 2) NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_modificacion DATETIME NOT NULL,

    CONSTRAINT fk_auditoria_envios
        FOREIGN KEY (id_envio) REFERENCES envios(id)
);
