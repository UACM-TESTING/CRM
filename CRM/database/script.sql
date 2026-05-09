CREATE DATABASE CRM;
CREATE USER testing WITH PASSWORD '123456';
ALTER ROLE testing WITH CreateDB;
ALTER DATABASE CRM OWNER TO testing;
GRANT ALL PRIVILEGES ON DATABASE CRM TO testing;

CREATE TABLE plan
(
    id_plan SMALLSERIAL PRIMARY KEY,
    nombre_plan VARCHAR(50) NOT NULL,
    precio_plan NUMERIC(8, 2) NOT NULL
);

CREATE TABLE olt
(
    id_olt SMALLSERIAL PRIMARY KEY,
    nombre_olt VARCHAR(30) NOT NULL,
    region_olt VARCHAR(30) NOT NULL
);

CREATE TABLE empleado
(
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(40),
    apellido_materno VARCHAR(20),
    apellido_materno VARCHAR(20),
    fecha_alta DATE DEFAULT CURRENT_DATE
);

CREATE TABLE cliente
(
    id_cliente SERIAL PRIMARY KEY UNIQUE,
    nombre_cliente VARCHAR(25),
    apellido_paterno VARCHAR(15),
    apellido_materno VARCHAR(15),
    telefono_celular VARCHAR(10),
    correo_cliente VARCHAR(40),
    cuenta_cliente INTEGER UNIQUE,
    --esta llave indica que el cliente conoce que numero de cuenta tiene
    FOREIGN KEY (cuenta_cliente) REFERENCES cuenta(id_cuenta)
);

CREATE TABLE acceso
(
    nombre_usuario VARCHAR(15) PRIMARY KEY,
    clave_acceso VARCHAR(30),
    id_usuario INTEGER UNIQUE,
    fecha_alta DATE DEFAULT CURRENT_DATE,
    --esta lllave indica que el usuario conoce a que empleado pertenece
    FOREIGN KEY (id_usuario) REFERENCES empleado(id_empleado)
);

CREATE TABLE folio
(
    id_folio SERIAL PRIMARY KEY UNIQUE,
    id_empleado INTEGER UNIQUE,
    id_cuenta INTEGER UNIQUE,
    fecha_alta DATE DEFAULT CURRENT_DATE,
    --esta llave indica que el folio conoce que empleado lo genero
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    --esta llave indica que el folio conoce que a que cuenta pertenece 
    FOREIGN KEY (id_cuenta) REFERENCES cuenta(id_cuenta)
);

CREATE TABLE equipo
(
    id_equipo VARCHAR(20) UNIQUE,
    mac_address VARCHAR(17) UNIQUE,
    descripcion VARCHAR(8),
    id_cuenta INTEGER,
    --llave primaria que se compone de 2 atributos
    PRIMARY KEY (id_equipo, mac_address),
    --esta llave indica que un equipo conoce a que cuenta pertenece
    FOREIGN KEY (id_cuenta) REFERENCES cuenta(id_cuenta)
);

--EL PRIMER NUMERO DE CUENTA SERA: 1147483647
CREATE TABLE cuenta
(
    id_cuenta SERIAL PRIMARY KEY,
    id_cliente INTEGER UNIQUE,
    id_olt INTEGER UNIQUE,
    id_plan INTEGER UNIQUE,
    id_folio INTEGER UNIQUE,
    id_equipo VARCHAR(20) UNIQUE,
    cuenta_activa BOOLEAN DEFAULT FALSE,
    fecha_corte DATE,
    fecha_limite DATE,
    telefono_fijo VARCHAR(10) UNIQUE,
    fecha_activacion DATE DEFAULT CURRENT_DATE,
    --llave que permite que la cuenta sepa a que cliente pertenece
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    --llave que permite que la cuenta sepa que plan tiene
    FOREIGN KEY (id_plan) REFERENCES plan(id_plan),
    --llave que permite que la cuenta sepa a que olt pertenece
    FOREIGN KEY (id_olt) REFERENCES olt(id_olt),
    --llave que permite que la cuenta sepa que folios tiene registrados
    FOREIGN KEY (id_equipo) REFERENCES equipo(id_equipo),
    --llave que permite que la cuenta sepa que equipos tiene registrados
    FOREIGN KEY (id_folio) REFERENCES equipo(id_folio)
);

ALTER TABLE cliente ADD CONSTRAINT FK_CUENTA 
FOREIGN KEY (cuenta_cliente) REFERENCES cuenta (id_cuenta);

INSERT INTO plan VALUES('Turbo', 1300);
INSERT INTO plan VALUES('Veloz', 900);
INSERT INTO plan VALUES('Sonico', 700);
INSERT INTO plan VALUES('Ultra Sonico', 500);

INSERT INTO olt VALUES('SUR_CDMX', 'SUR');
INSERT INTO olt VALUES('SUR_GDL', 'SUR');
INSERT INTO olt VALUES('NORTE_COAHUILA', 'NORTE');
INSERT INTO olt VALUES('NUEVO_LEON', 'NORTE');
INSERT INTO olt VALUES('SURESTE_TABASCO', 'SUROESTE');