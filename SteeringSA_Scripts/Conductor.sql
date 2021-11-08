DELETE FROM Conductor
go

-- Procedimiento para insertar conductor
ALTER PROC PROC_REGISTRAR_CONDUCTOR(
	@cedula VARCHAR(15),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@telefono VARCHAR(10),
	@fechaNac date,
	@tipoSangre VARCHAR(3),
	@tipoLicencia VARCHAR(2)
)
AS
-- Validar si el conductor existe
BEGIN TRAN
	IF NOT EXISTS(SELECT Cedula FROM Conductor WHERE Cedula = @cedula)
	BEGIN
		BEGIN TRY--INTENTAR INGRESAR LOS DATOS A LA TABLA 
			INSERT INTO Conductor(Cedula, Nombre, Apellido, Telefono, Fecha_de_nacimiento, Tipo_de_sangre, Tipo_de_licencia)
			VALUES(@cedula, @nombre, @apellido,@telefono, @fechaNac, @tipoSangre, @tipoLicencia)
			COMMIT TRAN--CONFIRMACION DE LA TRANSACCION
		END TRY
		BEGIN CATCH
			RAISERROR('OCURRIO UN ERROR INESPERADO, INTENTE NUEVAMENTE', 15,1)--MENSAJE EN CASO DE ERROR DE REGISTRO
			ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
		END CATCH
	END
	ELSE
	BEGIN
		RAISERROR('YA EXISTE UN CONDUCTOR REGISTRADO CON ESTOS DATOS',12,1)--MENSAJE EN CASO DE QUE YA EXISTA UN CONDUCTOR REGISTRADO CON ESOS DATOS
		ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
	END
GO

--Procedimiento para actualizar Conductor
CREATE PROC PROC_ACTUALIZAR_CONDUCTOR(
	@cedula VARCHAR(15),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@telefono VARCHAR(10),
	@fechaNac date,
	@tipoSangre VARCHAR(3),
	@tipoLicencia VARCHAR(2)
)
AS
	IF EXISTS(SELECT Cedula FROM Conductor WHERE Cedula = @cedula)
	BEGIN
		BEGIN TRAN
			BEGIN TRY
				UPDATE Conductor SET Nombre=@nombre,
				Apellido=@apellido,
				Telefono=@telefono,
				Fecha_de_nacimiento=@fechaNac,
				Tipo_de_sangre=@tipoSangre,
				Tipo_de_licencia=@tipoLicencia
				WHERE Cedula=@cedula;
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				RAISERROR('ERROR EN LA ACTUALIZACION DE LOS DATOS DEL CONDUCTOR',12,1)
				ROLLBACK TRAN
			END CATCH
	END
	ELSE
	BEGIN
		RAISERROR('NO HAY CONDUCTOR REGISTRADO CON ESE NUMERO DE CÉDULA',5,1)
	END
GO
SELECT * FROM Conductor
go
--Procedimiento para eliminar conductores
ALTER PROC PROC_ELIMINAR_CONDUCTOR(@Cedula VARCHAR(15))
AS
BEGIN
	BEGIN TRAN
	IF EXISTS (SELECT * FROM Conductor WHERE cedula = @Cedula)
	BEGIN
		BEGIN TRY
			DELETE FROM Conductor WHERE cedula = @Cedula
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('ERROR AL INTENTAR ELIMINAR EL CONDUCTOR SELECCIONADO',16,1)
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		RAISERROR('EL CONDUCTOR SELECCIONADO NO ESTA REGISTRADO EN LA BASE DE DATOS',16,1)
		ROLLBACK
	END
END
GO

--EJECUTAR HASTA AQUI 


/*
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
go*/