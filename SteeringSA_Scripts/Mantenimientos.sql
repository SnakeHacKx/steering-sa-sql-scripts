--Mantenimientos

--PROCEDIMIENTO PARA REGISTRAR MANTENIMIENTO
ALTER PROC PROC_REGISTRAR_MANTENIMIENTO(
	@Placa_Vehiculo VARCHAR(10),
	@Cod_reporte VARCHAR(10),
	@Costo MONEY,
	@Fecha DATE,
	@Descripcion varchar(225),
	@Estado VARCHAR(15),
	@MsgSuccess VARCHAR(50) OUTPUT,
	@MsgError VARCHAR(50) OUTPUT
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
				IF (@Fecha>=GETDATE())--verifica que el mantenimiento no se registre a un dia anterior a la fecha actual
				BEGIN
					BEGIN TRY
						INSERT INTO Mantenimiento (Placa_Vehiculo,Cod_reporte,Costo,Fecha,Descripcion,Estado)
						VALUES(@Placa_Vehiculo,@Cod_reporte,@Costo,@Fecha,@Descripcion,@Estado)
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
					SET @MsgError= 'NO SE PUEDE REGISTRAR UN MANTENIMIENTO PARA UNA FECHA ANTERIOR A LA ACTUAL'
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
CREATE PROC PROC_ELIMINAR_MANTENIMIENTO(
	@Cod_Mantenimiento INT,
	@MsgSuccess VARCHAR(50) OUTPUT,
	@MsgError VARCHAR(50) OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	IF EXISTS(SELECT * FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento)
	BEGIN
		BEGIN TRY
			DELETE FROM Mantenimiento WHERE Cod_Mantenimiento=@Cod_Mantenimiento
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