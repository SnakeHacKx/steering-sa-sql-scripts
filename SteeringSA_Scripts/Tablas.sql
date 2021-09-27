---SEMESTRAL DE BASE DE DATOS---
create database Steering_SA
ON PRIMARY
(
	Name ='Steering_SA_DATA',
	Filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Steering_SA.MDF',
	Size = 10MB,
	MAXSIZE = 30,
	FILEGROWTH = 2MB
)
LOG ON
(
	Name='Steering_SA_LOG',
	Filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Steering_SA.LDF',
	Size = 4MB,
	MAXSIZE = 15,
	FILEGROWTH = 20%
)
GO
--creacion de las tablas
--tabla conductor--
create table Conductor(
	Cedula varchar(15) not null,
	Nombre varchar(30) not null,
	Apellido varchar(30) not null,
	Telefono varchar(10) not null,
	Fecha_de_nacimiento date not null,
	Tipo_de_sangre varchar(3) not null, --se cambio de 5 a 3
	Tipo_de_licencia varchar(5) not null
	primary key (Cedula)
	);

--tabla mantenimiento--
create table Tipo_mantenimiento(
	Cod_tipo_mantenimiento int not null,
	Descripcion varchar(125) not null,
	primary key(Cod_tipo_mantenimiento)
)
--Tabla reporte ---
create table Reporte(
	Cod_reporte int not null,
	Descripcion varchar(150) not null,
	Fecha date not null,
	Responsable varchar(70) not null,
	primary key(Cod_reporte)

)
--tabla Hacer--
create table Mantenimiento(
	Placa varchar(10) not null,
	Cod_tipo_mantenimiento int not null,
	Cod_reporte int not null default -1,
	Costo money not null,
	Fecha date not null,
	foreign key (Placa) references Vehiculo(Placa),
	foreign key(Cod_tipo_mantenimiento) references Tipo_mantenimiento(Cod_tipo_mantenimiento),
	foreign key(Cod_reporte) references Reporte(Cod_reporte)
)
--Tabla Vehiculo--
create table Vehiculo(
	Placa varchar(10) not null,
	Motor varchar(10) not null, --se cambio de 50 a 10
	Tipo varchar(15) not null, --se cambio de 20 a 15
	Estado varchar(15) not null, --se cambio a 15
	pasajero smallint not null,
	Tipo_de_combustible varchar(10) not null,
	Color varchar(10) not null,
	primary key(Placa)
)


/*MODIFICACION DEL LA BASE DE DATOS 24-9-21 
MODIFICACION DE RELACION ENTRE CONDUCTORES, SERVICIOS Y VEHICULOS
SE MODIFICARA TAMBIEN LA TABLA SERVICIOS PARA SER TIPOS DE SERVICIOS
LA RELACION PASARA A LLAMARSE SERVICIOS*/

GO
--CREACION DE LA TABLA TIPO DE SERVICIOS
CREATE TABLE Tipo_servicios(
	Cod_tipo_servicio INT NOT NULL,
	Nombre_servicio VARCHAR(40) NOT NULL,
	Costo_servicio MONEY NOT NULL,
	PRIMARY KEY (Cod_tipo_servicio)
);
GO

--CREACION DE LA TABLA SERVICIO
CREATE TABLE Servicio(
	Cod_tipo_servicio INT NOT NULL,
	Cedula VARCHAR(15) NOT NULL,
	Placa VARCHAR(10) NOT NULL,
	Nombre_Cliente VARCHAR(35) NOT NULL,
	Fecha_inicio DATE NOT NULL,
	Fecha_finalizacion DATE NOT NULL,
	FOREIGN KEY(Cod_tipo_servicio) REFERENCES Tipo_servicios(Cod_tipo_servicio),
	FOREIGN KEY (Cedula) REFERENCES Conductor(Cedula),
	FOREIGN KEY(Placa) REFERENCES Vehiculo(Placa)
);
GO

