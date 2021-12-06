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
	--Se verifica que la fecha de inicio sea mayor o igual a la final y que sea mayor o igual a la actual
	IF (@F_Inicio<=@F_Final) AND (@F_Inicio>=Format(GETDATE(),'yyyy-MM-dd'))
	BEGIN
		--SE VERIFICA QUE EL CONDUCTOR NO TENGA REGISTRADO UN SERVICIO ENTRE LAS FECHAS DEL NUEVO SERVICIO A REALIZAR
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor and (@F_Inicio between Fecha_inicio and Fecha_finalizacion) and (@F_Final between Fecha_inicio and Fecha_finalizacion))
		BEGIN--SE VERIFICA QUE EL VEHICULO NO TENGA REGISTRADO UN SERVICIO ENTRE LAS FECHAS PARA VER SI ESTA DISPONIBLE
			IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa_Vehiculo and (@F_Inicio between Fecha_inicio and Fecha_finalizacion) and (@F_Final between Fecha_inicio and Fecha_finalizacion))
			BEGIN	--Se verifica que el vehiculo no tenga un mantenimiento programado para la fecha del nuevo servicio
				IF NOT EXISTS(SELECT * FROM Mantenimiento WHERE Placa_Vehiculo=@Placa_Vehiculo AND (Fecha BETWEEN @F_Inicio AND @F_Final))
				BEGIN--SE VALIDA QUE LOS PARAMETROS EXISTAN EN SUS CORRESPONDIENTES TABLAS
					SET @Validacion = DBO.FUNC_VALIDACION_REGISTRO_SERVICIO(@Codigo_Tipo_servicio,@Cedula_Conductor,@Cedula_Cliente,@Placa_Vehiculo)
					IF @Validacion= 0
					BEGIN
						SET @Monto_Total = DBO.FUNC_CALCULAR_MONTO_TOTAL_SERVICIO(@F_Inicio,@F_Final,@Codigo_Tipo_servicio) --SE CALCULA EL MONTO TOTAL
						BEGIN
							BEGIN TRY --INICIO DE LA INSERCION EN LA TABLA SERVICIO
								INSERT INTO Servicio(Cod_tipo_servicio,Cedula_Conductor,Placa,Cedula_Cliente,Fecha_inicio,Fecha_finalizacion,Monto_Total_Servicio)
								VALUES(@Codigo_Tipo_servicio,@Cedula_Conductor,@Placa_Vehiculo,@Cedula_Cliente,@F_Inicio,@F_Final,@Monto_Total)
								EXEC PROC_ACTUALIZAR_ESTADO_VEHICULOS
								EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo servicio'
								SET @MsgSuccess='Servicio registrado exitosamente'
								COMMIT TRAN
							END TRY
							BEGIN CATCH
								SET @MsgError='Error al intentar registrar el servicio'
								ROLLBACK
							END CATCH
						END
					END
					ELSE
					BEGIN
						SET @MsgError=        --IMPRIME EL MENSAJE DE ERROR SEGUN LO QUE NO SE ENCUENTRE REGISTRADO
							CASE 
								WHEN @Validacion = 1 THEN 'El tipo de servicio seleccionado no corresponde a ninguno que ofrezca la empresa'
								WHEN @Validacion = 2 THEN 'La cedula seleccionada no corresponde a ningun conductor registrado en la base de datos'
								WHEN @Validacion = 3 THEN 'La cedula del cliente seleccionada no corresponde a ningun cliente registrado en la base de datos'
								WHEN @Validacion = 4 THEN 'El vehiculo seleccionado no se encuentra registrado en la flota'
							END
							ROLLBACK
					END
				END--Fin del if de mantenimiento
				ELSE
				BEGIN
					SET @MsgError='El vehiculo seleccionado estara en mantenimiento para la fecha del servicio'
					ROLLBACK
				END
			END --Fin del if de verificacion de vehiculo
			ELSE
			BEGIN
				SET @MsgError='El vehiculo seleccionado esta ocupado para la fecha del servicio'
				ROLLBACK
			END
		END--fin del if de varificacion del conductor
		ELSE
		BEGIN
			SET @MsgError='El conductor seleccionado esta ocupado para la fecha del servicio'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='Error en los rangos de fecha seleccionados, verifique'
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
	DECLARE @Validacion INT
	IF (@Fecha_inicio<=@Fecha_finalizacion) AND (@Fecha_inicio>=Format(GETDATE(),'yyyy-MM-dd'))
	BEGIN
		IF EXISTS (SELECT * FROM Servicio WHERE Cod_Servicio=@Cod_Servicio)
		BEGIN
			IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa and (@Fecha_inicio between Fecha_inicio and Fecha_finalizacion) and (@Fecha_finalizacion between Fecha_inicio and Fecha_finalizacion)) OR EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa AND Cod_Servicio=@Cod_Servicio)
			BEGIN
				IF NOT EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor and (@Fecha_inicio between Fecha_inicio and Fecha_finalizacion) and (@Fecha_finalizacion between Fecha_inicio and Fecha_finalizacion)) OR EXISTS(SELECT * FROM Servicio WHERE Cedula_Conductor=@Cedula_Conductor AND Cod_Servicio = @Cod_Servicio)
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mantenimiento WHERE Placa_Vehiculo=@Placa AND (Fecha BETWEEN @Fecha_inicio AND @Fecha_finalizacion))
					BEGIN--SE VALIDA QUE LOS PARAMETROS EXISTAN EN SUS CORRESPONDIENTES TABLAS
						SET @Validacion = DBO.FUNC_VALIDACION_REGISTRO_SERVICIO(@Cod_tipo_servicio,@Cedula_Conductor,@Cedula_Cliente,@Placa)
						IF @Validacion= 0
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
								SET @MsgSuccess='Datos del servicio actualizados correctamente'
								COMMIT
							END TRY
							BEGIN CATCH
								SET @MsgError='Error al intentar actualizar los datos del servicio'
								ROLLBACK
							END CATCH
						END
						ELSE
						BEGIN
							SET @MsgError=        --IMPRIME EL MENSAJE DE ERROR SEGUN LO QUE NO SE ENCUENTRE REGISTRADO
								CASE 
									WHEN @Validacion = 1 THEN 'El tipo de servicio seleccionado no corresponde a ninguno que ofrezca la empresa'
									WHEN @Validacion = 2 THEN 'La cedula seleccionada no corresponde a ningun conductor registrado en la base de datos'
									WHEN @Validacion = 3 THEN 'La cedula del cliente seleccionada no corresponde a ningun cliente registrado en la base de datos'
									WHEN @Validacion = 4 THEN 'El vehiculo seleccionado no se encuentra registrado en la flota'
								END
								ROLLBACK
						END
					END--Fin del if de mantenimiento
					ELSE
					BEGIN
						SET @MsgError='El vehiculo seleccionado estara en mantenimiento para la fecha del servicio'
						ROLLBACK
					END
				END
				ELSE
				BEGIN
					SET @MsgError='El conductor asignado no esta disponible para la fecha del servicio'
					ROLLBACK
				END
			END
			ELSE
			BEGIN
				SET @MsgError='El vehiculo asignado no esta disponible para la fecha del servicio'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError= 'El servicio registrado no esta registrado en la base de datos'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='Error en los rangos de fecha seleccionados, verifique'
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
			SET @MsgSuccess='Servicio eliminado exitosamente'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='Error al intentar eliminar el servicio seleccionado'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='El codigo de servicio seleccionado no corresponde a ninguno registrado'
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
ALTER PROC PROC_LISTAR_TODOS_SERVICIOS
AS
BEGIN
	SELECT *FROM V_GENERALES_DE_SERVICIO
END
GO

--BUSCAR POR CODIGO DE SERVICIO
ALTER PROC PROC_BUSCAR_CODIGO_SERVICIO(
	@Codigo_Servicio INT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM Servicio WHERE Cod_Servicio=@Codigo_Servicio)
	BEGIN
		SELECT *FROM V_GENERALES_DE_SERVICIO
		WHERE Codigo = @Codigo_Servicio
	END
	ELSE
		SET @MsgError ='SERVICIO NO ENCONTRADO'
END
GO

--FILTRO
ALTER PROC PROC_FILTRO_SERVICIO(
	@Cedula_Cliente VARCHAR(15) = NULL,
	@Cedula_Conductor VARCHAR(15) = NULL,
	@Placa_Vehiculo VARCHAR(10) = NULL,
	@Tipo_Servicio VARCHAR(40) = NULL,
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