--Procedimientos para las consultas por radio button
select *from Hacer
go


-------------------------------------------------Conductor------------------------------------------------------
--Mostrar servicios asignados a un conductor

create proc ver_servicios_conductor
@ced varchar(15)
as
begin
	select S.Cod_servicio,S.Cliente,S.Fecha_de_inicio as[Fecha Inicio],
	S.fecha_de_finalizacion as [Fecha Final],S.Descripcion,Costo,Conducir.Placa as [vehiculo Asignado] from Conducir
	join Conductor C on Conducir.Cedula=C.Cedula
	join Servicio S on Conducir.Cod_servicio=S.Cod_servicio
	where Conducir.Cedula=@ced order by S.Cod_servicio asc
end
go
exec ver_servicios_conductor '00-0000-00001'
go

--Mostrar los conductores deacuerdo a la licencia
create proc mostar_por_licencia
@tipo varchar(5)
as
begin
	select *from Conductor where Tipo_de_licencia=@tipo order by Cedula asc
end
go


--Mostrar deacuerdo a los servicios entre fechas
create proc ver_por_fecha
@finit date,
@fend date
as
begin
	select C.Cedula,Nombre,Apellido,C.Telefono,S.Cod_servicio,S.Cliente,S.Fecha_de_inicio as Inicio,
	S.fecha_de_finalizacion as Final,S.Descripcion,V.Placa as[Vehiculo asignado],V.Tipo,V.Color from Conducir
	join Conductor C on Conducir.Cedula=C.Cedula
	join Servicio S on Conducir.Cod_servicio=S.Cod_servicio
	join Vehiculo V on V.Placa = Conducir.Placa
	where S.Fecha_de_inicio>=@finit and S.fecha_de_finalizacion <=@fend order by C.Cedula asc
end
go
exec ver_por_fecha '07-06-2021','07-08-2021'
go


----------------------------------------------------------------------------------------------------------------------------------
--Vehiculo

--Mostrar servicios asignados a un vehiculo
create proc ver_servicios_vehiculo
@matricula varchar(10)
as
begin
	select S.Cod_servicio as [Codigo de Servicio],S.Cliente,S.Descripcion,S.Fecha_de_inicio as Inicio,S.fecha_de_finalizacion as Final,Costo,Conducir.Cedula as [Cedula Conductor] from Conducir 
	join Vehiculo V on V.Placa=Conducir.Placa
	join Servicio S on S.Cod_servicio=Conducir.Cod_servicio
	where Conducir.Placa=@matricula order by S.Cod_servicio asc
end
go
exec ver_servicios_vehiculo '0202'
go


--Mostrar vehiculo por combustible
create proc ver_por_combustible
@tipo varchar(10)
as
begin
	select *from Vehiculo where Tipo_de_combustible=@tipo order by Placa asc
end
go
exec ver_por_combustible '95'
--Mostrar vehiculo por fechas de mantenimiento
go
create proc fecha_de_matenimiento
@finit date,
@fend date
as
begin
	select V.Placa as Matricula,V.Motor,Tipo,Tipo_de_combustible,M.Cod_mantenimiento,M.Descripcion,M.Costo,M.Fecha,Hacer.Cod_reporte as [Codigo reporte] from Hacer join Mantenimiento M on M.Cod_mantenimiento=Hacer.Cod_mantenimiento
	join Vehiculo V on V.Placa=Hacer.Placa
	where M.Fecha between @finit and @fend order by V.Placa asc
end
go
exec fecha_de_matenimiento '2021-07-13','2021-07-19'

-------------------------------------------------------------------------------------------------------------------------------------------------
--Servicio
--Mostrar los servicios sin vencer fecha de finalizacion
go
create proc	Servicios_sin_vencer
@fend date
as
begin
	select S.Cod_servicio as Codigo,S.Cliente,S.Descripcion,S.Costo,S.Fecha_de_inicio as [Fecha inicial],S.fecha_de_finalizacion as [Fecha final],Conducir.Cedula as [Cedula de conductor],Conducir.Placa as[Matricula asignada] from Conducir
	join Servicio S on S.Cod_servicio=Conducir.Cod_servicio
	where S.fecha_de_finalizacion<=@fend order by S.Cod_servicio asc
end
go
exec Servicios_sin_vencer '2021-07-06'
go
--Mostrar servicion en rango de fechas
create proc fecha_de_servicio
@finit date,
@fend date
as
begin
	select S.Cod_servicio as Codigo,S.Cliente,S.Descripcion,S.Fecha_de_inicio as [Fecha inicial], S.fecha_de_finalizacion as [Fecha final],S.Costo,C.Cedula as [Cedula conductor],C.Placa as [Matricula vehiculo] from Conducir C 
	join servicio S on S.Cod_servicio=C.Cod_servicio
	where S.Fecha_de_inicio>=@finit and S.fecha_de_finalizacion <=@fend order by S.Cod_servicio asc
end
go



-------------------------------------------------------------------------------------------------------------------------------------------------
--Mantenimientos
--mantenimientos en curso
create proc Por_Conductor
@ced varchar(15)
as
begin
	select distinct M.Cod_mantenimiento as [Codigo mantenimiento],M.Descripcion,M.Costo,M.Fecha, H.Cod_reporte as [Codigo reporte],V.Placa as [Matricula Vehiculo],V.Color,V.Tipo,V.Motor from Hacer H
	join Vehiculo V on V.Placa=H.Placa
	join Mantenimiento M on M.Cod_mantenimiento=H.Cod_mantenimiento
	join Conducir C on C.Placa=V.Placa
	Where C.Cedula=@ced and M.Cod_mantenimiento<>-1 order by M.Cod_mantenimiento
end
go
exec Por_Conductor '00-0000-00001'
go
--Mostrar por vehiculo
create proc mantenimiento_vehiculo
@matricula varchar(10)
as
begin
	select distinct M.Cod_mantenimiento as [Codigo mantenimiento],Placa as matricula,M.Descripcion as [Descripcion mantenimiento],M.Costo,M.Fecha,R.Cod_reporte as [Codigo de reporte],R.Descripcion as [Descripcion reporte] from Hacer
	join Mantenimiento M on M.Cod_mantenimiento=Hacer.Cod_mantenimiento
	join Reporte R on R.Cod_reporte=Hacer.Cod_reporte
	where Hacer.Placa=@matricula and Hacer.Cod_mantenimiento<>-1 order by M.Cod_mantenimiento asc

end
go
exec mantenimiento_vehiculo '0202'
go
--Mostrar mantenimiento en rango de fechas
create proc mantenimiento_fechas
@finit date,
@fend date
as
begin
	select distinct M.Cod_mantenimiento as [Codigo mantenimiento],V.Placa as matricula,M.Descripcion as [Descripcion mantenimiento],M.Costo,M.Fecha,R.Cod_reporte as [Codigo de reporte],R.Descripcion as [Descripcion reporte] from Hacer
	join Mantenimiento M on M.Cod_mantenimiento=Hacer.Cod_mantenimiento
	join Reporte R on R.Cod_reporte=Hacer.Cod_reporte
	join Vehiculo V on V.Placa=Hacer.Placa
	where (M.Fecha between @finit and @fend) and Hacer.Cod_mantenimiento<>-1 order by M.Cod_mantenimiento asc
end
go

-----------------------------------------------------------------------------------------------------------------------------------------------------
--Reporte
--Mostrar pendientes de atencion
create proc pendientes
as
begin
	select R.Cod_reporte as [Codigo reporte],R.Descripcion, R.Responsable,R.Fecha, H.Placa as Matricula from Hacer H
	join Reporte R on R.Cod_reporte=H.Cod_reporte
	where H.Cod_mantenimiento=-1 order by H.Placa asc
end
go
exec pendientes
go
--por vehiculo
create proc reporte_vehiculo
@matricula varchar(10)
as
begin
	select R.Cod_reporte as[Codigo Reporte],R.Descripcion as[Descripcion Reporte],R.Responsable,R.Fecha as[Fecha Reporte],M.Descripcion[Descripcion Mantenimiento] from Hacer H
	join Reporte R on R.Cod_reporte=H.Cod_reporte
	join Mantenimiento M on M.Cod_mantenimiento=H.Cod_mantenimiento
	where H.Placa=@matricula order by R.Cod_reporte asc
end
go
exec reporte_vehiculo '1'
--rango de fechas
go
create proc fechas_reporte
@finit date,
@fend date
as
begin
	select R.Cod_reporte as[Codigo Reporte],R.Descripcion as[Descripcion Reporte],R.Responsable,R.Fecha as[Fecha Reporte],M.Descripcion[Descripcion Mantenimiento], H.Placa as [Matricula Vehiculo] from Hacer H
	join Reporte R on R.Cod_reporte=H.Cod_reporte
	join Mantenimiento M on M.Cod_mantenimiento=H.Cod_mantenimiento
	where R.Fecha between @finit and @fend order by R.Cod_reporte asc
end

select *from Hacer