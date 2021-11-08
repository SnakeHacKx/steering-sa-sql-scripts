--TABLA DE CLIENTES

--PROCEDIMIENTO PARA REGISTRAR CLIENTES
CREATE PROC PROC_REGISTRAR_CLIENTE(
@Cedula_Cliente VARCHAR(15),
@Nombre_Cliente VARCHAR(35),
@Apellido_Cliente VARCHAR(35),
@Fecha_Nacimiento_Cliente DATE,
@Telefono_Cliente VARCHAR(15),
@Direccion_Cliente VARCHAR(65)
)
AS
BEGIN
BEGIN TRAN
	IF NOT EXISTS(SELECT * FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
	BEGIN
		INSERT INTO TB_Cliente(Cedula_Cliente,Nombre_Cliente,Apellido_Cliente,Fecha_Nacimiento_Cliente,Telefono_Cliente,Direccion_CLiente)
		VALUES(@Cedula_Cliente,@Nombre_Cliente,@Apellido_Cliente,@Fecha_Nacimiento_Cliente,@Telefono_Cliente,@Direccion_Cliente)
		COMMIT
	END
	ELSE
	BEGIN
		RAISERROR('YA EXISTE UN CLIENTE REGISTRADO CON EL NUMERO DE CEDULA INGRESADO',16,1)
		ROLLBACK
	END

END
GO

--PROCEDIMIENTO PARA ACTUALIZAR
CREATE PROC PROC_ACTUALIZAR_DATOS_CLIENTE(
@Cedula_Cliente VARCHAR(15),
@Nombre_Cliente VARCHAR(35),
@Apellido_Cliente VARCHAR(35),
@Fecha_Nacimiento_Cliente DATE,
@Telefono_Cliente VARCHAR(15),
@Direccion_Cliente VARCHAR(65)
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
			COMMIT
		END TRY
		BEGIN CATCH
			RAISERROR('ERROR AL INTENTAR ACTUALIZAR LOS DATOS DEL CLIENTE',16,1)
			ROLLBACK
		END CATCH
	END
	ELSE
	BEGIN
		RAISERROR('EL CLIENTE CON EL NUMERO DE CEDULA INGRESADO NO ESTA REGISTRADO EN LA BASE DE DATOS',16,1)
		ROLLBACK
	END
END
GO

--PROCEDIMIENTO PARA ELIMINAR CLIENTES
CREATE PROC PROC_ELIMINAR_CLIENTE(@Cedula_Cliente VARCHAR(15))
AS
BEGIN
BEGIN TRAN
		IF EXISTS(SELECT * FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente)
		BEGIN
			BEGIN TRY
				DELETE FROM TB_Cliente WHERE Cedula_Cliente=@Cedula_Cliente
				COMMIT
			END TRY
			BEGIN CATCH
				PRINT 'ERROR AL INTENTAR ELIMINAR AL CLIENTE SELECCIONADO'
				ROLLBACK
			END CATCH
		END
		ELSE
		BEGIN
			PRINT'LA CEDULA DEL CLIENTE INGRESADA NO CORRESPONDE A NINGUN CLIENTE REGISTRADO EN LA BASE DE DATOS'
			ROLLBACK
		END
END
GO






