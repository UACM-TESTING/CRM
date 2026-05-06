CREATE DATABASE CRM;
CREATE USER testing WITH PASSWORD '123456';
ALTER ROLE testing WITH CreateDB;
ALTER DATABASE CRM OWNER TO testing;
GRANT ALL PRIVILEGES ON DATABASE CRM TO testing;

CREATE TABLE plan
(
    id_plan SERIAL PRIMARY KEY,
    nombre_plan VARCHAR(50) NOT NULL,
    precio_plan NUMERIC(8, 2) NOT NULL
);

CREATE TABLE olt
(
    id_olt SERIAL PRIMARY KEY,
    nombre_olt VARCHAR(50) NOT NULL,
    region_olt VARCHAR(50) NOT NULL
);

CREATE TABLE cliente
(
    id_cliente SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(25) NOT NULL,
    apellido_paterno VARCHAR(25) NOT NULL,
    apellido_materno VARCHAR(25),
    telefono_celular VARCHAR(10),
    correo_cliente VARCHAR(40),
    cuenta_cliente BIGINT UNIQUE
);

CREATE TABLE cuenta
(
    num_cuenta BIGSERIAL PRIMARY KEY,
    id_cliente INTEGER UNIQUE NOT NULL,
    id_olt INTEGER UNIQUE NOT NULL,
    id_plan INTEGER NOT NULL,
    cuenta_activa BOOLEAN DEFAULT FALSE,
    fecha_corte DATE,
    fecha_limite DATE,
    telefono_fijo VARCHAR(10),
    fecha_activacion DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_plan) REFERENCES planes(id_plan),
    FOREIGN KEY (id_olt) REFERENCES olt(id_olt)
);

ALTER TABLE cliente
ADD CONSTRAINT FK_CUENTA 
FOREIGN KEY (cuenta_cliente) 
REFERENCES cuenta (num_cuenta);
