--RELACION DE ASIGNACION DE SERVICIOS-----
--REGISTRAR SERVICIO
GO
ALTER PROC PROC_REGISTRAR_SERVICIO(
@Codigo_Tipo_servicio int, 
@Cedula_Conductor varchar(15),
@Cedula_Cliente varchar(15),
@Placa_Vehiculo varchar(10),
@F_Inicio datetime,
@F_Final datetime,
@MsgSuccess VARCHAR(50) ='' OUTPUT,
@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	DECLARE @Monto_Total money,-- EL TOTAL A PAGAR POR LOS DIAS QUE SE REALIZO EL SERVICIO
	@Validacion INT--SEGUNA EL VALOR QUE TENGA SE IMPRIME UN MENSAJE DE ERROR DIFERENTE
	--SE VERIFICA QUE NO HAYA UN CONDUCTOR REGISTRADO ENTRE LAS FECHAS DEL NUEVO SERVICIO A REALIZAR
	IF NOT EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor and (@F_Inicio between Fecha_inicio and Fecha_finalizacion) and (@F_Final between Fecha_inicio and Fecha_finalizacion))
	BEGIN--SE VERIFICA QUE EL VEHICULO NO ESTE REGISTRADO ENTRE LAS FECHAS PARA VER SI ESTA DISPONIBLE
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa_Vehiculo and (@F_Inicio between Fecha_inicio and Fecha_finalizacion) and (@F_Final between Fecha_inicio and Fecha_finalizacion))
		BEGIN	
			SET @Validacion = DBO.FUNC_VALIDACION_REGISTRO_SERVICIO(@Codigo_Tipo_servicio,@Cedula_Conductor,@Cedula_Cliente,@Placa_Vehiculo)
			IF  @Validacion= 0
			BEGIN--SE VALIDA QUE LOS PARAMETROS EXISTAN EN SUS CORRESPONDIENTES TABLAS
				SET @Monto_Total = DBO.FUNC_CALCULAR_MONTO_TOTAL_SERVICIO(@F_Inicio,@F_Final,@Codigo_Tipo_servicio) --SE CALCULA EL MONTO TOTAL
				BEGIN
					BEGIN TRY --INICIO DE LA INSERCION EN LA TABLA SERVICIO
						INSERT INTO Servicio(Cod_tipo_servicio,Cedula_Conductor,Placa,Cedula_Cliente,Fecha_inicio,Fecha_finalizacion,Monto_Total_Servicio)
						VALUES(@Codigo_Tipo_servicio,@Cedula_Conductor,@Placa_Vehiculo,@Cedula_Cliente,@F_Inicio,@F_Final,@Monto_Total)
						EXEC PROC_ACTUALIZAR_ESTADO_VEHICULOS
						EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo servicio'
						SET @MsgSuccess='SERVICIO REGISTRADO EXITOSAMENTE'
						COMMIT TRAN
					END TRY
					BEGIN CATCH
						SET @MsgError='ERROR AL INTENTAR REGISTRAR EL SERVICIO'
						ROLLBACK
					END CATCH
				END
			END
			ELSE
			BEGIN
				SET @MsgError=        --IMPRIME EL MENSAJE DE ERROR SEGUN LO QUE NO SE ENCUENTRE REGISTRADO
					CASE 
						WHEN @Validacion = 1 THEN 'EL TIPO DE SERVICIO SELECCIONADO NO CORRESPONDE A NINGUNO QUE OFREZCA LA EMPRESA'
						WHEN @Validacion = 2 THEN 'LA CEDULA DEL CONDUCTOR SELECCIONADO NO SE ENCUENTRA REGISTRADA EN LA BASE DE DATOS'
						WHEN @Validacion = 3 THEN 'LA CEDULA DEL CLIENTE SELECCIONADO NO SE ENCUENTRA EN LA BASE DE DATOS'
						WHEN @Validacion = 4 THEN 'EL VEHICULO SELECCIONADO NO SE ENCUENTRA REGISTRADO EN LA BASE DE DATOS COMO PARTE DE LA FLOTA'
					END
					ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='EL VEHICULO SELECCIONADO ESTA OCUPADO PARA ESA FECHA'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='EL CONDUCTOR SELECCIONADO ESTA OCUPADO PARA ESA FECHA'
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DE SERVICIOS
ALTER PROC PROC_ACTUALIZAR_DATOS_SERVICIO(
@Cod_Servicio INT,
@Cod_tipo_servicio INT,
@Cedula_Conductor VARCHAR(15),
@Placa VARCHAR(10),
@Cedula_Cliente VARCHAR(15),
@Fecha_inicio DATE,
@Fecha_finalizacion DATE,
@MsgSuccess VARCHAR(50) ='' OUTPUT,
@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS (SELECT * FROM Servicio WHERE Cod_Servicio=@Cod_Servicio)
	BEGIN
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa and (@Fecha_inicio between Fecha_inicio and Fecha_finalizacion) and (@Fecha_finalizacion between Fecha_inicio and Fecha_finalizacion)) OR EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa AND Cod_Servicio=@Cod_Servicio)
		BEGIN
			IF NOT EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor and (@Fecha_inicio between Fecha_inicio and Fecha_finalizacion) and (@Fecha_finalizacion between Fecha_inicio and Fecha_finalizacion)) OR EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor AND Cod_Servicio = @Cod_Servicio)
			BEGIN
				BEGIN TRY
					UPDATE Servicio SET Cod_tipo_servicio=@Cod_tipo_servicio,
					Cedula_Conductor=@Cedula_Conductor,
					Cedula_Cliente=@Cedula_Cliente,
					Placa= @Placa,
					Fecha_inicio=@Fecha_inicio,
					Fecha_finalizacion=@Fecha_finalizacion,
					Monto_Total_Servicio=DBO.FUNC_CALCULAR_MONTO_TOTAL_SERVICIO(@Fecha_inicio,@Fecha_finalizacion,@Cod_tipo_servicio)
					WHERE Cod_Servicio=@Cod_Servicio
					EXEC PROC_ACTUALIZAR_ESTADO_VEHICULOS --solo actualiza el estado del vehiculo asignado
					EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un servicio'
					SET @MsgSuccess='DATOS DEL SERVICIO ACTUALIZADOS EXITOSAMENTE'
					COMMIT
				END TRY
				BEGIN CATCH
					SET @MsgError='ERROR AL INTENTAR ACTUALIZAR LOS DATOS DEL SERVICIO'
					ROLLBACK
				END CATCH
			END
			ELSE
			BEGIN
				SET @MsgError='EL CONDUCTOR ASIGNADO NO ESTA DISPONIBLE PARA LA FECHA DE ESTE EVENTO'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='EL VEHICULO ASIGNADO NO ESTA DISPONIBLE PARA LA FECHA DE ESTE EVENTO'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError= 'EL SERVICIO SELECCIONADO NO ESTA REGISTRADO EN LA BASE DE DATOS'
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ELIMINAR SERVICIO
ALTER PROC PROC_ELIMINAR_SERVICIO(@Codigo_Servicio INT,
@MsgSuccess VARCHAR(50) ='' OUTPUT,
@MsgError VARCHAR(50) ='' OUTPUT)
AS
BEGIN
BEGIN TRAN
	IF EXISTS (SELECT *FROM Servicio WHERE Cod_Servicio=@Codigo_Servicio)
	BEGIN
		BEGIN TRY
			DELETE FROM Servicio WHERE Cod_Servicio =@Codigo_Servicio
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un servicio'
			SET @MsgSuccess='SERVICIO ELIMINADO EXITOSAMENTE'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='ERROR AL INTENTAR ELIMINAR EL SERVICIO SELECCIONADO'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='EL CODIGO DE SERVICIO SELECCIONADO NO CORRESPONDE A NINGUN SERVICIO REGISTRADO'
		ROLLBACK
	END

END
GO

--FUNCION PARA CALCULAR EL MONTO TOTAL DEL SERVICIO POR LA CANTIDAD DE DIAS
CREATE FUNCTION FUNC_CALCULAR_MONTO_TOTAL_SERVICIO(@F_Inicio date,@F_Final date,@Codigo_Tipo_servicio int)
RETURNS MONEY
AS
BEGIN
	DECLARE @Cantidad_Dias INT,--DIAS QUE TOMARA PARA REALIZAR EL SERVICIO
			@Monto_Total money-- EL TOTAL A PAGAR POR LOS DIAS QUE SE REALIZO EL SERVICIO
	SET @Cantidad_Dias = (DATEDIFF(DAY,@F_Inicio,@F_Final))--SE CALCULA LA CANTIDAD DE DIAS QUE DURA EL SERVICIO
	IF (@Cantidad_Dias <>0)--SE VERIFICA QUE EL SERVICIO DURE MAS DE 1 DIA, SI ES 0 SOLO DURA 1 DIA Y SE ASIGNA AL TOTAL EL COSTO DEL SERVICIO
	BEGIN
		SET @Monto_Total = (SELECT (Costo_servicio * @Cantidad_Dias) FROM Tipo_servicios WHERE Cod_tipo_servicio=@Codigo_Tipo_servicio)
	END
	ELSE
	BEGIN--SE ASIGNA EL COSTO DIRECTO DEL TIPO DE SERVICIO POR SER SOLO 1 DIA
		SET @Monto_Total = (SELECT Costo_servicio FROM Tipo_servicios WHERE Cod_tipo_servicio=@Codigo_Tipo_servicio)
	END
	RETURN @Monto_Total	--SE RETORNA EL MONTO TOTAL CALCULADO
END
GO


--FUNCION PARA VALIDAR QUE EXISTA EL CONDUCTOR, TIPO DE SERVICIO, VEHICULO Y EL CLIENTE
CREATE FUNCTION FUNC_VALIDACION_REGISTRO_SERVICIO(
@Codigo_Tipo_servicio int, 
@Cedula_Conductor varchar(15),
@Cedula_Cliente varchar(15),
@Placa_Vehiculo varchar(10)
)
RETURNS INT	--SE DEVUELVE UN NUMERO QUE IDENTIFICA QUE VALOR NO ESTA EN LAS TABLAS
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Tipo_servicios WHERE Cod_tipo_servicio =@Codigo_Tipo_servicio)
		RETURN 1
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT * FROM Conductor WHERE Cedula=@Cedula_Conductor)
			RETURN 2
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT *FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
				RETURN 3
			ELSE
			BEGIN
				IF NOT EXISTS(SELECT * FROM Vehiculo WHERE Placa = @Placa_Vehiculo)
					RETURN 4
			END
		END
	END
	RETURN 0	--SE RETORNA 0 SI NO SE CUMPLE NINGUNA CONDICION, LO QUE SIGNIFICA QUE TODO ESTA CORRECTO
END
GO


--MOSTRAR TODOS LOS SERVICIOS
CREATE PROC PROC_LISTAR_TODOS_SERVICIOS
AS
BEGIN
	SELECT Codigo,[Tipo de servicio],Descripcion,Cliente,Conductor,[Cedula de Conductor],[Placa de vehiculo],[Tipo de vehiculo],[Color de Vehiculo],[Fecha de inicio],
	[Fecha de finalizacion],DATEDIFF(DAY,[Fecha de inicio],[Fecha de finalizacion]) AS 'Duracion',[Costo total]
	FROM V_GENERALES_DE_SERVICIO
END
GO

--BUSCAR POR CODIGO DE SERVICIO
CREATE PROC PROC_BUSCAR_CODIGO_SERVICIO(
	@Codigo_Servicio INT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM Servicio WHERE Cod_Servicio=@Codigo_Servicio)
	BEGIN
		SELECT Codigo,[Tipo de servicio],Descripcion,Cliente,Conductor,[Cedula de Conductor],[Placa de vehiculo],[Tipo de vehiculo],[Color de Vehiculo],[Fecha de inicio],
		[Fecha de finalizacion],DATEDIFF(DAY,[Fecha de inicio],[Fecha de finalizacion]) AS 'Duracion',[Costo total]
		FROM V_GENERALES_DE_SERVICIO
	END
	ELSE
		SET @MsgError ='SERVICIO NO ENCONTRADO'
END
GO

--FILTRO
CREATE PROC PROC_FILTRO_SERVICIO(
	@Cedula_Cliente VARCHAR(15) = NULL,
	@Cedula_Conductor VARCHAR(15) = NULL,
	@Placa_Vehiculo VARCHAR(10) = NULL,
	@Tipo_Servicio VARCHAR(40) = NULL,
	@Tipo_vehiculo VARCHAR(15) = NULL,
	@Costo_inicial MONEY = NULL,
	@Costo_final MONEY = NULL,
	@Fecha_inicial DATE = NULL,
	@Fecha_final DATE = NULL,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF(@Fecha_inicial<=@Fecha_final) OR (@Fecha_inicial IS NULL AND @Fecha_final IS NULL)
	BEGIN
		IF (@Costo_inicial<=@Costo_final) OR (@Costo_inicial IS NULL AND @Costo_final IS NULL)
		BEGIN
			SELECT * FROM V_GENERALES_DE_SERVICIO
			WHERE ([Cedula de Cliente]=@Cedula_Cliente OR @Cedula_Cliente IS NULL)
				AND([Cedula de Conductor] = @Cedula_Conductor OR @Cedula_Conductor IS NULL)
				AND([Placa de vehiculo] = @Placa_Vehiculo OR @Placa_Vehiculo IS NULL)
				AND([Tipo de servicio]=@Tipo_Servicio OR @Tipo_Servicio IS NULL)
				AND([Tipo de vehiculo] = @Tipo_vehiculo OR @Tipo_vehiculo IS NULL)
				AND((([Fecha de inicio] BETWEEN @Fecha_inicial AND @Fecha_final)AND([Fecha de finalizacion] BETWEEN @Fecha_inicial AND @Fecha_final)) OR (@Fecha_inicial IS NULL AND @Fecha_final IS NULL))
				AND(([Costo total] BETWEEN @Costo_inicial AND @Costo_final) OR (@Costo_inicial IS NULL AND @Costo_final IS NULL))
		END
		ELSE
			SET @MsgError='VERIFIQUE QUE EL RANGO INICIAL DE COSTOS SEA MENOR AL RANGO FINAL'	
	END
	ELSE
		SET @MsgError='INTERVALO DE FECHA NO VALIDO ¡VERIFIQUE LOS VALORES!'
END
GO
