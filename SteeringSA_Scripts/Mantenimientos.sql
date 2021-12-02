--Mantenimientos

--PROCEDIMIENTO PARA REGISTRAR MANTENIMIENTO
ALTER PROC PROC_REGISTRAR_MANTENIMIENTO(
	@Placa_Vehiculo VARCHAR(10),
	@Cod_reporte VARCHAR(10),
	@Costo MONEY,
	@Fecha DATE,
	@Descripcion varchar(1500),
	@Estado VARCHAR(15),
	@MsgSuccess VARCHAR(50) ='' OUTPUT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN--SI EL MANTENIMIENTO NO CORRESPONDE A NINGUN REPORTE (ES MANTENIMIENTO PREVENTIVO) EL CODIGO DE REPORTE DEBE SER "S/R" ENVIADO DESDE LA APP
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa_Vehiculo)--Verifica que exista el vehiculo
	BEGIN
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa_Vehiculo AND (@Fecha BETWEEN Fecha_inicio AND Fecha_finalizacion)) OR (@Estado='Realizado')---verifica que el vehiculo no este en servicio para la fecha del mantenimiento si es una receba de mantenimiento, si se permite si es un mantenimiento de emergencia en una fecha de servicio
		BEGIN
			IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_reporte AND Placa_Vehiculo=@Placa_Vehiculo) OR (@Cod_reporte='S/R')--Verifica que el codigo de reporte corresponda la vehiculo seleccionado o que sea un mantenimiento preventivo
			BEGIN
				IF (Format(@Fecha,'yyyy-MM-dd')>=Format((SELECT Fecha FROM Reporte WHERE Cod_reporte=@Cod_reporte) ,'yyyy-MM-dd')) OR (@Cod_reporte='S/R')--Se verifica que la fecha del mantenimiento no sea menor a la del reporte que atiende a menos que sea sin reporte
				BEGIN
					BEGIN TRY
						INSERT INTO Mantenimiento (Placa_Vehiculo,Cod_reporte,Costo,Fecha,Descripcion,Estado)
						VALUES(@Placa_Vehiculo,@Cod_reporte,@Costo,@Fecha,@Descripcion,@Estado)
						EXEC PROC_ACTUALIZAR_ESTADO_REPORTES-- SE ACTUALIZA EL ESTADO DEL REPORTE SELECCIONADO PARA EL MANTENIMIENTO
						EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo mantenimiento'
						SET @MsgSuccess ='MANTENIMIENTO REGISTRADO EXITOSAMENTE'
						COMMIT
					END TRY
					BEGIN CATCH
						SET @MsgError= 'ERROR AL REGISTRAR EL MANTENIMIENTO'
						ROLLBACK
					END CATCH
				END
				ELSE
				BEGIN
					SET @MsgError= 'NO SE PUEDE REGISTRAR UN MANTENIMIENTO PARA UNA FECHA ANTERIOR AL REPORTE QUE ATIENDE'
					ROLLBACK
				END
			END
			ELSE
			BEGIN
				SET @MsgError= 'EL REPORTE SELECCIONADO PARA MANTENIMIENTO NO CORRESPONDE A UN REPORTE ASIGNADO AL VEHICULO SELECCIONADO'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='NO SE PUEDE RESERVAR UN MANTENIMIENTO PARA FECHAS EN QUE EL VEHICULO ESTE DE SERVICIO'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='NO EXISTE VEHICULO EN LA BASE DE DATOS REGISTRADO CON LA PLACA SELECCIONADA'
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ELIMINAR MANTENIMIENTO
ALTER PROC PROC_ELIMINAR_MANTENIMIENTO(
	@Cod_Mantenimiento INT,
	@MsgSuccess VARCHAR(50) ='' OUTPUT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento)
	BEGIN
		BEGIN TRY
			DELETE FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un mantenimiento'
			SET @MsgSuccess='SE ELIMINO EL MANTENIMIENTO CORRECTAMENTE'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='OCURRIO UN ERROR AL INTENTAR ELIMINAR EL MANTENIMIENTO SELECCIONADO'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='EL MANTENIMIENTO SELECCIONADO PARA ELIMINAR NO ESTA REGISTRADO EN LA BASE DE DATOS'
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DEL MANTENIMIENTO
ALTER PROC PROC_ACTUALIZAR_MANTENIMIENTO(
	@Cod_Mantenimiento INT,
	@Placa_Vehiculo VARCHAR(10),
	@Cod_reporte VARCHAR(10),
	@Costo MONEY,
	@Fecha DATE,
	@Descripcion varchar(1500),
	@Estado VARCHAR(15),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento)--SE VALIDA QUE EL MANTENIMIENTO A ACTUALIZAR EXISTA
	BEGIN
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa_Vehiculo AND (@Fecha BETWEEN Fecha_inicio AND Fecha_finalizacion)) OR (@Estado='Realizado') --SE VALIDA QUE EL VEHICULO NO ESTE EN SERVICIO PARA LA FECHA DEL MANTENIMIENTO A MENOS QUE SEA UN MANTENIMIENTO REALIZADO AL MOMENTO
		BEGIN
			IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_reporte AND Placa_Vehiculo=@Placa_Vehiculo) OR (@Cod_reporte='S/R')--SE VALIDA QUE EL REPORTE SELECCIONADO CORRESPONDA AL VEHICULO SELECCIONADO
			BEGIN
				IF  ((SELECT Fecha FROM Reporte WHERE Cod_reporte=@Cod_reporte)<=@Fecha ) OR (@Cod_reporte='S/R')--SE VALIDA QUE LA NUEVA FECHA DE MANTENIMIENTO NO SEA MENOR A LA DEL REPORTE
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mantenimiento WHERE Cod_reporte=@Cod_reporte) OR EXISTS(SELECT * FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento AND Cod_reporte=@Cod_reporte) OR (@Cod_reporte='S/R')--SE VALIDA QUE EL NUEVO REPORTE NO ESTE REGISTRADO A SER ATENDIDO POR OTRO MANTENIMIENTO
					BEGIN
						BEGIN TRY
							UPDATE Mantenimiento SET 
							Placa_Vehiculo=@Placa_Vehiculo,
							Cod_reporte =@Cod_reporte,
							Costo=@Costo,
							Fecha=@Fecha,
							Descripcion=@Descripcion,
							Estado=@Estado
							WHERE Cod_Mantenimiento=@Cod_Mantenimiento
							EXEC PROC_ACTUALIZAR_ESTADO_REPORTES --SE ACTUALIZA EL ESTADO DEL REPORTE SELECCIONADO PARA EL MANTENIMIENTO Y EL QUE FUE REEMPLAZADO
							EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un mantenimiento'
							SET @MsgSuccess='DATOS DEL MANTENIMIENTO ACTUALIZADOS CORRECTAMENTE'
							COMMIT
						END TRY
						BEGIN CATCH
							SET @MsgError= 'ERROR AL INTENTAR ACTUALIZAR LOS DATOS DEL MANTENIMIENTO'
							ROLLBACK
						END CATCH
					END
					ELSE
					BEGIN
						SET @MsgError='NO SE PUEDE ASIGNAR EL REPORTE SELECCIONADO PORQUE YA ESTA ASIGNADO A OTRO MANTENIMIENTO'
						ROLLBACK
					END
				END
				ELSE
				BEGIN
					SET @MsgError= 'LA NUEVA FECHA DE MANTENIMIENTO NO DEBE SER MENOR A LA FECHA DEL REPORTE'
					ROLLBACK
				END
			END
			ELSE
			BEGIN
				SET @MsgError= 'EL REPORTE SELECCIONADO PARA MANTENIMIENTO NO CORRESPONDE A UN REPORTE ASIGNADO AL VEHICULO SELECCIONADO'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='NO SE PUEDE MODIFICAR LA FECHA PARA RECERVAR EL MANTENIMIENTO EN UNA FECHA DE SERVICIO DEL VEHICULO'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='EL MANTENIMIENTO SELECCIONADO NO ESTA REGISTRADO EN LA BASE DE DATOS'
		ROLLBACK
	END
END
GO

--MOSTRAR TODOS LOS MANTENIMIENTOS REGISTRADOS
ALTER PROC PROC_LISTAR_TODOS_MANTENIMIENTOS
AS
BEGIN
	SELECT * FROM V_GENERALES_DE_MANTENIMIENTO
END
GO

--BUSCAR MANTENIMIENTO POR CODIGO
CREATE PROC PROC_BUSCAR_CODIGO_MANTENIMIENTO(
	@Cod_Mantenimiento INT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT * FROM V_GENERALES_DE_MANTENIMIENTO WHERE [Codigo de mantenimiento]=@Cod_Mantenimiento)
	BEGIN
		SELECT * FROM V_GENERALES_DE_MANTENIMIENTO
		WHERE [Codigo de mantenimiento]=@Cod_Mantenimiento
	END
	ELSE
		SET @MsgError='MANTENIMIENTO NO ENCONTRADO'
END
GO

--FILTRO
ALTER PROC PROC_FILTRO_MANTENIMIENTO(
	@Costo_inicial MONEY = NULL,
	@Costo_final MONEY = NULL,
	@Fecha_inicial DATE = NULL,
	@Fecha_final DATE = NULL,
	@Estado VARCHAR(15) = NULL,
	@Placa_vehiculo VARCHAR(10) = NULL,
	@Tipo_vehiculo VARCHAR(15) = NULL,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF(@Fecha_inicial<=@Fecha_final) OR (@Fecha_inicial IS NULL AND @Fecha_final IS NULL)
	BEGIN
		IF (@Costo_inicial<=@Costo_final) OR (@Costo_inicial IS NULL AND @Costo_final IS NULL)
		BEGIN
			SELECT * FROM V_GENERALES_DE_MANTENIMIENTO
			WHERE (([Costo total] BETWEEN @Costo_inicial AND @Costo_final) OR (@Costo_inicial IS NULL AND @Costo_final IS NULL))
				AND(([Fecha de realizacion] BETWEEN @Fecha_inicial AND @Fecha_final) OR (@Fecha_inicial IS NULL AND @Fecha_final IS NULL))
				AND([Estado Actual]=@Estado OR @Estado IS NULL)
				AND([Placa de vehiculo]=@Placa_vehiculo OR @Placa_vehiculo IS NULL)
				AND([Tipo de vehiculo]=@Tipo_vehiculo OR @Tipo_vehiculo IS NULL)
		END
		ELSE
			SET @MsgError='VERIFIQUE QUE EL RANGO INICIAL DE COSTOS SEA MENOR AL RANGO FINAL'	
	END
	ELSE
		SET @MsgError='INTERVALO DE FECHA NO VALIDO ¡VERIFIQUE LOS VALORES!'
END
GO



