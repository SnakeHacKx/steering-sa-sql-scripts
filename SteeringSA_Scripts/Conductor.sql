
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
			EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo conductor'
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
				EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un conductor'
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
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS (SELECT * FROM Conductor WHERE cedula = @Cedula)
	BEGIN
		BEGIN TRY
			DELETE FROM Conductor WHERE cedula = @Cedula
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un conductor'
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
	ORDER BY Nombre
END
GO


--BUSCAR CONDUCTOR POR NOMBRE
ALTER PROC PROC_BUSCAR_NOMBRE_CONDUCTOR(
	@Nombre VARCHAR(70),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CONDUCTOR WHERE Nombre+' '+Apellido LIKE '%'+@Nombre+'%')
	BEGIN
		SELECT * FROM V_GENERALES_DE_CONDUCTOR
		WHERE Nombre+' '+Apellido LIKE '%'+@Nombre+'%'
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

---FILTROS
ALTER PROC PROC_FILTRO_CONDUCTOR(
	@Nombre VARCHAR(70),
	@Tipo_de_licencia VARCHAR(2)=NULL,
	@Edad_menor INT =NULL,
	@Edad_mayor INT =NULL,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF @Edad_menor<=@Edad_mayor OR (@Edad_menor IS NULL AND @Edad_mayor IS NULL)
	BEGIN
		IF EXISTS(SELECT *FROM V_GENERALES_DE_CONDUCTOR WHERE Licencia =@Tipo_de_licencia OR (Edad BETWEEN @Edad_menor AND @Edad_mayor) OR (Nombre+' '+Apellido LIKE '%'+@Nombre+'%'))
		BEGIN
			SELECT *FROM V_GENERALES_DE_CONDUCTOR
			WHERE (Licencia =@Tipo_de_licencia OR @Tipo_de_licencia IS NULL)--Si el parametro fue seleccionado como filtro desde la GUI entonces sera distinto de null y se buscara en la base de datos, si no lo encuentra la condicion entonces sera false
			AND ((Edad BETWEEN @Edad_menor AND @Edad_mayor) OR (@Edad_menor IS NULL AND @Edad_mayor IS NULL))--en caso de que no haya sido seleccionado el parametro como filtro entonces vendra como Null lo que hace que la condicion sea true pero no busca en la base de datos
			AND((Nombre+' '+Apellido LIKE '%'+@Nombre+'%')OR (@Nombre IS NULL))
		END
		ELSE
			SET @MsgError='NO HAY REGISTROS REGISTRADOS DENTRO DE LOS PARAMETROS DE FILTRADO'
	END
	ELSE
		SET @MsgError='INTERVALO DE EDAD NO VALIDO ¡VERIFIQUE LOS VALORES!'
END
GO


