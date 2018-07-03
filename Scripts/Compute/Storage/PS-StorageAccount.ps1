# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

#Crear Grupo de recursos (si no existe) 
New-AzureRmResourceGroup -Name TestRG -Location westeurope 

# Crear Storage Account TestStorageAccount 
New-AzureRmStorageAccount -ResourceGroupName TestRG -AccountName sastdtestiberostar -Type Standard_LRS -Location westeurope

# Almacenar el objeto de cuenta de almacenamiento en una variable 
$sa = Get-AzureRmStorageAccount -ResourceGroupName TestRG -AccountName sastdtestiberostar 

# Crear blob en la cuenta de almacenamiento 
New-AzureStorageContainer -Name vhds -Context $sa.Context -Permission blob



##########################################################################
##########################################################################

# Crear fileshare
$AccountKey    = (Get-AzureRmStorageAccountKey -StorageAccountName sastdtestiberostar -ResourceGroupName TestRG).Value[0]
$ctx           = New-AzureStorageContext -StorageAccountName sastdtestiberostar -StorageAccountKey $AccountKey
New-AzureStorageShare -Name iberoshare -Context $ctx.Context
Set-AzureStorageShareQuota -ShareName iberoshare -Quota 1024 -Context $ctx.Context

# Crear directorio
New-AzureStorageDirectory -Context $ctx.Context -ShareName iberoshare -Path Iberostar

# Escribir la fecha en un txt
Get-Date | Out-File -FilePath "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Iberostar\Test.txt" -Force

# Subir el txt a nuestro direcotorio creado
Set-AzureStorageFileContent -Context $ctx.Context -ShareName iberoshare -Source "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Iberostar\Test.txt" -Path "Iberostar\Test.txt"

# Borrar si hay un archivo existe llamado Test.txt
Remove-Item -Path "C:\Users\javier.gonzalez\Desktop\Test.txt" -Force -ErrorAction SilentlyContinue
Get-AzureStorageFileContent -Context $ctx.Context -ShareName iberoshare -Path "Iberostar\Test.txt" -Destination "C:\Users\javier.gonzalez\Desktop\Test.txt"

# Connect as a network drive