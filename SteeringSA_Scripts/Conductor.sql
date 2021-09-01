SELECT * FROM Conductor

-- Procedimiento para insertar conductor
ALTER PROC insertar_conductor(
	@cedula varchar(15),
	@nombre varchar(30),
	@apellido varchar(30),
	@telefono varchar(10),
	@fechaNac date,
	@tipoSangre varchar(5),
	@tipoLicencia varchar(5),

	@MsjExito varchar(50) = '' output,
	@MsjError varchar(50) = '' output
)
as
-- Validar si el conductor existe
begin tran
if not exists(select top 1 Cedula from Conductor where Cedula = @cedula)
begin
	insert into Conductor(Cedula, Nombre, Apellido, Telefono, Fecha_de_nacimiento, Tipo_de_sangre, Tipo_de_licencia)
	values(@cedula, @nombre, @apellido,@telefono, @fechaNac, @tipoSangre, @tipoLicencia)
	commit tran 
	set @MsjExito = 'El conductor fue registrado exitosamente'
end
else
begin
	rollback tran
	set @MsjError = 'Ya existe un coductor con esta cedula'
end
go

--Procedimiento para actualizar Conductor
create proc actualizar_conductor
	@cedula varchar(15),
	@nombre varchar(30),
	@apellido varchar(30),
	@telefono varchar(10),
	@fechaNac date,
	@tipoSangre varchar(5),
	@tipoLicencia varchar(5),

	@MsjExito varchar(50) = '' output,
	@MsjError varchar(50) = '' output
as
begin tran
if exists(select top 1 Cedula from Conductor where Cedula = @cedula)
begin
	update Conductor set Nombre=@nombre,
	Apellido=@apellido,
	Telefono=@telefono,
	Fecha_de_nacimiento=@fechaNac,
	Tipo_de_sangre=@tipoSangre,
	Tipo_de_licencia=@tipoLicencia
	where Cedula=@cedula;

	commit tran
	set @MsjExito = 'El conductor fue actualizado exitosamente'
end
else
begin
	rollback tran
	set @MsjError = 'No existe un coductor con esta cedula'
end
go

--Procedimiento para eliminar conductores
alter proc eliminar_conductor
	@cedula varchar(15),

	@MsjExito varchar(50) = '' output,
	@MsjError varchar(50) = '' output
as
begin tran
if exists(select top 1 Cedula from Conductor where Cedula = @cedula)
begin
	delete from Conductor where Cedula=@cedula

	commit tran
	set @MsjExito = 'El conductor fue eliminado exitosamente'
end
else
begin
	rollback tran
	set @MsjError = 'No existe un coductor con esta cedula'
end
go

-- CONSULTAS --

--Mostrar servicios asignados a un conductor
create proc ver_servicios_conductor
@cedula varchar(15)
as
begin
	select S.Cod_servicio,S.Cliente,S.Fecha_de_inicio as[Fecha Inicio],
	S.fecha_de_finalizacion as [Fecha Final],S.Descripcion,Costo,Conducir.Placa as [vehiculo Asignado] from Conducir
	join Conductor C on Conducir.Cedula=C.Cedula
	join Servicio S on Conducir.Cod_servicio=S.Cod_servicio
	where Conducir.Cedula=@cedula order by S.Cod_servicio asc
end
go

--Mostrar los conductores deacuerdo a la licencia
create proc ver_por_licencia
@tipoLicencia varchar(5)
as
begin
	select * from Conductor where Tipo_de_licencia=@tipoLicencia order by Cedula asc
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