-- CREATE DATABASE crm;
-- CREATE USER testing WITH PASSWORD '123456';
-- ALTER ROLE testing WITH CREATEDB;
-- ALTER DATABASE crm OWNER TO testing;
-- GRANT ALL PRIVILEGES ON DATABASE crm TO testing;

-- \connect crm

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
    equipo_activo BOOLEAN DEFAULT TRUE,
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

-- tabla nueva para visitas tecnicas, esta tabla se relaciona con el 
-- folio, ya que cada visita tecnica se genera a partir de un folio
-- Relación uno a uno: una visita pertenece a un folio, y un folio tiene una sola visita
CREATE TABLE visita
(
    -- el id de visita se asigna al momento de programar la visita tecnica, es un numero autoincremental
    idVisita SERIAL PRIMARY KEY,
    -- el id del folio se asigna al momento de programar la visita tecnica, se relaciona con el 
    -- folio que genero la visita, UNIQUE asegura que cada folio tiene una sola visita
    idFolio INTEGER UNIQUE NOT NULL,
    -- la fecha de visita se puede programar para una fecha futura, por eso no se asigna un valor por defecto
    fechaVisita DATE,
    -- separar fecha y hora para facilitar consultas por rango de fechas o por hora
    fechaCreacion DATE,
    -- el turno de visita se asigna al momento de programar la visita, puede ser turno matutino o vespertino
    turnoVisita VARCHAR(10),
    -- ID del empleado que genero la visita, se asigna al momento de programar la visita 
    idEmpleado INTEGER,
    -- la observaciones de la visita se asigna al momento de programar 
    -- la visita, puede incluir detalles adicionales sobre la visita tecnica
    observaciones VARCHAR(2000),
    -- el estado de la visita se asigna al momento de programar la visita, 
    -- puede ser programada, en progreso, completada, cancelada, reagendada 
    estadoVisita VARCHAR(20)  
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

-- la visita se relaciona con un folio (relación uno a uno)
ALTER TABLE visita ADD CONSTRAINT FK_VISITA_FOLIO
FOREIGN KEY (idFolio) REFERENCES folio(id_folio);

-- la visita sabe que empleado la programó
ALTER TABLE visita ADD CONSTRAINT FK_VISITA_EMPLEADO
FOREIGN KEY (idEmpleado) REFERENCES empleado(id_empleado);

-- Insert 10 plans
INSERT INTO plan (nombre_plan, precio_plan, descuento) VALUES
('Plan Básico', 299.00, 0.00),
('Plan Estándar', 499.00, 50.00),
('Plan Premium', 799.00, 100.00),
('Plan Empresarial', 1299.00, 200.00),
('Plan Hogar', 399.00, 30.00),
('Plan Estudiante', 249.00, 0.00),
('Plan Familiar', 699.00, 80.00),
('Plan Ultra', 999.00, 150.00),
('Plan Lite', 199.00, 0.00),
('Plan Pro', 1499.00, 250.00);

-- Insert 10 OLTs
INSERT INTO olt (nombre_olt, region_olt) VALUES
('OLT-Norte-01', 'Zona Norte'),
('OLT-Sur-01', 'Zona Sur'),
('OLT-Este-01', 'Zona Este'),
('OLT-Oeste-01', 'Zona Oeste'),
('OLT-Centro-01', 'Zona Centro'),
('OLT-Norte-02', 'Zona Norte'),
('OLT-Sur-02', 'Zona Sur'),
('OLT-Este-02', 'Zona Este'),
('OLT-Oeste-02', 'Zona Oeste'),
('OLT-Centro-02', 'Zona Centro');

-- Insert 10 accesos
INSERT INTO acceso (nombre_usuario, clave_acceso) VALUES
('jperez', 'pass123'),
('mgarcia', 'pass456'),
('lrodriguez', 'pass789'),
('alopez', 'pass321'),
('cmartinez', 'pass654'),
('rhernandez', 'pass987'),
('fgonzalez', 'pass147'),
('psanchez', 'pass258'),
('dramirez', 'pass369'),
('jtorres', 'pass741');

-- Insert 10 empleados
INSERT INTO empleado (nombre, apellido_paterno, apellido_materno, nombre_usuario) VALUES
('Juan', 'Pérez', 'García', 'jperez'),
('María', 'García', 'López', 'mgarcia'),
('Luis', 'Rodríguez', 'Martínez', 'lrodriguez'),
('Ana', 'López', 'Hernández', 'alopez'),
('Carlos', 'Martínez', 'González', 'cmartinez'),
('Rosa', 'Hernández', 'Sánchez', 'rhernandez'),
('Fernando', 'González', 'Ramírez', 'fgonzalez'),
('Patricia', 'Sánchez', 'Torres', 'psanchez'),
('Diego', 'Ramírez', 'Flores', 'dramirez'),
('Jorge', 'Torres', 'Morales', 'jtorres');

-- Insert 10 clientes
INSERT INTO cliente (nombre_cliente, apellido_paterno, apellido_materno, telefono_celular, correo_cliente) VALUES
('Roberto', 'Díaz', 'Cruz', '5551234567', 'roberto.diaz@email.com'),
('Laura', 'Morales', 'Ruiz', '5552345678', 'laura.morales@email.com'),
('Miguel', 'Castro', 'Ortiz', '5553456789', 'miguel.castro@email.com'),
('Sofia', 'Vargas', 'Mendoza', '5554567890', 'sofia.vargas@email.com'),
('Pedro', 'Jiménez', 'Reyes', '5555678901', 'pedro.jimenez@email.com'),
('Elena', 'Romero', 'Silva', '5556789012', 'elena.romero@email.com'),
('Alberto', 'Gutiérrez', 'Medina', '5557890123', 'alberto.gutierrez@email.com'),
('Carmen', 'Aguilar', 'Navarro', '5558901234', 'carmen.aguilar@email.com'),
('Ricardo', 'Mendez', 'Cortés', '5559012345', 'ricardo.mendez@email.com'),
('Gabriela', 'Ríos', 'Vega', '5550123456', 'gabriela.rios@email.com');

-- Insert 10 cuentas
INSERT INTO cuenta (id_cliente, id_olt, id_plan, fecha_corte, fecha_limite, telefono_fijo) VALUES
(1, 1, 1, '2024-01-15', '2024-01-20', '5581234567'),
(2, 2, 2, '2024-01-15', '2024-01-20', '5582345678'),
(3, 3, 3, '2024-01-15', '2024-01-20', '5583456789'),
(4, 4, 4, '2024-01-15', '2024-01-20', '5584567890'),
(5, 5, 5, '2024-01-15', '2024-01-20', '5585678901'),
(6, 6, 6, '2024-01-15', '2024-01-20', '5586789012'),
(7, 7, 7, '2024-01-15', '2024-01-20', '5587890123'),
(8, 8, 8, '2024-01-15', '2024-01-20', '5588901234'),
(9, 9, 9, '2024-01-15', '2024-01-20', '5589012345'),
(10, 10, 10, '2024-01-15', '2024-01-20', '5580123456');

-- Insert 10 equipos
INSERT INTO equipo (id_equipo, mac_address, descripcion, id_cuenta) VALUES
('ONT-001', '00:11:22:33:44:55', 'ONT', 1000000000),
('ONT-002', '00:11:22:33:44:56', 'ONT', 1000000001),
('ONT-003', '00:11:22:33:44:57', 'ONT', 1000000002),
('ONT-004', '00:11:22:33:44:58', 'ONT', 1000000003),
('ONT-005', '00:11:22:33:44:59', 'ONT', 1000000004),
('ONT-006', '00:11:22:33:44:5A', 'ONT', 1000000005),
('ONT-007', '00:11:22:33:44:5B', 'ONT', 1000000006),
('ONT-008', '00:11:22:33:44:5C', 'ONT', 1000000007),
('ONT-009', '00:11:22:33:44:5D', 'ONT', 1000000008),
('ONT-010', '00:11:22:33:44:5E', 'ONT', 1000000009);

-- Insert 10 folios
INSERT INTO folio (area_origen, falla, falla_especifica, solucion, descripcion, id_empleado, id_cuenta) VALUES
('Soporte Técnico', 'Sin Internet', 'Sin señal ONT', 'Reinicio de equipo', 'Cliente reporta sin servicio de internet', 10000000, 1000000000),
('Atención Cliente', 'Lentitud', 'Velocidad baja', 'Optimización', 'Cliente reporta velocidad menor a contratada', 10000001, 1000000001),
('Soporte Técnico', 'Sin Internet', 'Cable dañado', 'Cambio de cable', 'Se detectó cable de fibra dañado', 10000002, 1000000002),
('Instalaciones', 'Sin servicio', 'Equipo defectuoso', 'Cambio de ONT', 'ONT no enciende, se requiere reemplazo', 10000003, 1000000003),
('Soporte Técnico', 'Intermitencia', 'Señal débil', 'Ajuste de potencia', 'Señal de fibra fuera de rango', 10000004, 1000000004),
('Atención Cliente', 'Facturación', 'Cobro incorrecto', 'Ajuste de cuenta', 'Cliente reporta cargo duplicado', 10000005, 1000000005),
('Soporte Técnico', 'Sin Internet', 'Configuración', 'Reconfiguración', 'Equipo perdió configuración', 10000006, 1000000006),
('Instalaciones', 'Cambio plan', 'Upgrade', 'Cambio de plan', 'Cliente solicita cambio a plan superior', 10000007, 1000000007),
('Soporte Técnico', 'WiFi', 'Cobertura baja', 'Reubicación ONT', 'Mala cobertura WiFi en domicilio', 10000008, 1000000008),
('Atención Cliente', 'Consulta', 'Información', 'Información', 'Cliente solicita información de servicios', 10000009, 1000000009);
