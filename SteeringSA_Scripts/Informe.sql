--FUNCION PARA EL INFORME (SOLO LO PUEDE VER EL ADMINISTRADOR)
ALTER FUNCTION FUNC_OBTENER_HISTORIAL()--EN ESTE PROCEDIMIENTO SE CREA EL FORMATO DEL INFORME COMO UN STRING
RETURNS VARCHAR(max)
AS
BEGIN
	DECLARE @informe VARCHAR(max)
	SET @informe = '                 INFORME GENERAL'+CHAR(13)+CHAR(13)
	SET @informe += '       Cantidad de registros en cada tabla'+CHAR(13)
	SET @informe += '   Tabla                              Cantidad'+CHAR(13)
	SET @informe += 'Conductores                              '+ CAST ((SELECT COUNT(*) FROM Conductor) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Clientes                                 '+ CAST ((SELECT COUNT(*) FROM TB_Cliente) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Vehiculos                                '+ CAST ((SELECT COUNT(*) FROM Vehiculo) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Servicios                                '+ CAST ((SELECT COUNT(*) FROM Servicio) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Reportes                                 '+ CAST ((SELECT COUNT(*) FROM Reporte) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Mantenimientos                           '+ CAST ((SELECT COUNT(*) FROM Mantenimiento) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Tipos de servicios                       '+ CAST ((SELECT COUNT(*) FROM Tipo_servicios) AS VARCHAR(6))+CHAR(13)+CHAR(13)
	SET @informe += '                    Totales'+CHAR(13)
	SET @informe += 'Ganancias brutas en servicios          '+ CAST ((SELECT SUM(Monto_Total_Servicio) FROM Servicio) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Gastos brutos en mantenimientos        '+ CAST ((SELECT SUM(Costo) FROM Mantenimiento) AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Balance general                        '+ CAST (((SELECT SUM(Monto_Total_Servicio) FROM Servicio)-(SELECT SUM(Costo) FROM Mantenimiento)) AS VARCHAR(6))+CHAR(13)+CHAR(13)
	SET @informe += 'Cantidad de acciones sobre las tablas'+CHAR(13)
	SET @informe += 'Insertar                                 '+ CAST ((SELECT COUNT(*) FROM TB_Historial WHERE Accion='Insertar') AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Actualizar                               '+ CAST ((SELECT COUNT(*) FROM TB_Historial WHERE Accion='Actualizar') AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Eliminar                                 '+ CAST ((SELECT COUNT(*) FROM TB_Historial WHERE Accion='Eliminar') AS VARCHAR(6))+CHAR(13)
	SET @informe += 'Total de acciones                        '+ CAST ((SELECT COUNT(*) FROM TB_Historial) AS VARCHAR(6))+CHAR(13)+CHAR(13)
	SET @informe +=''+DBO.FUNC_GENERALES_CONDUCTORES()+CHAR(13)
	SET @informe +=''+DBO.FUNC_GENERALES_CLIENTES()



	RETURN @informe
END
GO

PRINT ''+DBO.FUNC_OBTENER_HISTORIAL()
PRINT ''+DBO.FUNC_GENERALES_CLIENTES()
go


--FUNCION PARA OBTENER LOS DATOS DE TODOS LOS CONDUCTORES
ALTER FUNCTION FUNC_GENERALES_CONDUCTORES()
RETURNS VARCHAR(max)
AS
BEGIN
	DECLARE 
	@cedula VARCHAR(15),
	@nombre VARCHAR(30),
	@apellido VARCHAR(30),
	@telefono VARCHAR(10),
	@fechaNac date,
	@tipoSangre VARCHAR(3),
	@tipoLicencia VARCHAR(2),
	@Salida VARCHAR(1500)
	SET @Salida ='                  Condutores'+CHAR(13)
	SET @Salida +='Formato / Cedula / Nombre / Apellido  / Telefono / Fecha de nacimiento / Tipo de sangre / Licencia'+CHAR(13)+CHAR(13)
	DECLARE C_CONDUCTORES CURSOR LOCAL SCROLL
	FOR SELECT *FROM Conductor
	OPEN C_CONDUCTORES
		FETCH C_CONDUCTORES INTO @cedula,@nombre,@apellido,@telefono,@fechaNac,@tipoSangre,@tipoLicencia
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SET @Salida +=''+@cedula+' / '+@nombre+' / '+@apellido+' / '+@telefono+' / '+CAST(@fechaNac AS VARCHAR(12))+' / '+@tipoSangre+' / '+@tipoLicencia+CHAR(13)
		FETCH C_CONDUCTORES INTO @cedula,@nombre,@apellido,@telefono,@fechaNac,@tipoSangre,@tipoLicencia
	END
	CLOSE C_CONDUCTORES
	DEALLOCATE C_CONDUCTORES
	RETURN (@Salida)
END
GO

--FUNCION PARA OBTENER LOS DATOS GENERALES DE CLIENTES
CREATE FUNCTION FUNC_GENERALES_CLIENTES()
RETURNS VARCHAR(1500)
AS
BEGIN
	DECLARE
	@Cedula_Cliente VARCHAR(15),
	@Nombre_Cliente VARCHAR(35),
	@Apellido_Cliente VARCHAR(35),
	@Fecha_Nacimiento_Cliente DATE,
	@Telefono_Cliente VARCHAR(15),
	@Direccion_Cliente VARCHAR(65),
	@Salida VARCHAR(1500)
	SET @Salida ='                  Clientes'+CHAR(13)
	SET @Salida +='Formato / Cedula / Nombre / Apellido  / Fecha de nacimiento / Telefono / Direccion'+CHAR(13)+CHAR(13)
	DECLARE C_CLIENTES CURSOR LOCAL SCROLL
	FOR SELECT *FROM TB_Cliente
	OPEN C_CLIENTES
		FETCH C_CLIENTES INTO @Cedula_Cliente,@Nombre_Cliente,@Apellido_Cliente,@Fecha_Nacimiento_Cliente,@Telefono_Cliente,@Direccion_Cliente
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SET @Salida +=''+@Cedula_Cliente+' / '+@Nombre_Cliente+' / '+@Apellido_Cliente+' / '+CAST(@Fecha_Nacimiento_Cliente AS VARCHAR(12))+' / '+@Telefono_Cliente+' / '+@Direccion_Cliente+CHAR(13)
		FETCH C_CLIENTES INTO @Cedula_Cliente,@Nombre_Cliente,@Apellido_Cliente,@Fecha_Nacimiento_Cliente,@Telefono_Cliente,@Direccion_Cliente
	END
	CLOSE C_CLIENTES
	DEALLOCATE C_CLIENTES
	RETURN (@Salida)
END
GO

