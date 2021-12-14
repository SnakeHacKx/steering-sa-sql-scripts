---SEMESTRAL DE BASE DE DATOS---
CREATE DATABASE Steering_SA
ON PRIMARY
(
	Name ='Steering_SA_DATA',
	Filename = 'F:\Program Files\Microsft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Steering_SA.MDF',
	Size = 10MB,
	MAXSIZE = 30,
	FILEGROWTH = 2MB
)
LOG ON
(
	Name='Steering_SA_LOG',
	Filename='F:\Program Files\Microsft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Steering_SA.LDF',
	Size = 4MB,
	MAXSIZE = 15,
	FILEGROWTH = 20%
)
GO
--creacion de las tablas
--tabla conductor--
--Guarda la informacion referente a los conductores
CREATE TABLE Conductor(
	Cedula varchar(15) not null,
	Nombre varchar(30) not null,
	Apellido varchar(30) not null,
	Telefono varchar(10) not null,
	Fecha_de_nacimiento date not null,
	Tipo_de_sangre varchar(3) not null, --se cambio de 5 a 3
	Tipo_de_licencia varchar(5) not null
	primary key (Cedula)
);
GO

--Tabla reporte ---
--Guarda la informacion referente a los reportes que se hagan a los vehiculos
CREATE TABLE Reporte(
	Cod_reporte VARCHAR(10),
	Placa_Vehiculo VARCHAR(10) NOT NULL,
	Estado VARCHAR(13) NOT NULL DEFAULT 'NO ATENDIDO',--se modifica automaticamente cuando se hace el mantenimiento
	Descripcion VARCHAR(1500) NOT NULL,
	Fecha DATE NOT NULL,--Es la fecha en el momento que se registra el reporte
	PRIMARY KEY(Cod_reporte),
	FOREIGN KEY(Placa_Vehiculo) REFERENCES Vehiculo(Placa)
)
GO
--tabla Mantenimientos
--Guarda la informacion referente a los mantenimientos realizados sobre los vehiculos
CREATE TABLE Mantenimiento(
	Cod_Mantenimiento INT IDENTITY(1,1),
	Placa_Vehiculo VARCHAR(10) NOT NULL,
	Cod_reporte VARCHAR(10) NOT NULL,--no es foreign key porque no siempre se hacen mantenimientos por reportes de daños
	Costo MONEY DEFAULT 0.00,
	Fecha DATE NOT NULL,--es la fecha para la cual se programa el mantenimiento
	Descripcion varchar(1500) not null,
	Estado VARCHAR(15) NOT NULL,
	PRIMARY KEY(Cod_Mantenimiento),
	FOREIGN KEY (Placa_Vehiculo) REFERENCES Vehiculo(Placa)
)
GO

--Tabla Vehiculo--
--Guarda la informacion referente a los vehiculos
CREATE TABLE Vehiculo(
	Placa varchar(10) not null,
	Modelo_vehiculo varchar(10) not null,
	Tipo varchar(15) not null, --puede ser pickup, camioneta, moto, camion, etc.
	Estado varchar(15) not null, --se refiere a si esta disponible o no para asignarse a servicios
	pasajero varchar(2) not null,--cantidad de puestos
	Tipo_de_combustible varchar(12) not null,
	Color varchar(10) not null,
	primary key(Placa)
)
GO


--CREACION DE LA TABLA TIPO DE SERVICIOS
--Guarda la informacion referente a los tipo de servicios que ofrece la empresa
CREATE TABLE Tipo_servicios(
	Cod_tipo_servicio INT IDENTITY(1,1),
	Nombre_servicio VARCHAR(40) NOT NULL,
	Costo_servicio MONEY NOT NULL,--Costo por dia 
	PRIMARY KEY (Cod_tipo_servicio)
);
GO

--CREACION DE LA TABLA SERVICIO
--Guarda la informacion referente a los servicios que se registran
CREATE TABLE Servicio(
	Cod_Servicio INT IDENTITY(1,1),
	Cod_tipo_servicio INT NOT NULL,
	Cedula_Conductor VARCHAR(15) NOT NULL,
	Placa VARCHAR(10) NOT NULL,
	Cedula_Cliente VARCHAR(15) NOT NULL,
	Fecha_inicio DATE NOT NULL,
	Fecha_finalizacion DATE NOT NULL,
	Monto_Total_Servicio MONEY NOT NULL,--se calcula segun la cantidad de dias del servicio y el costo por dia del tipo de servicio que sea
	Descripcion_servicio VARCHAR(1500),
	PRIMARY KEY (Cod_Servicio),
	FOREIGN KEY(Cod_tipo_servicio) REFERENCES Tipo_servicios(Cod_tipo_servicio),
	FOREIGN KEY (Cedula_Conductor) REFERENCES Conductor(Cedula),
	FOREIGN KEY(Placa) REFERENCES Vehiculo(Placa),
	FOREIGN KEY(Cedula_Cliente) REFERENCES TB_Cliente(Cedula_Cliente)
);
GO
--CREACION DE LA TABLA CLIENTES
--Guarda la informacion referente a los clientes
CREATE TABLE TB_Cliente(
	Cedula_Cliente VARCHAR(15) NOT NULL,
	Nombre_Cliente VARCHAR(35) NOT NULL,
	Apellido_Cliente VARCHAR(35) NOT NULL,
	Fecha_Nacimiento_Cliente DATE NOT NULL,--se utiliza para calcular la edad
	Telefono_Cliente VARCHAR(15)NOT NULL,
	Direccion_CLiente VARCHAR(65) NOT NULL,
	PRIMARY KEY (Cedula_Cliente)
);
GO

--CREACION DE TABLA HISTORIAL QUE ALMACENA TODAS LAS OPERACIONES DE INSERTAR,ACTUALIZAR,ELIMINAR TABLAS HECHAS POR LOS DIFERENTES USUARIOS 
CREATE TABLE TB_Historial(
	ID_operacion INT PRIMARY KEY IDENTITY(1,1),
	Nombre_usuario VARCHAR(50) DEFAULT USER_NAME(),
	Rol_Usuario VARCHAR(25) NOT NULL,
	Accion VARCHAR(20) NOT NULL,--ACCION REALIZADA SOBRE ALGUNA TABLA PUEDE SER ACTUALIZAR, ELIMINAR, INSERTAR EN TABLA 
	Descripcion VARCHAR(50) NOT NULL,
	Fecha DATE DEFAULT (GETDATE()),
);
GO