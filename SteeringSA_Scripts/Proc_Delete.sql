use [Steering S.A];
go
select * from Conducir
select * from Servicio
select *from Mantenimiento
select *from Reporte
select *from Vehiculo
Select *from Hacer
select* from Conductor


go
delete from Reporte where Cod_reporte=4
go




--Procedimiento para Eliminar Servicio
create proc eliminar_servicio
@Cod_s int
as
begin
	delete from Conducir
	where Cod_servicio=@Cod_s;
	delete from Servicio
	where Cod_servicio=@Cod_s;
	update V set V.Estado='Disponible' from Vehiculo V join Conducir C on C.Placa=V.Placa where C.Cod_servicio=@Cod_s
end
GO

--Procedimiento para eliminar Mantenimiento
create proc eliminar_mantenimiento
	@cod_m int
as
begin
	update Hacer set Cod_mantenimiento=-1 where Cod_mantenimiento=@cod_m;
	delete from Mantenimiento where Cod_mantenimiento=@cod_m and @cod_m<>-1;
end;
go
--eliminar reporte
create proc eliminar_reporte
	@cod_r int
as
begin
	delete from Hacer where Cod_reporte=@cod_r
	delete from Reporte where Cod_reporte=@cod_r
end;
go
--eliminar vehiculo
create proc eliminar_vehiculo
	@matricula varchar(10)
as 
begin
	delete from Vehiculo where Placa=@matricula
end;
go
