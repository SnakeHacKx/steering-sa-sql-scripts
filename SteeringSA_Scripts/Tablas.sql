---SEMESTRAL DE BASE DE DATOS---
create database [Steering S.A];
select * from Conductor
--creacion de las tablas
--tabla conductor--
create table Conductor(
	Cedula varchar(15) not null,
	Nombre varchar(30) not null,
	Apellido varchar(30) not null,
	Telefono varchar(10) not null,
	Fecha_de_nacimiento date not null,
	Tipo_de_sangre varchar(5) not null,
	Tipo_de_licencia varchar(5) not null
	primary key (Cedula)
	);

--tabla mantenimiento--
create table Mantenimiento(
	Cod_mantenimiento int not null,
	Descripcion varchar(125) not null,
	Fecha date,
	Costo money,
	primary key(Cod_mantenimiento)
)
--Tabla reporte ---
create table Reporte(
	Cod_reporte int not null,
	Descripcion varchar(150) not null,
	Fecha date not null,
	responsable varchar(70) not null,
	primary key(Cod_reporte)

)
--Tabla Vehiculo--
create table Vehiculo(
	Placa varchar(10) not null,
	Motor varchar(50) not null,
	Tipo varchar(20) not null,
	Estado varchar(25) not null,
	pasajero smallint not null,
	Tipo_de_combustible varchar(10) not null,
	Color varchar(10) not null,
	primary key(Placa)
)
--tabla Hacer--
create table Hacer(
	Placa varchar(10) not null,
	Cod_mantenimiento int not null,
	Cod_reporte int not null,
	foreign key (Placa) references Vehiculo(Placa),
	foreign key(Cod_mantenimiento) references Mantenimiento(Cod_mantenimiento),
	foreign key(Cod_reporte) references Reporte(Cod_reporte)
)

/*MODIFICACION DEL LA BASE DE DATOS 24-9-21 
MODIFICACION DE RELACION ENTRE CONDUCTORES, SERVICIOS Y VEHICULOS
SE MODIFICARA TAMBIEN LA TABLA SERVICIOS PARA SER TIPOS DE SERVICIOS
LA RELACION PASARA A LLAMARSE SERVICIOS*/

USE [Steering S.A];
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

