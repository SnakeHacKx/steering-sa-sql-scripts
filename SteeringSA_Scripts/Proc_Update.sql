
select * from Conducir
select * from Servicio
Select *from Hacer
select* from Conductor
select *from Mantenimiento
select *from Reporte
select *from Vehiculo
go
--Procedimiento para Actualizar los datos del servicio y la tabla conducir
create proc actualizar_servicio 
@Cod_s int,
@Client varchar(50),
@F_init date,
@F_end date,
@desc varchar(150),
@cost money,
@ced varchar(15),
@matricula varchar(10)
as
begin
 update Servicio set Cliente=@Client,Fecha_de_inicio=@F_init,fecha_de_finalizacion=@F_end,Descripcion=@desc,Costo=@cost
 where Cod_servicio=@Cod_s;
 update Conducir set Cedula=@ced, Placa=@matricula where Cod_servicio=@Cod_s
end
go

--Procedimiento para Actualizar un mantenimiento
create proc actualizar_mantenimiento
@Cod_m int,
@desc varchar(25),
@date date,
@cost money,
@matricula varchar(10),
@cod_r int
as
begin
	update Mantenimiento set Descripcion=@desc,Fecha= @date ,Costo=@cost
	where Cod_mantenimiento=@Cod_m;
	update Hacer set Cod_mantenimiento = -1 where Cod_reporte = (select Cod_reporte from Hacer where Cod_mantenimiento=@Cod_m);
	update Hacer set Cod_mantenimiento = @cod_m where Cod_reporte = @cod_r
end
GO

--Procedimiento para Actualizar reporte
create proc actualizar_reporte
@cod int,
@desc varchar(150),
@F date,
@resp varchar(75),
@plac varchar(10)
as
begin
	update Hacer set Placa=@plac, Cod_reporte=@cod where Cod_reporte=@cod and Cod_mantenimiento=-1
	update reporte set Descripcion=@desc,Fecha=@F,Responsable=@resp where Cod_reporte=@cod
end
go

--Procedimiento para actualizar Conductor
create proc actualizar_conductor
@ced varchar(15),
@nom varchar(30),
@ap varchar(30),
@tel int,
@F date,
@sangre varchar(5),
@lic varchar(5)
as
begin
	update Conductor set Nombre=@nom,Apellido=@ap,Telefono=@tel,Fecha_de_nacimiento=@F,Tipo_de_sangre=@sangre,Tipo_de_licencia=@lic
	where Cedula=@ced;
end
go

--procedimiento para actualizar vehiculo
create proc actualizar_vehiculo
@matricula varchar(10),
@mot varchar(50),
@tip varchar(20),
@pas smallint,
@combustible varchar(10),
@col varchar(10)
as
begin
	update Vehiculo set Placa=@matricula,Motor=@mot,Tipo=@tip,pasajeros=@pas,Tipo_de_combustible=@combustible,Color=@col
	where Placa=@matricula;
end
go


