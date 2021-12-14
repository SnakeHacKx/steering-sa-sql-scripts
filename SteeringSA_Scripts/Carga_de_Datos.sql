---HOJA DE DATOS PRECARGADOS PARA PRUEBAS ---

--DATOS DE LA TABLA CONDUCTORES
EXEC PROC_REGISTRAR_CONDUCTOR '07-0124-000325','Juan','Pinilla','6742-7752',"04/13/1997",'B+','C'
EXEC PROC_REGISTRAR_CONDUCTOR '07-2015-000322','Pedro','Arrocha','6256-2264',"05/23/1992",'B-','D'
EXEC PROC_REGISTRAR_CONDUCTOR '06-0725-000872','Maria','Montenegro','6539-0523',"01/20/2000",'O+','D'
EXEC PROC_REGISTRAR_CONDUCTOR '04-1004-001206','Lian','Poveda','6277-3444',"10/13/1999",'AB+','F'
EXEC PROC_REGISTRAR_CONDUCTOR '04-0245-000776','Cristian','Moreno','6287-3164',"02/25/1997",'A+','F'
EXEC PROC_REGISTRAR_CONDUCTOR '04-0985-000521','Alexandra','Muñoz','6545-0341',"10/7/2000",'B+','B'
EXEC PROC_REGISTRAR_CONDUCTOR '06-0142-000124','Jhon','Barrera','6777-9608',"01/02/1995",'A-','D'

--DATOS DE LA TABLA VEHICULOS
EXEC PROC_REGISTRAR_VEHICULO 'AG0145','Accent','Sedán','5','Gasolina 95','Azul'
EXEC PROC_REGISTRAR_VEHICULO 'G24S14','Tacoma','Pickup','4','Gasolina 95','Blanco'
EXEC PROC_REGISTRAR_VEHICULO '245135','FJ4DS','Camión','2','Diesel','Gris'
EXEC PROC_REGISTRAR_VEHICULO 'A45872','Elantra','Sedán','5','Gasolina 95','Rojo'
EXEC PROC_REGISTRAR_VEHICULO 'E14F25','Elantra','Sedán','5','Gasolina 95','Blanco'
EXEC PROC_REGISTRAR_VEHICULO '558214','R300','Moto','2','Gasolina 95','Gris'
EXEC PROC_REGISTRAR_VEHICULO 'BO0134','N400','Minivan','7','Gasolina 95','Negra'
EXEC PROC_REGISTRAR_VEHICULO '122DS1','Coaster','Autobús','8+','Diesel','Gris'

--DATOS DE LA TABLA TIPO DE SERVICIO
EXEC PROC_REGISTRAR_TIPO_SERVICIO 'Transporte','35.00'
EXEC PROC_REGISTRAR_TIPO_SERVICIO 'Carga','45.00'
EXEC PROC_REGISTRAR_TIPO_SERVICIO 'Delivery','20.00'
EXEC PROC_REGISTRAR_TIPO_SERVICIO 'Paseo','100.00'
EXEC PROC_REGISTRAR_TIPO_SERVICIO 'transporte de animales','250.00'

--DATOS DE LA TABLA CLIENTE
EXEC PROC_REGISTRAR_CLIENTE '06-0235-001025','José','Peralta',"12/11/1992",'6857-5214','Monagrillo, Chitre, Herrera'
EXEC PROC_REGISTRAR_CLIENTE '04-0825-000732','Fernanda','Obando',"03/26/1991",'6258-8896','San Antonio, Santiago, Veraguas'
EXEC PROC_REGISTRAR_CLIENTE '04-0021-000925','Ariel','Rodriguez',"09/17/1995",'6764-1987','EL Porvenir, Santiago, Veraguas'
EXEC PROC_REGISTRAR_CLIENTE '07-0423-000865','Mitzila','Portillo',"02/23/2000",'6927-1423','El sesteadero, Las Tablas, Los Santos'
EXEC PROC_REGISTRAR_CLIENTE '06-1002-000963','Alexander','Atencio',"12/30/1992",'6258-1722','Parita, Parita, Herrera'
EXEC PROC_REGISTRAR_CLIENTE '06-0852-000753','Roberto','Caldaña',"03/11/1995",'6526-7891','Llano Bonito, Chitre, Los Santos'

--DATOS DE SERVICIOS
EXEC PROC_REGISTRAR_SERVICIO 5,'07-0124-000325','04-0825-000732','G24S14',"11/5/2021","11/9/2021",'Se necesita enviar unos caballos desde santiago a chitre y regresarlos'
EXEC PROC_REGISTRAR_SERVICIO 4,'07-2015-000322','07-0423-000865','G24S14',"11/10/2021","11/15/2021",'Transportar a un grupo de personas al chorro de pozo azul'
EXEC PROC_REGISTRAR_SERVICIO 3,'06-0725-000872','04-0825-000732','A45872',"11/3/2021","11/15/2021",'Llevar entregar pedidos de un restaurante que se quedo sin repartidor'
EXEC PROC_REGISTRAR_SERVICIO 2,'07-0124-000325','06-0852-000753','A45872',"12/2/2021","12/6/2021",'Carga de materiales de construccion hasta San Martin'
EXEC PROC_REGISTRAR_SERVICIO 1,'06-0725-000872','07-0423-000865','AG0145',"11/16/2021","11/18/2021",'Se requiere llevar a unos trabajadores hasta chitre para junta de empres, se debe traer de vuelta'
EXEC PROC_REGISTRAR_SERVICIO 1,'04-0985-000521','06-0852-000753','AG0145',"11/30/2021","12/3/2021",'Transportar empleados desde una sucursar de la empresa Js a otra '
EXEC PROC_REGISTRAR_SERVICIO 2,'04-0985-000521','06-0235-001025','BO0134',"12/4/2021","12/6/2021",'Transporte de pacas para caballos'
EXEC PROC_REGISTRAR_SERVICIO 3,'04-1004-001206','07-0423-000865','122DS1',"12/16/2021","12/20/2021",'Entrega de paquetes a los clientes de un bazar'

--DATOS DE REPORTES

EXEC PROC_REGISTRAR_REPORTE 'AG0145','Cambio de aceite de motor',"11/5/2021"
EXEC PROC_REGISTRAR_REPORTE 'AG0145','Cambio de faja de tiempo',"11/1/2021"
EXEC PROC_REGISTRAR_REPORTE '245135','Revision de luces',"10/30/2021"
EXEC PROC_REGISTRAR_REPORTE 'A45872','Revision de frenos',"11/8/2021"
EXEC PROC_REGISTRAR_REPORTE 'A45872','Ruido en extraño en el motor',"11/5/2021"
EXEC PROC_REGISTRAR_REPORTE 'BO0134','Luz de la bateria encendida',"10/12/2021"
EXEC PROC_REGISTRAR_REPORTE '122DS1','Problemas al intentar encender el vehiculo',"11/15/2021"
EXEC PROC_REGISTRAR_REPORTE '245135','Se rompio el vidro delantero por una pelota mientras se encontraba estacionado',"09/23/2021"

--DATOS DE MANTENIMIENTOS
EXEC PROC_REGISTRAR_MANTENIMIENTO 'AG0145','AG01',35.00,"11/13/2021",'Se realizo el cambio de la faja de tiempo gastada','Realizado'
EXEC PROC_REGISTRAR_MANTENIMIENTO '245135','2450',50.00,"11/13/2021",'Cambio de luces por leds debido al desgaste','Realizado'
EXEC PROC_REGISTRAR_MANTENIMIENTO 'A45872','A450',45.00,"11/13/2021",'Las pastillas de freno delanteras se encontraban en mal estado y se hizo el cambio','Realizado'
EXEC PROC_REGISTRAR_MANTENIMIENTO 'A45872','S/R',80.00,"11/26/2021",'Mantenimiento general despues de servicio','Realizado'
EXEC PROC_REGISTRAR_MANTENIMIENTO 'G24S14','S/R',77.00,"12/1/2021",'Mantenimiento preventivo','Realizado'
EXEC PROC_REGISTRAR_MANTENIMIENTO 'BO0134','S/R',75.00,"12/2/2021",'Mantenimiento preventivo','Realizado'
