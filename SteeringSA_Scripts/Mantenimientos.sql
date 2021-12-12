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
		IF NOT EXISTS(SELECT * FROM Servicio WHERE Placa=@Placa_Vehiculo AND (@Fecha BETWEEN Fecha_inicio AND Fecha_finalizacion)) OR (@Estado='Realizado')---verifica que el vehiculo no este en servicio para la fecha del mantenimiento si es una reserva de mantenimiento, si se permite si es un mantenimiento de emergencia en una fecha de servicio
		BEGIN
			IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_reporte AND Placa_Vehiculo=@Placa_Vehiculo) OR (@Cod_reporte='S/R')--Verifica que el codigo de reporte corresponda la vehiculo seleccionado o que sea un mantenimiento preventivo
			BEGIN
				IF (Format(@Fecha,'yyyy-MM-dd')>=Format((SELECT Fecha FROM Reporte WHERE Cod_reporte=@Cod_reporte) ,'yyyy-MM-dd')) OR (@Cod_reporte='S/R')--Se verifica que la fecha del mantenimiento no sea menor a la del reporte que atiende a menos que sea sin reporte
				BEGIN
					IF NOT EXISTS(SELECT * FROM Mantenimiento WHERE Cod_reporte=@Cod_reporte) OR (@Cod_reporte='S/R')--SE VALIDA QUE EL NUEVO REPORTE NO ESTE REGISTRADO A SER ATENDIDO POR OTRO MANTENIMIENTO
					BEGIN
						BEGIN TRY
							INSERT INTO Mantenimiento (Placa_Vehiculo,Cod_reporte,Costo,Fecha,Descripcion,Estado)
							VALUES(@Placa_Vehiculo,@Cod_reporte,@Costo,@Fecha,@Descripcion,@Estado)
							EXEC PROC_ACTUALIZAR_ESTADO_REPORTES-- SE ACTUALIZA EL ESTADO DEL REPORTE SELECCIONADO PARA EL MANTENIMIENTO
							EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo mantenimiento'
							SET @MsgSuccess ='Mantenimiento registrado exitosamente'
							COMMIT
						END TRY
						BEGIN CATCH
							SET @MsgError= 'Error al registrar el mantenimiento'
							ROLLBACK
						END CATCH
					END
					ELSE
					BEGIN
						SET @MsgError='No se puede asignar el reporte seleccionado porque ya esta registrado para otro mantenimiento'
						PRINT'YA SELECCIONADO'
						ROLLBACK
					END
				END
				ELSE
				BEGIN
					SET @MsgError= 'No se puede registrar un mantenimiento para una fecha anterior a la fecha de registro del reporte que atiende'
					ROLLBACK
				END
			END
			ELSE
			BEGIN
				SET @MsgError= 'El reporte seleccionado no corresponde a un reporte hecho al vehiculo seleccionado para mantenimiento'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='No se puede reservar un mantenimiento para una fecha en que el vehiculo este de servicio'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='El vehiculo seleccionado no esta registrado en la base de datos'
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
			SET @MsgSuccess='Se elimino correctamente el mantenimiento'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='Ocurrio un error al intentar eliminar el mantenimiento'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='El mantenimiento seleccionado para eliminar no esta registrado en la base de datos'
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
							SET @MsgSuccess='Datos del mantenimiento actualizados correctamente'
							COMMIT
						END TRY
						BEGIN CATCH
							SET @MsgError= 'Error al intentar actualizar los datos del mantenimiento'
							ROLLBACK
						END CATCH
					END
					ELSE
					BEGIN
						SET @MsgError='No se puede asignar el reporte seleccionado porque ya esta asignado en otro mantenimiento'
						ROLLBACK
					END
				END
				ELSE
				BEGIN
					SET @MsgError= 'La nueva fecha de mantenimiento no puede ser menor a la fecha de reporte'
					ROLLBACK
				END
			END
			ELSE
			BEGIN
				SET @MsgError= 'El reporte seleccionado para el mantenimiento no corresponde a un reporte realizado al vehiculo'
				ROLLBACK
			END
		END
		ELSE
		BEGIN
			SET @MsgError='No se puede modificar la fecha del mantenimiento para una fecha en que el vehiculo este en servicio'
			ROLLBACK
		END
	END
	ELSE
	BEGIN
		SET @MsgError='El mantenimiento seleccionado no esta registrado en la base de datos'
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
				AND((CONVERT(DATETIME,[Fecha de realizacion],103) BETWEEN @Fecha_inicial AND @Fecha_final) OR (@Fecha_inicial IS NULL AND @Fecha_final IS NULL))
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



