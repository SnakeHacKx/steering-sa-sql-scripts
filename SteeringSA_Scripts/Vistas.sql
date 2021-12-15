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
	SELECT S.Cod_Servicio AS 'ID',
	T.Nombre_servicio AS'Tipo de Servicio',
	T.Cod_tipo_servicio AS 'ID Tipo de Servicio',
	C.Nombre+' '+C.Apellido AS 'Conductor',
	C.Cedula AS 'Cédula (Conductor)',
	CL.Nombre_Cliente+' '+CL.Apellido_Cliente AS 'Cliente',
	CL.Cedula_Cliente AS 'Cédula (Cliente)',
	V.Placa AS 'Matrícula del Vehículo',
	V.Tipo AS 'Tipo de Vehículo',
	FORMAT(S.Fecha_inicio,'dd-MM-yyyy') AS 'Fecha de Inicio',
	FORMAT(S.Fecha_finalizacion,'dd-MM-yyyy') AS 'Fecha de Finalización',
	DATEDIFF(DAY,S.Fecha_inicio,S.Fecha_finalizacion) AS 'Duración (días)',
	ROUND(S.Monto_Total_Servicio,2,1) AS 'Costo Total',
	S.Descripcion_servicio AS 'Descripción'
	FROM Servicio S
	INNER JOIN Conductor C ON S.Cedula_Conductor=C.Cedula
	INNER JOIN Vehiculo V ON S.Placa = V.Placa
	INNER JOIN Tipo_servicios T ON S.Cod_tipo_servicio=T.Cod_tipo_servicio
	INNER JOIN TB_Cliente CL ON S.Cedula_Cliente = CL.Cedula_Cliente
GO

--VISTA DE GENERALES DEL MANTENIMIENTO (RELACIONA LAS TABLAS ASOCIADAS A UN MANTENIMIENTO)
ALTER VIEW V_GENERALES_DE_MANTENIMIENTO
AS
	SELECT M.Cod_Mantenimiento AS 'ID',
	M.Cod_reporte AS 'ID Reporte',
	M.Costo AS 'Costo Total',
	M.Estado AS 'Estado Actual',
	FORMAT(M.Fecha,'dd-MM-yyyy') AS 'Fecha de Realización',
	V.Placa AS 'Matrícula de Vehículo',
	V.Tipo AS 'Tipo de Vehículo',
	M.Descripcion AS 'Descripción'
	FROM Mantenimiento M
	INNER JOIN Vehiculo V ON V.Placa = M.Placa_Vehiculo
GO

--VISTA GENERALES DE CLIENTE
ALTER VIEW V_GENERALES_DE_CLIENTE
AS
	SELECT Cedula_Cliente AS 'N° Cédula',
	Nombre_Cliente AS 'Nombre',
	Apellido_Cliente AS 'Apellido',
	FORMAT(Fecha_Nacimiento_Cliente,'dd-MM-yyyy') AS 'Fecha de Nacimiento',
	YEAR(GETDATE())-YEAR(Fecha_Nacimiento_Cliente) AS 'Edad',
	Telefono_Cliente AS 'Contacto',
	Direccion_CLiente AS 'Dirección' 
	FROM TB_Cliente
GO
--VISTA GENERALES DE CONDUCTOR
ALTER VIEW V_GENERALES_DE_CONDUCTOR
AS
	SELECT Cedula AS 'N° Cédula',
	Nombre,
	Apellido,
	Telefono AS 'Contacto',
	FORMAT(Fecha_de_nacimiento,'dd-MM-yyyy') AS 'Fecha de Nacimiento',
	YEAR(GETDATE()) -YEAR(Fecha_de_nacimiento)AS 'Edad',
	Tipo_de_sangre AS 'Grupo Sanguíneo',
	Tipo_de_licencia AS 'Tipo de Licencia'
	FROM Conductor
GO

--VISTA DE GENERALES DE VEHICULO
ALTER VIEW V_GENERALES_DE_VEHICULO
AS
	SELECT Placa AS 'Matrícula',
	Tipo,
	Modelo_vehiculo AS 'Modelo',
	pasajero AS 'Capacidad',
	Color,
	Tipo_de_combustible AS 'Tipo de Combustible',
	Estado 
	FROM Vehiculo
GO

--VISTA DE GENERALES DE REPORTE
ALTER VIEW V_GENERALES_DE_REPORTE
AS
	SELECT Cod_reporte AS 'ID',
	Placa_Vehiculo as 'Matrícula del Vehículo'
	,FORMAT(Fecha,'dd-MM-yyyy') AS 'Fecha de Registro',
	Estado,
	Descripcion AS 'Descripción' FROM Reporte
GO

--VISTA GENERAL DE TIPO DE SERVICIO
ALTER VIEW V_GENERALES_DE_TIPO_DE_SERVICIO
AS
	SELECT Cod_tipo_servicio AS 'ID',
	Nombre_servicio AS 'Nombre',
	ROUND(Costo_servicio,2,1) AS 'Costo Diario'
	FROM Tipo_servicios
GO

--VISTAR GENERAL DE HISTORIAL DE ACCIONES SOBRE LA BASE DE DATOS
ALTER VIEW V_VER_HISTORIAL_DE_ACCIONES
AS
	SELECT U.Usuario AS 'Nombre de Usuario',
	U.Rol AS 'Rol',H.Accion AS 'Acción Realizada',
	FORMAT(H.Fecha,'dd-MM-yyyy') AS 'Fecha de Realización',
	H.ID_operacion'ID de Acción'
	FROM TB_Historial H
	INNER JOIN V_VER_USUARIOS U ON U.Rol=H.Rol_Usuario
GO

--VISTA PARA OBTENER LOS USUARIOS Y SUS ROLES
ALTER VIEW V_VER_USUARIOS
AS
	SELECT m.name Usuario, p.name Rol FROM sys.server_role_members rm
	INNER JOIN sys.server_principals p ON rm.role_principal_id = p.principal_id
	INNER JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id
	WHERE m.type='S' AND (rm.role_principal_id = 279 OR rm.role_principal_id =294 OR rm.role_principal_id = 5)--la S identifica al tipo de usuario SQL 
GO
