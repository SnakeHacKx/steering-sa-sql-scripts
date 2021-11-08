--Scripts de VEHICULOS-------
--AGREGAR UN NUEVO VEHICULO
CREATE PROC PROC_REGISTRAR_VEHICULO(
	@Placa varchar(10),
	@Motor varchar(10),
	@Tipo varchar(15),
	@pasajero smallint,
	@Tipo_de_combustible varchar(10),
	@Color varchar(10)
)
AS
	IF NOT EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa)
	BEGIN
		BEGIN TRAN
		BEGIN TRY--INTENTAR INGRESAR LOS DATOS A LA TABLA 
			INSERT INTO Vehiculo (Placa,Motor,Tipo,Estado,pasajero,Tipo_de_combustible,Color)
			VALUES(@Placa,@Motor,@Tipo,'DISPONIBLE',@pasajero,@Tipo_de_combustible,@Color)
			COMMIT TRAN--CONFIRMACION DE LA TRANSACCION
		END TRY
		BEGIN CATCH
			RAISERROR('OCURRIO UN ERROR INESPERADO AL INTENTAR REGISTRAR EL VEHICULO, INTENTE NUEVAMENTE', 15,1)--MENSAJE EN CASO DE ERROR DE REGISTRO
			ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
		END CATCH
	END
	ELSE
	BEGIN
		RAISERROR('YA EXISTE UN VEHICULO REGISTRADO CON ESTOS DATOS',12,1)--MENSAJE EN CASO DE QUE YA EXISTA UN VEHICULO REGISTRADO CON ESOS DATOS
	END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DE UN VEHICULO
ALTER PROC PROC_ACTUALIZAR_DATOS_VEHICULO(
	@Placa varchar(10),
	@Motor varchar(10),
	@Tipo varchar(15),
	@pasajero smallint,
	@Tipo_de_combustible varchar(10),
	@Color varchar(10)
)
AS
BEGIN
BEGIN TRAN
	IF EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa)
		BEGIN
			BEGIN TRY
				UPDATE Vehiculo SET
				Motor=@Motor,
				Tipo=@Tipo,
				pasajero=@pasajero,
				Tipo_de_combustible=@Tipo_de_combustible,
				Color=@Color
				WHERE Placa=@Placa;
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				RAISERROR('ERROR EN LA ACTUALIZACION DE LOS DATOS DEL VEHICULO SELECCIONADO',12,1)
				ROLLBACK
			END CATCH
		END
	ELSE
	BEGIN
		RAISERROR('NO EXISTE UN VEHICULO REGISTRADO CON LA PLACA SELECCIONADA',16,1)
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ACTUALIZAR EL ESTADO DE LOS VEHICULOS SEGUN LA FECHA Y LOS SERVICIOS
ALTER PROC PROC_ACTUALIZAR_ESTADO_VEHICULOS
AS--ESTA PRECEDIMIENTO TIENE UN CURSOS QUE ACTUALIZARA EL ESTADO DE LOS VEHICULOS SEGUN LA FECHA ACTUAL Y LA FECHA DE LOS SERVICIOS ASIGNADOS
BEGIN
BEGIN TRAN
	DECLARE @Fecha_Actual DATE,
			@Fecha_Inicio DATE,
			@Fecha_Final DATE,
			@Placa_Vehiculo VARCHAR(10)
	DECLARE @Modificados Table(Placa varchar(10))--SE CREA UNA VARIABLE DE TIPO TABLA PARA ALMACENAR LAS PLACAS DE LOS VEHICULOS A LOS QUE SE LES MODIFICO EL ESTADO Y EVITAR QUE SE SOBRE ESCRIBA EN EL CURSOR
	SET @Fecha_Actual = GETDATE()
	DECLARE C_ACTUALIZAR_ESTADO_VEHICULO CURSOR LOCAL SCROLL
		FOR SELECT Placa,Fecha_inicio,Fecha_finalizacion
		FROM V_ESTADO_VEHICULO_FECHA_ACTUAL--VISTA QUE CONTIENE EL ESTADO, LAS FECHAS DE LOS SERVICIOS Y LA PLACA DE VEHICULOS
	OPEN C_ACTUALIZAR_ESTADO_VEHICULO
	FETCH C_ACTUALIZAR_ESTADO_VEHICULO INTO @Placa_Vehiculo,@Fecha_Inicio,@Fecha_Final
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		BEGIN TRY
			IF (@Fecha_Inicio<=@Fecha_Actual) AND (@Fecha_Final>=@Fecha_Actual)
			BEGIN
				UPDATE V_ESTADO_VEHICULO_FECHA_ACTUAL SET Estado='NO DISPONIBLE' WHERE Placa =@Placa_Vehiculo
				INSERT INTO @Modificados (placa) VALUES (@Placa_Vehiculo)
			END
			ELSE
			BEGIN
				IF NOT EXISTS(SELECT * FROM @Modificados WHERE Placa =@Placa_Vehiculo)--SI NO SE HA MODIFICADO SU ESTADO A NO DISPONIBLE ENTONCES SE PONE EN DISPONIBLE, PORQUE QUIERE DECIR QUE NO TIENE SERVICIOS EN ESTE MOMENTO
					UPDATE V_ESTADO_VEHICULO_FECHA_ACTUAL SET Estado='DISPONIBLE' WHERE Placa =@Placa_Vehiculo--VEHICULOS QUE A LA FECHA NO SE ENCUENTRAN EN SERVICIO SE LES ACTUALIZA EL ESTADO A DISPONIBLE
			END
		END TRY
		BEGIN CATCH
				RAISERROR('ERROR AL INTENTAR ACTUALIZAR EL ESTADO DEL VEHICULO',16,1)
				ROLLBACK
		END CATCH
		FETCH C_ACTUALIZAR_ESTADO_VEHICULO INTO @Placa_Vehiculo,@Fecha_Inicio,@Fecha_Final
	END
	COMMIT--SE CONFIRMA LA TRANSACCION AL MODIFICAR TODOS LOS DATOS 
	CLOSE C_ACTUALIZAR_ESTADO_VEHICULO
	DEALLOCATE C_ACTUALIZAR_ESTADO_VEHICULO

END
GO
--PROCIDIMIENTO PARA ELIMINAR VEHICULOS
ALTER PROC PROC_ELIMINAR_VEHICULO(@Placa_Vehiculo VARCHAR(10))
AS
BEGIN
BEGIN TRAN
	IF EXISTS (SELECT *FROM Vehiculo WHERE Placa=@Placa_Vehiculo)
	BEGIN
		BEGIN TRY
			DELETE FROM Vehiculo WHERE Placa=@Placa_Vehiculo
			COMMIT
		END TRY
		BEGIN CATCH
			PRINT('ERROR AL INTENTAR ELIMINAR EL VEHICULO SELECCIONADO')
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		PRINT('LA PLACA INTRODUCIDA NO CORRESPONDE A NINGUN VEHICULO DE LA FLOTA')
		ROLLBACK
	END
END
GO

