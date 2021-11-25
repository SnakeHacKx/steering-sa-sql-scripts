--USUARIOS

--PROCEDIMIENTO PARA REGISTRAR EN UN HISTORIAL TODAS LA OPERACIONES REALIZADAS POR LOS USUARIOS EN LA BASE DE DATOS
ALTER PROC PROC_REGISTRAR_HISTORIAL(
	@Accion VARCHAR(20),--INSERTAR/ELIMINAR/ACTUALIZAR
	@Descripcion VARCHAR(50)--INDICAR LA TABLA EN LA QUE SE REALIZAR LA ACCION
)
AS--ESTE PROCEDIMIENTO SE INCLUYE EN CADA UNO DE LOS PROCEDIMIENTOS PARA LAS OPERACIONES BASICAS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		INSERT INTO TB_Historial (Nombre_usuario,Rol_Usuario,Accion,Descripcion,Fecha)
		VALUES(USER_NAME(),DBO.FUNC_OBTENER_ROL_USUARIO(),@Accion,@Descripcion,GETDATE())
		COMMIT
	END TRY
	BEGIN CATCH
		RAISERROR('FALLO AL REGISTRAR LA OPERACION EN EL HISTORIAL',16,1)
		ROLLBACK
	END CATCH
END
GO

--FUNCION QUE OBTIENE EL ROL DEL USUARIO ACTUAL, FUE SACADO PARCIALMENTE DE INTERNET (GRACIAS STACKOVERFLOW)
ALTER FUNCTION FUNC_OBTENER_ROL_USUARIO()
RETURNS VARCHAR(30)
AS
BEGIN
	DECLARE @User_Rol VARCHAR(10)
	SET @User_Rol=(SELECT p.name rol FROM sys.database_role_members rm
		INNER JOIN sys.database_principals p
		ON rm.role_principal_id = p.principal_id
		INNER JOIN sys.database_principals m
		ON rm.member_principal_id = m.principal_id
		WHERE m.name=USER_NAME())
	RETURN(@User_Rol)
END
GO

--PROCEDIMIENTO PARA REGISTRAR NUEVO USUARIO
ALTER PROC PROC_REGISTRAR_USUARIO(
	@User_name VARCHAR(25),
	@User_Password Varchar(30),
	@User_rol VARCHAR(10),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
BEGIN TRAN
	BEGIN TRY
	
		DECLARE 
		@Crear_login_usuario VARCHAR(200),				--VA A CONTENER EL CODIGO NECESARIO PARA CREAR UN LOGIN DE USUARIO
		@Crear_Usuario VARCHAR(200),					--CONTIENE EL CODIGO NECESARIO PARA CREAR EL USUARIO EN LA BASE DE DATOS PARA EL LOGIN CREADO
		@Asinar_rol VARCHAR(200)						--CONTIENE EL CODIGO NECESARIO PARA ASIGNAR EL USUARIO CREADO A UN ROL DEFINIDO EN LA BASE DE DATOS PARA HEREDAR SUS PERMISOS
		SET @Crear_login_usuario = 'CREATE LOGIN ['+@User_name+'] WITH PASSWORD= '''+@User_Password+''', DEFAULT_DATABASE=[Steering_SA], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
		EXEC(@Crear_login_usuario)						--EJECUTA LA SENTENCIA DE CREACION DE LOGIN
		SET @Crear_Usuario='CREATE USER ['+@User_name+'] FOR LOGIN ['+@User_name+'] WITH DEFAULT_SCHEMA=[dbo]'
		EXEC(@Crear_Usuario)							--Ejecuta la sentencia para crear el usuario 
		IF @User_rol='Empleado'							--Si es empleado se le asigna el rol de empleado
		BEGIN
			SET @Asinar_rol='ALTER ROLE [Rol_Empleado] ADD MEMBER ['+@User_name+']'
			EXEC(@Asinar_rol)							--ejecuta la sentencia para asignar al nuevo usuario el rol de empleado
		END
		ELSE
		BEGIN
			SET @Asinar_rol = 'ALTER ROLE [Rol_Administrador] ADD MEMBER ['+@User_name+']'
			EXEC(@Asinar_rol)--ejecuta la sentencia para asignar al nuevo usuario el rol de empleado
		END
		SET @MsgSuccess ='Usuario creado exitosamente'
		COMMIT
	END TRY
	BEGIN CATCH
		SET @MsgError='ERROR EN LA CREACION DEL USUARIO'
		ROLLBACK
	END CATCH

END
GO
--ELIMINAR USUARIOS
ALTER PROC PROC_ELIMINAR_USUARIO(
@User_name VARCHAR(25),
@MsgSuccess VARCHAR(50)='' OUTPUT,
@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	DECLARE @query VARCHAR(100)
	BEGIN TRY
		SET @query = 'DROP USER '+@User_name	--primero se eliminar el usuario de la base de datos
		EXEC(@query)
		SET @query ='DROP LOGIN '+@User_name			--luego se elimina el login del servidor
		EXEC(@query)
		SET @MsgSuccess='Usuario eliminado'
		COMMIT
	END TRY
	BEGIN CATCH
		SET @MsgError='Error al intentar eliminar el usuario'+char(13)+'Verifique el nombre de usuario'
		ROLLBACK
	END CATCH
END
GO

--MODIFICAR CONTRASEÑA DE USUARIO
ALTER PROC PROC_CAMBIAR_CONTRASEÑA_USUARIO(
	@User_name VARCHAR(25),
	@New_pass VARCHAR(30),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	DECLARE @query VARCHAR(100)
	BEGIN TRY
		SET @query = 'ALTER LOGIN '+@User_name+' WITH PASSWORD = '''+@New_pass+''''
		EXEC(@query)
		SET @MsgSuccess='Contraseña actualizada correctamente'
		COMMIT
	END TRY
	BEGIN CATCH
		SET @MsgError='Ocurrio un error al intentar cambiar la contraseña'
		ROLLBACK
	END CATCH
END
GO

--MODIFICAR NOMBRE DE USUARIO
CREATE PROC PROC_CAMBIAR_NOMBRE_DE_USUARIO(
	@User_name VARCHAR(25),
	@new_name VARCHAR(25),
	@MsgSuccess VARCHAR(50)='' OUTPUT,
	@MsgError VARCHAR(50)='' OUTPUT
)
AS
BEGIN
	BEGIN TRAN
	DECLARE @query VARCHAR(100)
	BEGIN TRY
		SET @query ='ALTER LOGIN '+@User_name+' WITH NAME = '+@new_name
		PRINT 'EXITO'
		EXEC(@query)
		SET @MsgSuccess='Nombre de usuario actualizado correctamente'
		COMMIT
	END TRY
	BEGIN CATCH
		SET @MsgError='Ocurrio un error al intentar cambiar el nombre de usuario'
		ROLLBACK
	END CATCH
END
GO