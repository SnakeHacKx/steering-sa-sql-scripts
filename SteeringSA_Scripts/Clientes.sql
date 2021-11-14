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
		SET @MsgSuccess = 'CLIENTE REGISTRADO EXITOSAMENTE'
		COMMIT
	END
	ELSE
	BEGIN
		SET @MsgError= 'YA EXISTE UN CLIENTE REGISTRADO CON EL NUMERO DE CEDULA INGRESADO'
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
	SELECT Cedula_Cliente AS 'N° Cedula',Nombre_Cliente+' '+Apellido_Cliente AS 'Nombre completo',YEAR(GETDATE())-YEAR(Fecha_Nacimiento_Cliente) AS 'Edad',
	Telefono_Cliente AS 'Telefono',Direccion_CLiente AS 'Direccion' FROM TB_Cliente
	ORDER BY [Nombre completo]
END
GO

--BUSCAR CLIENTE POR NOMBRE
ALTER PROC PROC_BUSCAR_NOMBRE_CLIENTE(
	@Nombre_Cliente VARCHAR(35),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CLIENTE WHERE [Nombre completo] LIKE '%'+@Nombre_Cliente+'%')
	BEGIN
		SELECT *FROM V_GENERALES_DE_CLIENTE
		WHERE [Nombre completo] LIKE '%'+@Nombre_Cliente+'%'
	END
	ELSE
		SET @MsgError='CLIENTE NO ENCONTRADO'
END
GO

--BUSCAR CLIENTE POR CEDULA
ALTER PROC PROC_BUSCAR_CEDULA_CLIENTE(
	@Cedula_Cliente VARCHAR(15),
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	IF EXISTS(SELECT *FROM V_GENERALES_DE_CLIENTE WHERE [N° Cedula] =@Cedula_Cliente)
	BEGIN
		SELECT *FROM V_GENERALES_DE_CLIENTE
		WHERE [N° Cedula] =@Cedula_Cliente
	END
	ELSE
		SET @MsgError='CLIENTE NO ENCONTRADO'
END
GO





