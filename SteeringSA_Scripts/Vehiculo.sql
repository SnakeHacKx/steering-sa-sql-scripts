--Scripts de VEHICULOS-------
--AGREGAR UN NUEVO VEHICULO
ALTER PROC PROC_REGISTRAR_VEHICULO(
	@Placa varchar(10),
	@Modelo_vehiculo varchar(10),
	@Tipo varchar(15),
	@pasajero varchar(2),
	@Tipo_de_combustible varchar(12),
	@Color varchar(10),
	@MsgSuccess VARCHAR(50) = '' OUTPUT,
	@MsgError VARCHAR(50) = '' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa)
	BEGIN
		BEGIN TRY--INTENTAR INGRESAR LOS DATOS A LA TABLA 
			INSERT INTO Vehiculo (Placa,Modelo_vehiculo,Tipo,Estado,pasajero,Tipo_de_combustible,Color)
			VALUES(@Placa,@Modelo_vehiculo,@Tipo,'DISPONIBLE',@pasajero,@Tipo_de_combustible,@Color)
			EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo Vehiculo'
			SET @MsgSuccess='Vehiculo registrado correctamente'
			COMMIT TRAN--CONFIRMACION DE LA TRANSACCION
		END TRY
		BEGIN CATCH
			SET @MsgError='Ocurrió un errror inesperado al intentar registrar el vehículo, inténtelo nuevamente'--MENSAJE EN CASO DE ERROR DE REGISTRO
			ROLLBACK TRAN--CANCELACION DE LA TRANSACCION
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='Ya existe un vehículo registrado con estos datos'--MENSAJE EN CASO DE QUE YA EXISTA UN VEHICULO REGISTRADO CON ESOS DATOS
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA ACTUALIZAR DATOS DE UN VEHICULO
ALTER PROC PROC_ACTUALIZAR_DATOS_VEHICULO(
	@Placa varchar(10),
	@Modelo_vehiculo varchar(10),
	@Tipo varchar(15),
	@pasajero varchar(2),
	@Tipo_de_combustible varchar(12),
	@Color varchar(10),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	IF EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa)
		BEGIN
			BEGIN TRY
				UPDATE Vehiculo SET
				Modelo_vehiculo=@Modelo_vehiculo,
				Tipo=@Tipo,
				pasajero=@pasajero,
				Tipo_de_combustible=@Tipo_de_combustible,
				Color=@Color
				WHERE Placa=@Placa;
				EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un vehiculo'
				SET @MsgSuccess='Datos del vehiculo actualizados correctamente'
				COMMIT TRAN
			END TRY
			BEGIN CATCH
				SET @MsgError='Error en la actualizacion de datos del vehiculo'
				ROLLBACK
			END CATCH
		END
	ELSE
	BEGIN
		SET @MsgError='No existe un vehiculo registrado con la placa seleccionada'
		ROLLBACK
	END
END
GO
--PROCEDIMIENTO PARA ACTUALIZAR EL ESTADO DE LOS VEHICULOS SEGUN LA FECHA Y LOS SERVICIOS
ALTER PROC PROC_ACTUALIZAR_ESTADO_VEHICULOS
AS--ESTA PRECEDIMIENTO TIENE UN CURSOR QUE ACTUALIZARA EL ESTADO DE LOS VEHICULOS SEGUN LA FECHA ACTUAL Y LA FECHA DE LOS SERVICIOS ASIGNADOS
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
			IF (@Fecha_Inicio<=@Fecha_Actual) AND (@Fecha_Final>=@Fecha_Actual)--Si la fecha actual esta entre las fecha de inicio y final del servicio del vehiculo entonces no esta disponible
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
ALTER PROC PROC_ELIMINAR_VEHICULO(@Placa_Vehiculo VARCHAR(10),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50) ='' OUTPUT)
AS
BEGIN
BEGIN TRAN
	IF EXISTS (SELECT *FROM Vehiculo WHERE Placa=@Placa_Vehiculo)
	BEGIN
		BEGIN TRY
			DELETE FROM Vehiculo WHERE Placa=@Placa_Vehiculo
			EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un vehiculo'
			SET @MsgSuccess='Vehiculo eliminado correctamente'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError=('Error al intentar eliminar el vehiculo seleccionado')
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError=('La placa introducida no corresponde a ningun vehiculo de la flota')
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA OBTENER LOS REPORTES DE UN VEHICULO
ALTER PROC PROC_OBTENER_REPORTES_VEHICULO(
	@Placa_Vehiculo VARCHAR(10),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT * FROM Vehiculo WHERE Placa=@Placa_Vehiculo)
	BEGIN
		SELECT * FROM V_GENERALES_DE_REPORTE WHERE [Matrícula del Vehículo] = @Placa_Vehiculo
	END
	ELSE
	BEGIN
		SET @MsgError=('La placa introducida no corresponde a ningun vehiculo de la flota')
	END
END
GO
--PROCEDIMIENTO PARA OBTENER LOS VEHICULOS QUE ESTAN DISPONIBLES A LA FECHA
CREATE PROC PROC_OBTENER_VEHICULOS_DISPONIBLE
AS
BEGIN
	SELECT * FROM V_GENERALES_DE_VEHICULO WHERE Estado = 'DISPONIBLE'
END
GO


--MOSTRAR TODOS
ALTER PROC PROC_LISTAR_TODOS_VEHICULOS
AS
BEGIN
	SELECT * FROM V_GENERALES_DE_VEHICULO
	ORDER BY Matrícula
END
GO

--BUSCAR POR PLACA
ALTER PROC PROC_BUSCAR_VEHICULO_POR_PLACA(
	@Placa varchar(10),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT * FROM V_GENERALES_DE_VEHICULO WHERE [Matrícula]LIKE @Placa+'%')
	BEGIN
		SELECT * FROM V_GENERALES_DE_VEHICULO WHERE [Matrícula] LIKE @Placa+'%'
	END
	ELSE
		SET @MsgError='Vehículo no encontrado'
END
GO

--FILTRO
ALTER PROC PROC_FILTRO_VEHICULO(
	@Modelo_vehiculo varchar(10) =NULL,
	@Tipo varchar(15)=NULL,
	@pasajero_init varchar(2)=NULL, --rango inferior
	@pasajero_top varchar(2)=NULL,	--rango superior
	@Tipo_de_combustible varchar(12)=NULL,
	@Estado_vehiculo varchar(15) =NULL,
	@Color varchar(10)=NULL,
	@MsgError VARCHAR(50) = '' OUTPUT
)
AS
BEGIN 
	IF (@pasajero_init<=@pasajero_top) OR (@pasajero_init IS NULL AND @pasajero_top IS NULL)--solo es necesaria la validacion del que el rango sea correcto porque los otros valores estan pre cargados en combo box
	BEGIN																					--lo que hace que siempre esten correctos
		SELECT *FROM V_GENERALES_DE_VEHICULO --se accede a los datos generales del vehiculo por medio de la vista
		WHERE (([Modelo] LIKE @Modelo_vehiculo+'%') OR @Modelo_vehiculo IS NULL)--Si el parametro fue seleccionado como filtro desde la GUI entonces sera distinto de null y se buscara en la base de datos, si no lo encuentra la condicion entonces sera false
			AND (Tipo=@Tipo OR @Tipo IS NULL)									--en caso de que no haya sido seleccionado el parametro como filtro entonces vendra como Null lo que hace que la condicion sea true pero no busca en la base de datos
			AND((Capacidad BETWEEN @pasajero_init AND @pasajero_top) OR (@pasajero_init IS NULL AND @pasajero_top IS NULL ))
			AND ([Tipo de Combustible] = @Tipo_de_combustible OR @Tipo_de_combustible IS NULL)
			AND (Estado = @Estado_vehiculo OR @Estado_vehiculo IS NULL)
			AND(Color = @Color OR @Color IS NULL)
	END
	ELSE
		SET @MsgError='INTERVALO DE CANTIDAD DE PASAJEROS NO VALIDO ¡VERIFIQUE LOS VALORES!'
END
GO

