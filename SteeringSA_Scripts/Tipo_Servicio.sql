--TIPO DE SERVICIO
--REGISTRAR NUEVO TIPO DE SERVICIO
ALTER PROC PROC_REGISTRAR_TIPO_SERVICIO(@Nombre VARCHAR(40),@Costo MONEY,@Descripcion VARCHAR(1500),@MsgSuccess VARCHAR(50)='' OUTPUT,@MsgError VARCHAR(50)='' OUTPUT)
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		INSERT INTO Tipo_servicios(Nombre_servicio,Costo_servicio,Descripcion_servicio)
		VALUES(@Nombre,@Costo,@Descripcion)
		EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo tipo de servicio'
		SET @MsgSuccess='Tipo de servicio registrado correctamente'
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		SET @MsgError='Error al intentar registrar un nuevo tipo de servicio'
		ROLLBACK
	END CATCH
END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DE LOS TIPOS DE SERVICIO
ALTER PROC PROC_ACTUALIZAR_DATOS_T_SERVICIOS(@Codigo INT, @Nombre VARCHAR(40),@Costo MONEY,@Descripcion VARCHAR(1500),@MsgSuccess VARCHAR(50)='' OUTPUT,@MsgError VARCHAR(50) =''OUTPUT)
AS
BEGIN
BEGIN TRAN
	IF EXISTS(SELECT *FROM Tipo_servicios WHERE Cod_tipo_servicio=@Codigo)
	BEGIN
		BEGIN TRY
			UPDATE Tipo_servicios SET
			Nombre_servicio=@Nombre,
			Costo_servicio=@Costo,
			Descripcion_servicio=@Descripcion
			WHERE Cod_tipo_servicio=@Codigo
			EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un tipo de servicio'
			SET @MsgSuccess='Datos del tipo de servicio actualizados correctamente'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='Error al intentar actualizar los datos del tipo de servicio'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='No existe el tipo de servicio asociado al codigo que ha ingresado'
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ELIMINAR TIPOS DE SERVICIO
ALTER PROC PROC_ELIMINAR_TIPO_SERVICIO(@Codigo_Tipo_Servicio INT,@MsgSuccess VARCHAR(50) ='' OUTPUT,@MsgError VARCHAR(50)='' OUTPUT)
AS
BEGIN
BEGIN TRAN
	IF EXISTS(SELECT * FROM Tipo_servicios WHERE Cod_tipo_servicio=@Codigo_Tipo_Servicio)
	BEGIN
		BEGIN TRY
			DELETE FROM Tipo_servicios WHERE Cod_tipo_servicio=@Codigo_Tipo_Servicio
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un tipo de servicio'
			SET @MsgSuccess = 'Tipo de servicio eliminado correctamente'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError= 'Error al intentar eliminar el tipo de servicio'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError=('El tipo de servicio que se quiere eliminar no esta registrado en la base de datos')
		ROLLBACK
	END
END
GO

--MOSTRAR TODOS
ALTER PROC PROC_LISTAR_TODOS_T_SERVICIOS
AS
BEGIN
	SELECT * FROM V_GENERALES_DE_TIPO_DE_SERVICIO
	ORDER BY Codigo
END
GO

--BUSCAR POR CODIGO TIPO DE servicio
CREATE PROC PROC_BUSCAR_CODIGO_TIPO_SERVICIO(
	@Codigo_Tipo_Servicio INT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT * FROM V_GENERALES_DE_TIPO_DE_SERVICIO WHERE Codigo=@Codigo_Tipo_Servicio)
	BEGIN
		SELECT * FROM V_GENERALES_DE_TIPO_DE_SERVICIO 
		WHERE Codigo=@Codigo_Tipo_Servicio
	END
	ELSE
		SET @MsgError='TIPO DE SERVICIO NO ENCONTRADO'
END
GO

--OBTENER NOMBRE DEL TIPO DE SERVICIO
CREATE PROC PROC_OBTENER_NOMBRES_T_SERVICIO
AS
BEGIN
	SELECT [Nombre del servicio] FROM V_GENERALES_DE_TIPO_DE_SERVICIO
END
GO
