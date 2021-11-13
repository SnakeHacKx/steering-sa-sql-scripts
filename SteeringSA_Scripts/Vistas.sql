--VISTAS DE LA BASE DE DATOS

--VISTA PARA OBTENER LOS VEHICULOS QUE ESTAN ASIGNADOS A UN SERVICIO ACTUALMENTE
ALTER VIEW V_ESTADO_VEHICULO_FECHA_ACTUAL
AS
	SELECT V.Placa, V.Estado,S.Fecha_inicio,S.Fecha_finalizacion FROM Vehiculo V
	INNER JOIN Servicio S ON V.Placa=S.Placa
GO
