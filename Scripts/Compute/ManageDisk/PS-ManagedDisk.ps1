# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear Grupo de recursos (si no existe) 
New-AzureRmResourceGroup -Name TestRG -Location westeurope

# Almacenar configuración de disco en variable
$diskConfig = New-AzureRmDiskConfig -SkuName ‘Standard_LRS‘ -Location westeurope -CreateOption Empty -DiskSizeGB 1

# Creamos el disco administrado
New-AzureRmDisk -DiskName psmd -Disk $diskConfig -ResourceGroupName TestRG