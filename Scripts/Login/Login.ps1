<# 

.VERSION
  
	1.0  01-03-2017 -- Initial script  Login-AzureRM-1.0


.SYNOPSIS
	El proposito de este script es del realizar el login en Azure. 
    Este script se usa para iniciar sesion en Azure RM. Si tu deseas usar Azure SM este script no es para ti.

.DESCRIPCION
	Este script será usado para iniciar sesion en Azure RM.

.SALIDA


REQUERIMIENTOS:
    El script será ejecutado con suficientes permisos y:
        - Tener instalada la última version de PowerShell y .NET.
        - La versión correcta de de Azure RM -> Install-Module AzureRM

Este código de ejemplo se proporciona sólo con fines ilustrativos y no se pretende que se utilice en un entorno de producción.
ESTE CÓDIGO ES DE EJEMPLO Y CUALQUIER INFORMACIÓN RELACIONADA SE PROPORCIONA "TAL CUAL" SIN GARANTÍA DE NINGÚN TIPO, SEA EXPRESA 
O IMPLÍCITA, INCLUYENDO PERO NO LIMITANDO A LAS GARANTÍAS IMPLÍCITAS DE COMERCIABILIDAD Y/O ADECUACIÓN PARA UN PROPÓSITO PARTICULAR. 
Le concedemos un derecho no exclusivo y libre de regalías para usar y modificar el código de ejemplo y para reproducir y distribuir 
el código de objeto del código de ejemplo, Siempre que Usted acepte: 
(I)	no utilizar Nuestro nombre, logotipo o marcas comerciales para comercializar Su producto de software en el que está incluido el 
código de ejemplo; 
(II) incluir un aviso de copyright válido en Su producto de software en el que esté incluido el Código de Muestra;
(III) indemnizar, eximir de responsabilidad y defender a Nosotros ya Nuestros proveedores de y en contra de cualquier 
reclamo o demanda legal, incluyendo los honorarios de abogados, que surjan o resulten del uso o distribución del Código Muestra. 
Tenga en cuenta: Ninguna de las condiciones descritas en la exención de responsabilidad anterior reemplazará los términos y condiciones 
contenidos en la Descripción de los servicios al cliente de Premier. Esta publicación se proporciona "TAL CUAL" sin garantías, y no confiere ningún derecho

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