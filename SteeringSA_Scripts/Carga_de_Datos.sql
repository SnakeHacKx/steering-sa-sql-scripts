---HOJA DE DATOS PRE CARGADOS PARA PRUEBAS ---

--DATOS DE LA TABLA CONDUCTORES
EXEC PROC_REGISTRAR_CONDUCTOR '111-111-111','Juan','Pinilla','1111-1111',"04/13/1997",'B+','C','',''
EXEC PROC_REGISTRAR_CONDUCTOR '222-222-222','Pedro','Arrocha','2222-2222',"05/23/1992",'B-','D','',''
EXEC PROC_REGISTRAR_CONDUCTOR '333-333-333','Maria','Montenegro','3333-3333',"01/20/2000",'O+','D','',''
EXEC PROC_REGISTRAR_CONDUCTOR '444-444-444','Lian','Poveda','4444-4444',"10/13/1999",'AB+','F','',''

--DATOS DE LA TABLA VEHICULOS
EXEC PROC_REGISTRAR_VEHICULO 'AG0145','G2A3','Sedan','2','95','Azul'
EXEC PROC_REGISTRAR_VEHICULO 'G24S14','350V8','Pickup','4','95','Blanco'
EXEC PROC_REGISTRAR_VEHICULO '245135','FJ4DS','Camion','2','Diesel','Gris'
EXEC PROC_REGISTRAR_VEHICULO 'A45872','HD02','Sedan','5','95','Rojo'

--DATOS DE LA TABLA TIPO DE SERVICIO
EXEC PROC_REGISTRAR_TIPO_SERVICIO '1','Transporte','35.00','Transporte de personas para eventos o paseos'
EXEC PROC_REGISTRAR_TIPO_SERVICIO '2','Carga','45.00','Transporte de materiales o cualquier tipo de carga'
EXEC PROC_REGISTRAR_TIPO_SERVICIO '3','Delivery','20.00','Envio de paquetes o productos desde un local a un cliente'
ROLLBACK
--DATOS DE LA TABLA CLIENTE
EXEC PROC_REGISTRAR_CLIENTE '9-999-999','José','Peralta',"12/11/1992",'6857-5214','Chitre'
EXEC PROC_REGISTRAR_CLIENTE '6-725-632','Fernanda','Obando',"03/26/1991",'6258-8896','Santiago'
EXEC PROC_REGISTRAR_CLIENTE '4-233-1004','Ariel','Rodriguez',"09/17/1995",'6764-1987','Santiago'
EXEC PROC_REGISTRAR_CLIENTE '7-224-362','Mitzila','Portillo',"02/23/2000",'6927-1423','Los Santos'

--DATOS DE SERVICIOS
EXEC PROC_REGISTRAR_SERVICIO 12,'777-777','9-999-999','G24S14',"11/5/2021","11/9/2021"
EXEC PROC_REGISTRAR_SERVICIO 12,'111-111-111','4-233-1004','G24S14',"11/10/2021","11/15/2021"
EXEC PROC_REGISTRAR_SERVICIO 3,'333-333-333','4-233-1004','A45872',"11/3/2021","11/15/2021"
EXEC PROC_REGISTRAR_SERVICIO 1,'333-333-333','4-233-1004','A45872',"11/16/2021","11/25/2021"
EXEC PROC_REGISTRAR_SERVICIO 1,'444-444-444','6-725-632','AG0145',"11/16/2021","11/18/2021"

--DATOS DE REPORTES

EXEC PROC_REGISTRAR_REPORTE 'AG0145','Cambio de aceite de motor',"11/5/2021" --La fecha introducida no puede ser mayor a la actual a la hora de insertar
EXEC PROC_REGISTRAR_REPORTE 'AG0145','Cambio de faja de tiempo',"11/1/2021"
EXEC PROC_REGISTRAR_REPORTE '245135','Revision de luces',"10/30/2021"
EXEC PROC_REGISTRAR_REPORTE 'A45872','Revision de frenos',"11/8/2021"
EXEC PROC_REGISTRAR_REPORTE 'A45872','Ruido en extraño en el motor',"11/5/2021"

--DATOS DE MANTENIMIENTOS
EXEC PROC_REGISTRAR_MANTENIMIENTO 'AG0145','AG01',35.00,"11/13/2021",'Se realizo el cambio de la faja de tiempo gastada','Realizado' --la fecha debe cambiarse por la actual
EXEC PROC_REGISTRAR_MANTENIMIENTO '245135','2450',50.00,"11/13/2021",'Cambio de luces por leds debido al desgaste','Realizado'--la fecha debe cambiarse por la actual
EXEC PROC_REGISTRAR_MANTENIMIENTO 'A45872','A450',45.00,"11/13/2021",'Las pastillas de freno delanteras se encontraban en mal estado y se hizo el cambio','Realizado'--la fecha debe cambiarse por la actual
EXEC PROC_REGISTRAR_MANTENIMIENTO 'A45872','S/R',80.00,"11/26/2021",'Mantenimiento general despues de servicio','Pendiente'--la fecha debe cambiarse por una superio a la actual
EXEC PROC_REGISTRAR_MANTENIMIENTO 'G24S14','S/R',77.00,"12/1/2021",'Mantenimiento preventivo','Pendiente'--la fecha debe cambiarse por una superio a la actual
