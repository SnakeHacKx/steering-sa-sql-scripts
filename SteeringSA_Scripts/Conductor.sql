
-- Procedimiento para insertar conductor
ALTER PROC PROC_REGISTRAR_CONDUCTOR(
	@cedula VARCHAR(15),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@telefono VARCHAR(10),
	@fechaNac date,
	@tipoSangre VARCHAR(3),
	@tipoLicencia VARCHAR(2),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
-- Validar si el conductor existe
BEGIN TRAN
	IF NOT EXISTS(SELECT Cedula FROM Conductor WHERE Cedula = @cedula)
	BEGIN
		BEGIN TRY--INTENTAR INGRESAR LOS DATOS A LA TABLA 
			INSERT INTO Conductor(Cedula, Nombre, Apellido, Telefono, Fecha_de_nacimiento, Tipo_de_sangre, Tipo_de_licencia)
			VALUES(@cedula, @nombre, @apellido,@telefono, @fechaNac, @tipoSangre, @tipoLicencia)
			SET @MsgSuccess='Conductor registrado correctamente.'
			COMMIT TRAN--CONFIRMACION DE LA TRANSACCION
		END TRY
		BEGIN CATCH
			SET @MsgError= 'Ocurrió un errror inesperado al intentar registrar el conductor, inténtelo nuevamente'--MENSAJE EN CASO DE ERROR DE REGISTRO
			ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='Ya existe un conductor registrado con estos datos'--MENSAJE EN CASO DE QUE YA EXISTA UN CONDUCTOR REGISTRADO CON ESOS DATOS
		ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
	END
GO

--Procedimiento para actualizar Conductor
ALTER PROC PROC_ACTUALIZAR_CONDUCTOR(
	@cedula VARCHAR(15),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@telefono VARCHAR(10),
	@fechaNac date,
	@tipoSangre VARCHAR(3),
	@tipoLicencia VARCHAR(2),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
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
				SET @MsgSuccess='DATOS DEL CONDUCTOR ACTUALIZADOS EXITOSAMENTE'
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SET @MsgError='ERROR EN LA ACTUALIZACION DE LOS DATOS DEL CONDUCTOR'
				ROLLBACK TRAN
			END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='NO HAY CONDUCTOR REGISTRADO CON ESE NUMERO DE CÉDULA'
		ROLLBACK
	END
GO
--Procedimiento para eliminar conductores
ALTER PROC PROC_ELIMINAR_CONDUCTOR(@Cedula VARCHAR(15),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
AS
BEGIN
	BEGIN TRAN
	IF EXISTS (SELECT * FROM Conductor WHERE cedula = @Cedula)
	BEGIN
		BEGIN TRY
			DELETE FROM Conductor WHERE cedula = @Cedula
			SET @MsgSuccess='EL CONDUCTOR HA SIDO ELIMINADO EXITOSAMENTE'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='ERROR AL INTENTAR ELIMINAR EL CONDUCTOR SELECCIONADO'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='EL CONDUCTOR SELECCIONADO NO ESTA REGISTRADO EN LA BASE DE DATOS'
		ROLLBACK
	END
END
GO


--MOSTRAR TODOS
ALTER PROC PROC_LISTAR_TODOS_CONDUCTORES
AS
BEGIN
	SELECT *FROM V_GENERALES_DE_CONDUCTOR
	ORDER BY [Nombre completo]
END
GO


--BUSCAR CONDUCTOR POR NOMBRE
ALTER PROC PROC_BUSCAR_NOMBRE_CONDUCTOR(
	@Nombre VARCHAR(70),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CONDUCTOR WHERE [Nombre completo] LIKE '%'+@Nombre+'%')
	BEGIN
		SELECT *FROM V_GENERALES_DE_CONDUCTOR
		WHERE [Nombre completo] LIKE '%'+@Nombre+'%'
	END
	ELSE
		SET @MsgError='CONDUCTOR NO ENCONTRADO'
END
GO

--BUSCAR CONDUCTOR POR CEDULA 
CREATE PROC PROC_BUSCAR_CEDULA_CONDUCTOR(
	@Cedula VARCHAR(70),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CONDUCTOR WHERE [N° Cedula]=@Cedula)
	BEGIN
		SELECT *FROM V_GENERALES_DE_CONDUCTOR
		WHERE [N° Cedula]=@Cedula
	END
	ELSE
		SET @MsgError='CONDUCTOR NO ENCONTRADO'
END
GO





