--VISTAS DE LA BASE DE DATOS

--VISTA PARA OBTENER LOS VEHICULOS QUE ESTAN ASIGNADOS A UN SERVICIO ACTUALMENTE
ALTER VIEW V_ESTADO_VEHICULO_FECHA_ACTUAL
AS
	SELECT V.Placa, V.Estado,S.Fecha_inicio,S.Fecha_finalizacion FROM Vehiculo V
	INNER JOIN Servicio S ON V.Placa=S.Placa
GO

--VISTA DE GENERALES DEL SERVICIO (RELACIONA LAS TABLAS ASOCIADAS A UN SERVICIO)
ALTER VIEW V_GENERALES_DE_SERVICIO
AS
	SELECT S.Cod_Servicio AS 'Codigo',C.Nombre+' '+C.Apellido AS 'Conductor',V.Placa'Placa de vehiculo',V.Tipo AS 'Tipo de vehiculo',C.Cedula AS 'Cedula de Conductor',
	V.Color AS 'Color de Vehiculo',T.Nombre_servicio AS'Tipo de servicio',T.Descripcion_servicio AS 'Descripcion',S.Fecha_inicio AS 'Fecha de inicio',
	S.Fecha_finalizacion AS 'Fecha de finalizacion',S.Monto_Total_Servicio AS 'Costo total',CL.Nombre_Cliente+' '+CL.Apellido_Cliente AS 'Cliente',CL.Cedula_Cliente AS 'Cedula de Cliente'
	FROM Servicio S
	INNER JOIN Conductor C ON S.Cedula_Conductor=C.Cedula
	INNER JOIN Vehiculo V ON S.Placa = V.Placa
	INNER JOIN Tipo_servicios T ON S.Cod_tipo_servicio=T.Cod_tipo_servicio
	INNER JOIN TB_Cliente CL ON S.Cedula_Cliente = CL.Cedula_Cliente
GO

--VISTA DE GENERALES DEL MANTENIMIENTO (RELACIONA LAS TABLAS ASOCIADAS A UN MANTENIMIENTO)
ALTER VIEW V_GENERALES_DE_MANTENIMIENTO
AS
	SELECT M.Cod_Mantenimiento AS 'Codigo de mantenimiento',V.Placa AS 'Placa de vehiculo',V.Tipo AS 'Tipo de vehiculo',V.Modelo_vehiculo AS 'Modelo de vehiculo',
	M.Cod_reporte AS 'Reporte',M.Descripcion,M.Fecha AS 'Fecha de realizacion',M.Costo AS 'Costo total',M.Estado AS 'Estado Actual'
	FROM Mantenimiento M
	INNER JOIN Vehiculo V ON V.Placa = M.Placa_Vehiculo
GO

--VISTA GENERALES DE CLIENTE
ALTER VIEW V_GENERALES_DE_CLIENTE
AS
	SELECT Cedula_Cliente AS 'N° Cedula',Nombre_Cliente AS 'Nombre',Apellido_Cliente AS 'Apellido',Fecha_Nacimiento_Cliente AS 'Fecha de nacimiento',YEAR(GETDATE())-YEAR(Fecha_Nacimiento_Cliente) AS 'Edad',
	Telefono_Cliente AS 'Telefono',Direccion_CLiente AS 'Direccion' FROM TB_Cliente
GO
--VISTA GENERALES DE CONDUCTOR
ALTER VIEW V_GENERALES_DE_CONDUCTOR
AS
	SELECT Cedula AS 'N° Cedula',Nombre,Apellido,Telefono AS 'Contacto',Fecha_de_nacimiento AS 'Fecha de nacimiento',YEAR(GETDATE()) -YEAR(Fecha_de_nacimiento)
	AS 'Edad',Tipo_de_sangre AS 'Grupo sanguineo',Tipo_de_licencia AS 'Licencia'
	FROM Conductor
GO
--VISTA DE GENERALES DE VEHICULO
CREATE VIEW V_GENERALES_DE_VEHICULO
AS
	SELECT Placa AS 'Placa de vehiculo',Tipo,Modelo_vehiculo AS 'Modelo de Vehiculo',pasajero AS 'Capacidad',Color,Tipo_de_combustible AS 'Tipo de combustible',Estado FROM Vehiculo
GO

--VISTA DE GENERALES DE REPORTE
ALTER VIEW V_GENERALES_DE_REPORTE
AS
	SELECT Cod_reporte AS 'Codigo de Reporte',Placa_Vehiculo as 'Placa del vehiculo',Descripcion,Fecha AS 'Fecha de reporte', Estado FROM Reporte
GO

--VISTA GENERAL DE TIPO DE SERVICIO
CREATE VIEW V_GENERALES_DE_TIPO_DE_SERVICIO
AS
	SELECT Cod_tipo_servicio AS 'Codigo',Nombre_servicio AS 'Nombre del servicio',Descripcion_servicio AS 'Descripcion',
	Costo_servicio AS 'Costo diario' FROM Tipo_servicios
GO

--VISTAR GENERAL DE HISTORIAL DE ACCIONES SOBRE LA BASE DE DATOS
CREATE VIEW v_VER_HISTORIAL_DE_ACCIONES
AS
	SELECT U.Id_usuario AS 'ID',U.Nombre_usuario AS 'Nombre de Usuario',U.Rol_usuario AS 'Rol de Usuario',H.Accion AS 'Accion realizada',H.Fecha AS 'Fecha de realizacion',H.ID_operacion'ID de accion' FROM TB_Historial H
	INNER JOIN TB_Usuarios U ON U.Id_usuario=H.Id_usuario
GO

--VISTA PARA OBTENER LOS USUARIOS Y SUS ROLES
ALTER VIEW V_VER_USUARIOS
AS
	SELECT m.name Usuario, p.name Rol FROM sys.database_role_members rm
	INNER JOIN sys.database_principals p ON rm.role_principal_id = p.principal_id
	INNER JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
	WHERE m.type='S'
GO