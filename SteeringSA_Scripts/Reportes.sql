--Reporte

--PROCEDIMIENTO PARA REGISTRAR UN REPORTE
ALTER PROC PROC_REGISTRAR_REPORTE(
	@Placa_Vehiculo VARCHAR(10),
	@Descripcion VARCHAR(1500),
	@Fecha DATE,
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	--variable para guardar el codigo de reporte
	DECLARE @Cod_Reporte VARCHAR(10)
	--Se verifica la fecha de registro del reporte
	IF @Fecha<=Format(GETDATE(),'yyyy-MM-dd')
	BEGIN
		IF EXISTS (SELECT *FROM Vehiculo WHERE Placa=@Placa_Vehiculo)
		BEGIN
				--se genera el codigo de reporte con la funcion
				SET @Cod_Reporte = DBO.FUNC_GENERAR_COD_REPORTE(@Placa_Vehiculo)
				BEGIN TRY
					INSERT INTO Reporte(Cod_reporte,Placa_Vehiculo,Fecha,Descripcion)
					VALUES(@Cod_Reporte,@Placa_Vehiculo,@Fecha,@Descripcion)
					EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo Reporte'
					SET @MsgSuccess='Reporte registrado exitosamente'
					COMMIT
				END TRY
				BEGIN CATCH
					SET @MsgError= 'Error al intentar registrar el reporte'
					ROLLBACK
				END CATCH
		END
		ELSE
		BEGIN
			SET @MsgError='El vehiculo seleccionado para realizarle un reporte no se encuentra registrado en la base de datos'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='La fecha del reporte no puede ser mayor a la actual'
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ELIMINAR REPORTE
ALTER PROC PROC_ELIMINAR_REPORTE(
	@Cod_Reporte VARCHAR(10),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_Reporte)
	BEGIN
		BEGIN TRY
			DELETE FROM Reporte WHERE Cod_reporte=@Cod_Reporte
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un reporte'
			SET @MsgSuccess='Reporte eliminado correctamente'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='Error al intentar eliminar el reporte seleccionado'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='El reporte seleccionado no esta registrado en la base de datos'
		ROLLBACK
	END
END
GO



ALTER FUNCTION FUNC_GENERAR_COD_REPORTE(@Placa_Vehiculo VARCHAR(10))
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE
	 @Codigo VARCHAR(10),
	 @condicion INT,
	 @Num INT
	SET @Num =0
	SET @condicion =0
	WHILE(@condicion =0)--la condicion no se modifica dentro del ciclo asi que se hace hasta que se salga por la sentencia return
	BEGIN
		SET @Codigo = ''+SUBSTRING(@Placa_Vehiculo,1,3)+''+CAST(@Num AS VARCHAR(10))--el codigo de construye con las primeras 3 letras de la placa del vehiculo y con un numero segun la cantidad de reportes que tenga el vehiculo
		IF NOT EXISTS(SELECT * FROM Reporte WHERE Placa_Vehiculo = @Placa_Vehiculo AND Cod_reporte=@Codigo)--si verifica si el vehiculo no tiene el codigo generado ya registrado en un reporte
			RETURN (@Codigo)
		SET @Num=@Num+1--si el vehiculo ya tiene un reporte con el codigo generado, entonces se incrementa el numero que se le asigna al codigo
	END
	RETURN '-1'
END
GO

--PROCEDIMIENTO PARA MODIFICAR EL ESTADO DE LOS REPORTES AL REGISTRARSE UN MANTENIMIENTO
ALTER PROC PROC_ACTUALIZAR_ESTADO_REPORTES
AS
BEGIN
	BEGIN TRAN
	DECLARE 
	@Cod_repote VARCHAR(10),
	@Fecha_reporte DATE,
	@Estado VARCHAR(13)
	DECLARE C_RECORRER_REPORTES CURSOR LOCAL SCROLL --CURSOR PARA RECORRER CADA REPORTE
	FOR SELECT Cod_reporte,Fecha FROM Reporte
	OPEN C_RECORRER_REPORTES
	FETCH C_RECORRER_REPORTES INTO @Cod_repote,@Fecha_reporte
	WHILE(@@FETCH_STATUS=0)
	BEGIN
		IF EXISTS(SELECT *FROM Mantenimiento WHERE Cod_reporte=@Cod_repote AND Estado='Realizado')--SI EL REPORTE TIENE MANTENIMIENTO REGISTRADO Y EL MANTENIMIENTO FUE HECHO EL REPORTE FUE ATENDIDO
			SET @Estado='ATENDIDO'
		ELSE--DE LO CONTRARIO SI ES S/R O EL MANTENIMIENTO NO HA SIDO REALIZADO ENTONCES SE PONE NO ATENDIDO EL REPORTE
			SET @Estado='NO ATENDIDO'
		BEGIN TRY
			UPDATE Reporte SET Estado = @Estado WHERE Cod_reporte=@Cod_repote
		END TRY
		BEGIN CATCH
			RAISERROR('Error inesperado al intentar actualizar el estado de reportes',16,1)
			ROLLBACK
			RETURN
		END CATCH
		FETCH C_RECORRER_REPORTES INTO @Cod_repote,@Fecha_reporte
	END
	COMMIT
END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DE LOS REPORTES 
ALTER PROC PROC_ACTUALIZAR_DATOS_REPORTE(
	@Cod_Reporte VARCHAR(10),
	@Placa_Vehiculo VARCHAR(10),
	@Descripcion VARCHAR(1500),
	@Fecha DATE,
	@MsgSuccess VARCHAR(50) ='' OUTPUT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte = @Cod_Reporte)
	BEGIN
		IF NOT EXISTS(SELECT * FROM Mantenimiento WHERE Cod_reporte=@Cod_Reporte AND Fecha<FORMAT(@Fecha,'yyyy-MM-dd')) AND (FORMAT(@Fecha,'yyyy-MM-dd') <=FORMAT(GETDATE(),'yyyy-MM-dd'))  --SE VALIDA QUE LA NUEVA FECHA NO SEA MAYOR A LA FECHA DEL MANTENIMIENTO ASOCIADO A ESE REPORTE
		BEGIN
			BEGIN TRY
				UPDATE Reporte SET
				Placa_Vehiculo=@Placa_Vehiculo,
				Descripcion=@Descripcion,
				Fecha=@Fecha
				WHERE Cod_reporte=@Cod_Reporte
				EXEC PROC_ACTUALIZAR_ESTADO_REPORTES --Actualiza el estado del reporte
				EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un reporte'
				SET @MsgSuccess='Se actualizaron los datos del reporte exitosamente'
				COMMIT
			END TRY
			BEGIN CATCH
				SET @MsgError='Error al intentar actualizar los datos de un reporte'
				ROLLBACK
			END CATCH
		END
		ELSE
		BEGIN
			SET @MsgError='La nueva fecha seleccionada no puede ser mayor a la fecha del mantenimiento asociado al reporte'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='El reporte seleccionado no esta registrado en la base de datos'
		ROLLBACK
	END
END
GO

--MOSTRADO TODOS LOS REPORTES
ALTER PROC PROC_LISTAR_TODOS_REPORTES
AS
BEGIN
	SELECT * FROM V_GENERALES_DE_REPORTE
	ORDER BY ID
END
GO

--BUSCAR POR CODIGO DE REPORTE
CREATE PROC PROC_BUSCAR_CODIGO_REPORTE(
	@Cod_Reporte VARCHAR(10),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT * FROM V_GENERALES_DE_REPORTE WHERE [ID]=@Cod_Reporte)
	BEGIN
		SELECT * FROM V_GENERALES_DE_REPORTE 
		WHERE [ID]=@Cod_Reporte
	END
	ELSE
		SET @MsgError='Reporte no encontrado'
END
GO

--FILTRO
ALTER PROC PROC_FILTRO_REPORTE(
	@Fecha_inicio DATE = NULL,
	@Fecha_final DATE = NULL,
	@Estado_reporte VARCHAR(13) = NULL,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF (@Fecha_inicio<=@Fecha_final) OR (@Fecha_inicio IS NULL AND @Fecha_final IS NULL)
	BEGIN
		SELECT * FROM V_GENERALES_DE_REPORTE
		WHERE ((CONVERT(DATETIME,[Fecha de Registro],103) BETWEEN @Fecha_inicio AND @Fecha_final) OR (@Fecha_inicio IS NULL AND @Fecha_final IS NULL))--Si el parametro fue seleccionado como filtro desde la GUI entonces sera distinto de null y se buscara en la base de datos, si no lo encuentra la condicion entonces sera false
			AND (Estado =@Estado_reporte OR @Estado_reporte IS NULL)															--en caso de que no haya sido seleccionado el parametro como filtro entonces vendra como Null lo que hace que la condicion sea true pero no busca en la base de datos
	END
	ELSE
		SET @MsgError='INTERVALO DE FECHA NO VALIDO ¡VERIFIQUE LOS VALORES!'
END
GO
