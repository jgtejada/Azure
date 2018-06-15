<# 

.VERSION
  
	1.0  01-03-2017 -- Initial script  Login-AzureRM-1.0


.SYNOPSIS
	El proposito de este script es del realizar el login en Azure. 
    Este script se usa para iniciar sesion en Azure RM. Si tu deseas usar Azure SM este script no es para ti.

.DESCRIPCION
	Este script ser� usado para iniciar sesion en Azure RM.

.SALIDA


REQUERIMIENTOS:
    El script ser� ejecutado con suficientes permisos y:
        - Tener instalada la �ltima version de PowerShell y .NET.
        - La versi�n correcta de de Azure RM -> Install-Module AzureRM

Este c�digo de ejemplo se proporciona s�lo con fines ilustrativos y no se pretende que se utilice en un entorno de producci�n.
ESTE C�DIGO ES DE EJEMPLO Y CUALQUIER INFORMACI�N RELACIONADA SE PROPORCIONA "TAL CUAL" SIN GARANT�A DE NING�N TIPO, SEA EXPRESA 
O IMPL�CITA, INCLUYENDO PERO NO LIMITANDO A LAS GARANT�AS IMPL�CITAS DE COMERCIABILIDAD Y/O ADECUACI�N PARA UN PROP�SITO PARTICULAR. 
Le concedemos un derecho no exclusivo y libre de regal�as para usar y modificar el c�digo de ejemplo y para reproducir y distribuir 
el c�digo de objeto del c�digo de ejemplo, Siempre que Usted acepte: 
(I)	no utilizar Nuestro nombre, logotipo o marcas comerciales para comercializar Su producto de software en el que est� incluido el 
c�digo de ejemplo; 
(II) incluir un aviso de copyright v�lido en Su producto de software en el que est� incluido el C�digo de Muestra;
(III) indemnizar, eximir de responsabilidad y defender a Nosotros ya Nuestros proveedores de y en contra de cualquier 
reclamo o demanda legal, incluyendo los honorarios de abogados, que surjan o resulten del uso o distribuci�n del C�digo Muestra. 
Tenga en cuenta: Ninguna de las condiciones descritas en la exenci�n de responsabilidad anterior reemplazar� los t�rminos y condiciones 
contenidos en la Descripci�n de los servicios al cliente de Premier. Esta publicaci�n se proporciona "TAL CUAL" sin garant�as, y no confiere ning�n derecho

#>
 
#Seleccionar la suscripcion de Azure con la que quieres trabajar utilizando powershell
Login-AzureRmAccount
$SId = 
    ( Get-AzurermSubscription |
        Out-GridView `
          -Title "Selecciona cuenta ..." `
          -PassThru
    ).SubscriptionId

Select-AzurermSubscription -SubscriptionId $SId