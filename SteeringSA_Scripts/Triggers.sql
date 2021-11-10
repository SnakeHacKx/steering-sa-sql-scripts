--TRIGGERS DE LA BASE DE DATOS


/*CUANDO SE EJECUTA LA ELIMINACION DE UN CONDUCTOR SE HACE ESTO EN SU LUGAR
PARA ELIMINAR ANTES LOS SERVICIOS EN LOS QUE PARTICIPO EL CONDUCTOR*/
CREATE TRIGGER TR_ELIMINAR_SERVICIOS_CONDUCTOR
ON Conductor	--EL TRIGER ESTA VERIFICANDO LA TABLA CONDUCTOR PARA ELIMINACIONES
INSTEAD OF DELETE
AS
BEGIN
	BEGIN TRAN
		BEGIN TRY
			DECLARE @Cedula_Conductor VARCHAR(15)
			SELECT @Cedula_Conductor = Conductor.Cedula FROM deleted Conductor--se extrae la cedula del conductor a eliminar
			DELETE FROM Servicio WHERE Cedula_Conductor = @Cedula_Conductor--se eliminan todos los servicios donde esta relacionado
			DELETE C FROM Conductor C INNER JOIN deleted D ON D.Cedula=C.Cedula--se elimina el conductor de la tabla conductor
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('ERROR AL INTENTAR ELIMINAR LOS SERVICIOS ASOCIADOS AL CONDUCTOR SELECCIONADO',16,1)
			ROLLBACK
		END CATCH
END
GO

--TRIGGER PARA MODIFICAR EL ESTADO DE UN VEHICULO SI SE ELIMINA EL SERVICIO MIENTRAS ESTA EN CURSO
CREATE TRIGGER TR_ELIMINAR_SERVICIO_ACT_ESTADO
ON Servicio
AFTER DELETE
AS
BEGIN
	BEGIN TRAN
	DECLARE
	@Placa_Vehiculo VARCHAR(10),
	@Codigo_servicio INT
	BEGIN TRY
		SELECT @Placa_Vehiculo=S.Placa,@Codigo_servicio=S.Cod_Servicio FROM deleted S
		IF EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa_Vehiculo)
		BEGIN
			IF((SELECT Estado FROM Vehiculo WHERE Placa=@Placa_Vehiculo)<>'DISPONIBLE')--SI EL VEHICULO YA TIENE EL ESTADO DISPONIBLE NO ES NECESARIO MODIFICARLO
				BEGIN
				UPDATE Vehiculo SET Estado='DISPONIBLE' WHERE Placa=@Placa_Vehiculo--SE ACTUALIZA EL ESTADO DEL VEHICULO QUE ESTABA ASIGNADO
				END
		END
		COMMIT
	END TRY
	BEGIN CATCH
		RAISERROR('ERROR EN LA OPERACION DE ELIMINACION DEL SERVICIO',16,1)
		ROLLBACK
	END CATCH
END
GO

--TRIGGER PARA ELIMINAR LOS SERVICIOS ASOCIADOS A UN VEHICULO CUANDO SE ELIMINA EL VEHICULO
ALTER TRIGGER TR_ELIMINAR_VEHICULO --MODIFICAR ESTE PARA QUE ELIMINE TAMBIEN REPORTES DEL VEHICULO
ON Vehiculo
INSTEAD OF DELETE
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE @Placa_Vehiculo VARCHAR(10)
		SELECT @Placa_Vehiculo =Vehiculo.Placa FROM deleted Vehiculo --SE EXTRAE LA PLACA DEL VEHICULO A ELIMINAR
		DELETE FROM Servicio WHERE Placa=@Placa_Vehiculo	--SE ELIMINAN TODOS LOS SERVICIOS ASOCIADOS AL VEHICULO A ELIMINAR
		DELETE FROM Reporte WHERE Placa_Vehiculo =@Placa_Vehiculo --SE ELIMINAN LOS REPORTES ASOCIADOS AL VEHICULO
		DELETE FROM Mantenimiento WHERE Placa_Vehiculo=@Placa_Vehiculo --SE ELIMINAN LOS MANTENIMIENTOS ASOCIADOS AL VEHICULO EN CASO DE QUE TENGA MANTENIMIENTOS PREVENTIVOS
		DELETE V FROM Vehiculo V INNER JOIN deleted D ON D.Placa=V.Placa
		WHERE V.Placa=@Placa_Vehiculo
		COMMIT
	END TRY
	BEGIN CATCH
		PRINT('ERROR AL INTENTAR ELIMINAR LOS SERVICIOS ASOCIADOS A ESTE VEHICULO')
		ROLLBACK
	END CATCH
END
GO

--TRIGGER PARA REALIZAR LA OPERACION DE ELIMINAR TIPO DE SERVICIO Y QUE SE ELIMINEN LOS SERVICIOS QUE TENGAN ESE TIPO ASIGNADO
CREATE TRIGGER TR_ELIMINAR_SERVICIO_POR_TIPO
ON Tipo_servicios
INSTEAD OF DELETE
AS
BEGIN
BEGIN TRAN 
	BEGIN TRY
		DECLARE @Cod_Tipo_Servicio INT
		SELECT @Cod_Tipo_Servicio=D.Cod_tipo_servicio FROM deleted D	--se extrae el codigo de servicio que se quiere eliminar
		DELETE FROM Servicio WHERE Cod_tipo_servicio=@Cod_Tipo_Servicio	--se eliminan todos los servicios asociados a ese tipo
		DELETE T FROM Tipo_servicios T INNER JOIN deleted D ON D.Cod_tipo_servicio=T.Cod_tipo_servicio	--se elimina el tipo de servicio de la tabla 
		WHERE T.Cod_tipo_servicio=@Cod_Tipo_Servicio
		COMMIT
	END TRY
	BEGIN CATCH
		PRINT'ERROR AL INTENTAR ELIMINAR LOS SERVICIOS ASOCIADOS A ESTE TIPO DE SERVICIO'
		ROLLBACK
	END CATCH
END
GO

--TRIGER PARA ELIMINAR LOS SERVICIOS ASOCIADOS A UN CLIENTE QUE SE ELIMINA
CREATE TRIGGER TR_ELIMINAR_SERVICIO_CLIENTE
ON TB_Cliente
INSTEAD OF DELETE
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
		DECLARE
			@Cedula_Cliente VARCHAR(15)
		SELECT @Cedula_Cliente=D.Cedula_Cliente FROM deleted D
		DELETE FROM Servicio WHERE Cedula_Cliente =@Cedula_Cliente
		DELETE C FROM TB_Cliente C INNER JOIN deleted D ON C.Cedula_Cliente=D.Cedula_Cliente
		WHERE C.Cedula_Cliente=@Cedula_Cliente
		COMMIT
	END TRY
	BEGIN CATCH
		PRINT 'ERROR AL INTENTAR ELIMINAR SERVICIOS ASOCIADOS AL CLIENTE QUE SE QUIERE ELIMINAR'
		ROLLBACK
	END CATCH
END
GO

--TRIGGER PARA ACTUALIZAR EL ESTADO DE UN VEHICULO QUE A SIDO REMOVIDO DE UN SERVICIO POR ACTUALIZACION DE DATOS DE SERVICIO
CREATE TRIGGER TR_ACTUALIZACION_DE_SERVICIO
ON Servicio
AFTER UPDATE
AS
BEGIN
	DECLARE @Placa_Vehiculo VARCHAR(10)
	DECLARE C_PLACA_VEHICULOS CURSOR LOCAL SCROLL
	FOR SELECT Placa FROM Vehiculo
	OPEN C_PLACA_VEHICULOS
	FETCH C_PLACA_VEHICULOS INTO @Placa_Vehiculo
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		IF NOT EXISTS(SELECT * FROM V_ESTADO_VEHICULO_FECHA_ACTUAL WHERE Placa=@Placa_Vehiculo)
			UPDATE Vehiculo SET Estado='DISPONIBLE' WHERE Placa =@Placa_Vehiculo
		FETCH C_PLACA_VEHICULOS INTO @Placa_Vehiculo
	END
END
GO

/*ALTER TRIGGER TR_INSERTAR_MANTENIMIENTO
ON Mantenimiento
AFTER INSERT
AS
BEGIN
	BEGIN TRAN
	DECLARE @Cod_reporte VARCHAR(10)
	SELECT @Cod_reporte = I.Cod_reporte FROM inserted I
	IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_reporte)
	BEGIN
		BEGIN TRY
			UPDATE Reporte SET Estado = 'ATENDIDO' WHERE Cod_reporte=@Cod_reporte
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('ERROR AL ACTUALIZAR EL ESTADO DEL REPORTE ATENDIDO',16,1)
			ROLLBACK
		END CATCH
	END
	ELSE
		COMMIT
END
GO*/


ALTER TRIGGER TR_ELIMINAR_MANTENIMIENTO--AL ELIMINAR EL MANTENIMIENTO SE ACTUALIZA EL ESTADO DEL REPORTE QUE SE ATIENDE SI NO ES PREVENTIVO
ON Mantenimiento
AFTER DELETE
AS
BEGIN
	BEGIN TRAN
	DECLARE @Cod_reporte VARCHAR(10)
	SELECT @Cod_reporte = D.Cod_reporte FROM deleted D
	IF EXISTS(SELECT * FROM Reporte WHERE Cod_reporte=@Cod_reporte)  --VERIFICA QUE EL CODIGO DE REPORTE EXISTA EN LA TABLA, SI NO EXISTE ES "S/R" QUE CORRESPONDE A UN MANTENIMIENTO PREVENTIVO
	BEGIN
		BEGIN TRY
			UPDATE Reporte SET Estado ='NO ATENDIDO' WHERE Cod_reporte=@Cod_reporte   --ACTUALIZA EL ESTADO DEL REPORTE QUE ATENDIA ESTE MANTENIMIENTO
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('FALLO LA ACTUALIZACION DEL ESTADO DEL REPORTE QUE ERA ATENDIDO POR EL MANTENIMIENTO BORRADO',16,1)
			ROLLBACK
		END CATCH
	END
	ELSE
		COMMIT
END
GO
--TRIGGER PARA ELIMINAR EL MANTENIMIENTO QUE ESTE ASOCIADO A UN REPORTE 
CREATE TRIGGER ELIMINAR_REPORTE
ON Reporte
AFTER DELETE
AS
BEGIN
	BEGIN TRAN
	DECLARE @Cod_Mantenimiento INT,
	@Cod_Reporte VARCHAR(10)
	SELECT @Cod_Reporte = D.Cod_Reporte FROM deleted D
	IF EXISTS(SELECT * FROM Mantenimiento WHERE Cod_reporte=@Cod_Reporte)
	BEGIN
		BEGIN TRY
			DELETE FROM Mantenimiento WHERE Cod_reporte=@Cod_Reporte
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('HA OCURRIDO UN ERROR AL INTENTAR ELIMINAR EL MANTENIMIENTO ASOCIADO AL REPORTE ELIMINADO',16,1)
			ROLLBACK
		END CATCH
	END
	ELSE
		COMMIT
END