CREATE DATABASE crm;
CREATE USER testing WITH PASSWORD '123456';
ALTER ROLE testing WITH CREATEDB;
ALTER DATABASE crm OWNER TO testing;
GRANT ALL PRIVILEGES ON DATABASE crm TO testing;

\connect crm

-- los numeros de cuenta estan dentro de un rango de [1000000000 - 2147483647] 
-- secuencia para numeros de cuenta
CREATE SEQUENCE seq_cuenta START WITH 1000000000;

-- los numeros de folio estan dentro de un rango de [100000 - 1000000000] 
-- secuencia para numeros de folio
CREATE SEQUENCE seq_folio START WITH 100000;

-- los numeros de empleado se acotan a 8 digitos y no mas [10000000 - 99999999]
-- secuencia para numeros de empleado
CREATE SEQUENCE seq_empleado START WITH 10000000;

CREATE TABLE plan
(
    id_plan SMALLSERIAL PRIMARY KEY,
    nombre_plan VARCHAR(30),
    precio_plan NUMERIC(7, 2),
    descuento NUMERIC(7, 2)
);

CREATE TABLE olt
(
    id_olt SMALLSERIAL PRIMARY KEY,
    nombre_olt VARCHAR(30),
    region_olt VARCHAR(30)
);

CREATE TABLE empleado
(
    id_empleado INTEGER PRIMARY KEY DEFAULT nextval('seq_empleado'),
    nombre VARCHAR(40) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    nombre_usuario VARCHAR(15) UNIQUE,
    fecha_alta DATE DEFAULT CURRENT_DATE
);

CREATE TABLE cliente
(
    id_cliente SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(20) NOT NULL,
    apellido_paterno VARCHAR(20) NOT NULL,
    apellido_materno VARCHAR(20) NOT NULL,
    telefono_celular VARCHAR(10),
    correo_cliente VARCHAR(40)
);

CREATE TABLE acceso
(
    nombre_usuario VARCHAR(15) PRIMARY KEY,
    clave_acceso VARCHAR(30),
    fecha_alta DATE DEFAULT CURRENT_DATE
);

CREATE TABLE equipo
(
    id_equipo VARCHAR(20) PRIMARY KEY,
    mac_address VARCHAR(17) UNIQUE,
    descripcion VARCHAR(8),
    id_cuenta INTEGER
);

-- EL PRIMER NUMERO DE FOLIO SERA: 100000 A 6 NUMEROS
CREATE TABLE folio
(
    id_folio INTEGER PRIMARY KEY DEFAULT nextval('seq_folio'),
    area_origen VARCHAR(30),
    falla VARCHAR(30),
    falla_especifica VARCHAR(30),
    solucion VARCHAR(30),
    descripcion VARCHAR(2000),
    id_empleado INTEGER,
    id_cuenta INTEGER,
    fecha_alta DATE DEFAULT CURRENT_DATE
);

-- EL PRIMER NUMERO DE CUENTA SERA: 1000000000 A 10 DIGITOS
CREATE TABLE cuenta
(
    id_cuenta INTEGER PRIMARY KEY DEFAULT nextval('seq_cuenta'),
    id_cliente INTEGER,
    id_olt INTEGER,
    id_plan INTEGER,
    cuenta_activa BOOLEAN DEFAULT TRUE,
    fecha_corte DATE,
    fecha_limite DATE,
    telefono_fijo VARCHAR(10) UNIQUE, 
    fecha_activacion DATE DEFAULT CURRENT_DATE
);

-- el emplado sabe que acceso tiene
ALTER TABLE empleado ADD CONSTRAINT FK_EMPLEADO_ACCESO
FOREIGN KEY (nombre_usuario) REFERENCES acceso(nombre_usuario);

-- la cuenta conoce a que cliente pertenece
ALTER TABLE cuenta ADD CONSTRAINT FK_CUENTA_CLIENTE
FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);

-- la cuenta sabe que plan tiene cargado
ALTER TABLE cuenta ADD CONSTRAINT FK_CUENTA_PLAN
FOREIGN KEY (id_plan) REFERENCES plan(id_plan);

-- la cuenta sabe a que olt pertenece
ALTER TABLE cuenta ADD CONSTRAINT FK_CUENTA_OLT
FOREIGN KEY (id_olt) REFERENCES olt(id_olt);

-- el folio sabe que empleado lo genero
ALTER TABLE folio ADD CONSTRAINT FK_FOLIO_EMPLEADO
FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);

-- el folio sabe a que cuenta pertenece
ALTER TABLE folio ADD CONSTRAINT FK_FOLIO_CUENTA 
FOREIGN KEY (id_cuenta) REFERENCES cuenta(id_cuenta);

-- el equipo de red sabe a que cuenta pertenece
ALTER TABLE equipo ADD CONSTRAINT FK_EQUIPO_CUENTA 
FOREIGN KEY (id_cuenta) REFERENCES cuenta(id_cuenta);

-- TEST DATA
INSERT INTO plan (nombre_plan, precio_plan, descuento) VALUES 
('Basico', 299.00, 0.00),
('Premium', 599.00, 50.00),
('Empresarial', 899.00, 100.00),
('Familiar', 449.00, 25.00),
('Ultra', 1299.00, 150.00),
('Hogar Plus', 349.00, 15.00),
('Negocio', 749.00, 75.00),
('Estudiante', 199.00, 0.00),
('Corporativo', 1499.00, 200.00),
('Estandar', 399.00, 20.00);

INSERT INTO olt (nombre_olt, region_olt) VALUES 
('OLT-Norte', 'Norte'),
('OLT-Sur', 'Sur'),
('OLT-Este', 'Este'),
('OLT-Oeste', 'Oeste'),
('OLT-Centro', 'Centro'),
('OLT-Noreste', 'Noreste'),
('OLT-Noroeste', 'Noroeste'),
('OLT-Sureste', 'Sureste'),
('OLT-Suroeste', 'Suroeste'),
('OLT-Central1', 'Centro');

INSERT INTO acceso (nombre_usuario, clave_acceso) VALUES 
('admin', 'admin123'),
('soporte', 'soporte123'),
('tecnico1', 'tec123'),
('tecnico2', 'tec456'),
('ventas1', 'ven123'),
('tecnico3', 'tec789'),
('tecnico4', 'tec101'),
('ventas2', 'ven456'),
('ventas3', 'ven789'),
('supervisor1', 'sup123');

INSERT INTO empleado (nombre, apellido_paterno, apellido_materno, nombre_usuario) VALUES 
('Juan', 'Perez', 'Lopez', 'admin'),
('Maria', 'Garcia', 'Martinez', 'soporte'),
('Pedro', 'Martinez', 'Ruiz', 'tecnico1'),
('Laura', 'Lopez', 'Diaz', 'tecnico2'),
('Roberto', 'Gonzalez', 'Torres', 'ventas1'),
('Fernando', 'Moreno', 'Silva', 'tecnico3'),
('Carmen', 'Gutierrez', 'Ramos', 'tecnico4'),
('Diego', 'Herrera', 'Medina', 'ventas2'),
('Patricia', 'Romero', 'Aguilar', 'ventas3'),
('Ricardo', 'Castillo', 'Vazquez', 'supervisor1');

INSERT INTO cliente (nombre_cliente, apellido_paterno, apellido_materno, telefono_celular, correo_cliente) VALUES 
('Carlos', 'Rodriguez', 'Sanchez', '5551234567', 'carlos@email.com'),
('Ana', 'Hernandez', 'Gomez', '5559876543', 'ana@email.com'),
('Luis', 'Ramirez', 'Castro', '5551112233', 'luis@email.com'),
('Sofia', 'Flores', 'Morales', '5552223344', 'sofia@email.com'),
('Miguel', 'Vargas', 'Ortiz', '5553334455', 'miguel@email.com'),
('Elena', 'Mendoza', 'Reyes', '5554445566', 'elena@email.com'),
('Jorge', 'Cruz', 'Jimenez', '5555556677', 'jorge@email.com'),
('Andres', 'Salazar', 'Vega', '5556667788', 'andres@email.com'),
('Daniela', 'Paredes', 'Luna', '5557778899', 'daniela@email.com'),
('Oscar', 'Navarro', 'Rojas', '5558889900', 'oscar@email.com');

INSERT INTO cuenta (id_cliente, id_olt, id_plan, telefono_fijo) VALUES 
(1, 1, 1, '5555551111'),
(2, 2, 2, '5555552222'),
(3, 3, 3, '5555553333'),
(4, 4, 4, '5555554444'),
(5, 5, 5, '5555555555'),
(6, 6, 6, '5555556666'),
(7, 7, 7, '5555557777'),
(8, 8, 8, '5555558888'),
(9, 9, 9, '5555559999'),
(10, 10, 10, '5555550000');

INSERT INTO equipo (id_equipo, mac_address, descripcion, id_cuenta) VALUES 
('ONT-001', '00:11:22:33:44:55', 'Huawei', 1000000000),
('ONT-002', 'AA:BB:CC:DD:EE:FF', 'ZTE', 1000000001),
('ONT-003', '11:22:33:44:55:66', 'Nokia', 1000000002),
('ONT-004', '22:33:44:55:66:77', 'Huawei', 1000000003),
('ONT-005', '33:44:55:66:77:88', 'ZTE', 1000000004),
('ONT-006', '44:55:66:77:88:99', 'Huawei', 1000000005),
('ONT-007', '55:66:77:88:99:AA', 'Nokia', 1000000006),
('ONT-008', '66:77:88:99:AA:BB', 'Huawei', 1000000007),
('ONT-009', '77:88:99:AA:BB:CC', 'ZTE', 1000000008),
('ONT-010', '88:99:AA:BB:CC:DD', 'Nokia', 1000000009);

INSERT INTO folio (area_origen, falla, falla_especifica, solucion, descripcion, id_empleado, id_cuenta) VALUES 
('Soporte', 'Conexion', 'Sin internet', 'Reinicio ONT', 'Cliente reporta sin servicio', 10000000, 1000000000),
('Ventas', 'Instalacion', 'Nueva alta', 'Instalado', 'Nueva instalacion completada', 10000001, 1000000001),
('Soporte', 'Velocidad', 'Lentitud', 'Cambio plan', 'Cliente solicita upgrade', 10000002, 1000000002),
('Tecnico', 'Equipo', 'ONT dañado', 'Reemplazo', 'Equipo reemplazado', 10000003, 1000000003),
('Soporte', 'Conexion', 'Intermitente', 'Ajuste señal', 'Problema de señal resuelto', 10000004, 1000000004),
('Ventas', 'Instalacion', 'Nueva alta', 'Instalado', 'Cliente nuevo activado', 10000005, 1000000005),
('Soporte', 'Facturacion', 'Cobro doble', 'Ajuste', 'Aclaracion realizada', 10000006, 1000000006),
('Tecnico', 'Cableado', 'Fibra cortada', 'Reparacion', 'Fibra reparada en poste', 10000007, 1000000007),
('Soporte', 'Conexion', 'Sin servicio', 'Reinicio equipo', 'Servicio restablecido tras reinicio', 10000008, 1000000008),
('Ventas', 'Instalacion', 'Nueva alta', 'Instalado', 'Instalacion residencial completada', 10000009, 1000000009);
