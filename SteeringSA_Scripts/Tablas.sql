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
--Tabla servicio--
create table Servicio(
	Cod_servicio int not null,
	Cliente varchar(50) not null,
	Fecha_de_inicio date not null,
	fecha_de_finalizacion date not null,
	Descripcion varchar(150) not null,
	Costo money not null,
	primary key(Cod_servicio)
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
--tabla Conducir
create table Conducir(
	Cedula varchar(15) not null,
	Placa varchar(10) not null,
	Cod_servicio int not null,
	foreign key(Cedula) references Conductor(Cedula),
	foreign key (Placa) references Vehiculo(Placa),
	foreign key(Cod_servicio) references Servicio(Cod_servicio)
)
--table Hacer--
create table Hacer(
	Placa varchar(10) not null,
	Cod_mantenimiento int not null,
	Cod_reporte int not null,
	foreign key (Placa) references Vehiculo(Placa),
	foreign key(Cod_mantenimiento) references Mantenimiento(Cod_mantenimiento),
	foreign key(Cod_reporte) references Reporte(Cod_reporte)
)
select *from Conductor
select *from Vehiculo
select *from Servicio
select *from Reporte
select *from Mantenimiento
select *from Hacer
select *from Conducir
--INSERCION DE ALMENOS 1 DATO
insert into Conductor values ('70-0000-00000','Carlos','Escobar','8888-8888','1998-05-08','B-','C')
insert into Vehiculo values ('ER02','4LL','Sedan','Disponible',2,'95','Azul')
insert into Servicio values (67,'Jatech','2021-07-21','2021-07-19','Transporte de empleados',35.00)
insert into Reporte values (25,'Fuga de aceite','2021-07-19','Javier Rodriguez')
insert into Mantenimiento values(36,'Sellado de fuga','2021-07-19',24.00)
insert into Conducir values('70-0000-00000','ER02',67)
insert into Hacer values('ER02',36,25)
--ACTUALIZACION
update Conductor set Apellido='Arrosemena' where Cedula='70-0000-00000'
--Eliminacion
delete from Conductor where Cedula='70-0000-00000'

--ACTUALIZAR DATOS CONDUCTOR
exec actualizar_conductor '70-0000-00000','José','Barria','8888-8888','1998-05-08','B-','D'
--Eliminar registro conductor
delete from Conducir where Cedula='70-0000-00000'
delete from Conductor where Cedula='70-0000-00000'