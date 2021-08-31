select * from Conductor

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