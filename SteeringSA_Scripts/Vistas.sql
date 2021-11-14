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
CREATE VIEW V_GENERALES_DE_MANTENIMIENTO
AS
	SELECT M.Cod_Mantenimiento AS 'Codigo de mantenimiento',V.Placa AS 'Placa de vehiculo',V.Tipo AS 'Tipo de vehiculo',V.Motor AS 'Motor',
	M.Cod_reporte AS 'Reporte',M.Descripcion,M.Fecha AS 'Fecha de realizacion',M.Costo AS 'Costo total',M.Estado AS 'Estado Actual'
	FROM Mantenimiento M
	INNER JOIN Vehiculo V ON V.Placa = M.Placa_Vehiculo
GO
