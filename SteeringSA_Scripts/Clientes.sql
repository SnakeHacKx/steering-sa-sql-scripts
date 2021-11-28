--TABLA DE CLIENTES

--PROCEDIMIENTO PARA REGISTRAR CLIENTES
ALTER PROC PROC_REGISTRAR_CLIENTE(
@Cedula_Cliente VARCHAR(15),
@Nombre_Cliente VARCHAR(35),
@Apellido_Cliente VARCHAR(35),
@Fecha_Nacimiento_Cliente DATE,
@Telefono_Cliente VARCHAR(15),
@Direccion_Cliente VARCHAR(65),
@MsgSuccess VARCHAR(50) ='' OUTPUT,
@MsgError VARCHAR(50) ='' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
	BEGIN
		INSERT INTO TB_Cliente(Cedula_Cliente,Nombre_Cliente,Apellido_Cliente,Fecha_Nacimiento_Cliente,Telefono_Cliente,Direccion_CLiente)
		VALUES(@Cedula_Cliente,@Nombre_Cliente,@Apellido_Cliente,@Fecha_Nacimiento_Cliente,@Telefono_Cliente,@Direccion_Cliente)
		EXEC PROC_REGISTRAR_HISTORIAL 'Insertar','Se registro un nuevo cliente'
		SET @MsgSuccess = 'Cliente registrado correctamente.'
		COMMIT
	END
	ELSE
	BEGIN
		SET @MsgError= 'Ya existe un cliente registrado con estos datos'
		ROLLBACK
	END

END
GO

--PROCEDIMIENTO PARA ACTUALIZAR
ALTER PROC PROC_ACTUALIZAR_DATOS_CLIENTE(
@Cedula_Cliente VARCHAR(15),
@Nombre_Cliente VARCHAR(35),
@Apellido_Cliente VARCHAR(35),
@Fecha_Nacimiento_Cliente DATE,
@Telefono_Cliente VARCHAR(15),
@Direccion_Cliente VARCHAR(65),
@MsgSuccess VARCHAR(50)='' OUTPUT,
@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	IF EXISTS(SELECT *FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
	BEGIN
		BEGIN TRY
			UPDATE TB_Cliente SET
			Nombre_Cliente=@Nombre_Cliente,
			Apellido_Cliente=@Apellido_Cliente,
			Fecha_Nacimiento_Cliente=@Fecha_Nacimiento_Cliente,
			Telefono_Cliente=@Telefono_Cliente,
			Direccion_CLiente=@Direccion_Cliente
			WHERE Cedula_Cliente=@Cedula_Cliente
			EXEC PROC_REGISTRAR_HISTORIAL 'Actualizar','Se actualizaron los datos de un cliente'
			SET @MsgSuccess = 'DATOS DEL CLIENTE ACTUALIZADOS EXITOSAMENTE'
			COMMIT
		END TRY
		BEGIN CATCH
			SET @MsgError='ERROR AL INTENTAR ACTUALIZAR LOS DATOS DEL CLIENTE'
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		SET @MsgError='EL CLIENTE CON EL NUMERO DE CEDULA INGRESADO NO ESTA REGISTRADO EN LA BASE DE DATOS'
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA ELIMINAR CLIENTES
ALTER PROC PROC_ELIMINAR_CLIENTE(@Cedula_Cliente VARCHAR(15),
@MsgSuccess VARCHAR(50)='' OUTPUT,
@MsgError VARCHAR(50)='' OUTPUT)
AS
BEGIN
BEGIN TRAN
		IF EXISTS(SELECT * FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
		BEGIN
			BEGIN TRY
				DELETE FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente
				EXEC PROC_REGISTRAR_HISTORIAL 'Eliminar','Se elimino un cliente'
				SET @MsgSuccess='CLIENTE ELIMINADO EXITOSAMENTE'
				COMMIT
			END TRY
			BEGIN CATCH
				SET @MsgError= 'ERROR AL INTENTAR ELIMINAR AL CLIENTE SELECCIONADO'
				ROLLBACK
			END CATCH
		END
		ELSE
		BEGIN
			SET @MsgError='LA CEDULA DEL CLIENTE INGRESADA NO CORRESPONDE A NINGUN CLIENTE REGISTRADO EN LA BASE DE DATOS'
			ROLLBACK
		END
END
GO

--MOSTRAR TODOS LOS CLIENTES
ALTER PROC PROC_LISTAR_TODOS_CLIENTES
AS
BEGIN
	SELECT Cedula_Cliente AS 'N� Cedula',Nombre_Cliente+' '+Apellido_Cliente AS 'Nombre completo',YEAR(GETDATE())-YEAR(Fecha_Nacimiento_Cliente) AS 'Edad',
	Telefono_Cliente AS 'Telefono',Direccion_CLiente AS 'Direccion' FROM TB_Cliente
	ORDER BY [Nombre completo]
END
GO


--BUSCAR CLIENTE POR CEDULA
ALTER PROC PROC_BUSCAR_CEDULA_CLIENTE(
	@Cedula_Cliente VARCHAR(15),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CLIENTE WHERE [N� Cedula] =@Cedula_Cliente)
	BEGIN
		SELECT *FROM V_GENERALES_DE_CLIENTE
		WHERE [N� Cedula] =@Cedula_Cliente
	END
	ELSE
		SET @MsgError='CLIENTE NO ENCONTRADO'
END
GO

--FILTRO
ALTER PROC PROC_FILTRO_CLIENTE(
	@Nombre_Cliente VARCHAR(35)=NULL,
	@Edad_inicial INT =NULL,
	@Edad_final INT =NULL,
	@Direccion_cliente VARCHAR(65) =NULL,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF (@Edad_inicial<@Edad_final) OR(@Edad_inicial IS NULL AND @Edad_final IS NULL)
	BEGIN
		IF EXISTS (SELECT * FROM V_GENERALES_DE_CLIENTE WHERE (Edad BETWEEN @Edad_inicial AND @Edad_final) OR (Direccion LIKE '%'+@Direccion_cliente+'%') OR (Nombre+' '+Apellido LIKE '%'+@Nombre_Cliente+'%'))
		BEGIN
			SELECT * FROM V_GENERALES_DE_CLIENTE
			WHERE ((Edad BETWEEN @Edad_inicial AND @Edad_final) OR (@Edad_inicial IS NULL AND @Edad_final IS NULL))
			AND((Direccion LIKE '%'+@Direccion_cliente+'%') OR (@Direccion_cliente IS NULL))
			AND((Nombre+' '+Apellido LIKE '%'+@Nombre_Cliente+'%') OR (@Nombre_Cliente IS NULL))
		END
		ELSE
			SET @MsgError='NO EXISTEN REGISTROS QUE CUMPLAN LOS PARAMETROS DE FILTRO ESTABLECIDOS'
	END
	ELSE
		SET @MsgError='RANGO DE EDAD NO VALIDO �VERIFIQUE EL INTERVALO INTRODUCIDO!'
END
GO





