# Logarse en la suscripción desde una ventana de PowerShell 
Login-AzureRmAccount

# Seleccionar subscripción 
Get-AzureRmSubscription (comprobar suscripciones del usuario) 
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription (seleccionar suscripción)

# Crear grupo de recursos
New-AzureRmResourceGroup -Name JSON -Location westeurope

# Crear cuenta de almacenamiento
$storageName = "st" + (Get-Random)
New-AzureRmStorageAccount -ResourceGroupName JSON -AccountName $storageName -Location westeurope -SkuName "Standard_LRS" -Kind Storage
$accountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName JSON -Name $storageName).Value[0]
$context = New-AzureStorageContext -StorageAccountName $storageName -StorageAccountKey $accountKey 
New-AzureStorageContainer -Name "templates" -Context $context -Permission Container

# Subir plantillas
Set-AzureStorageBlobContent -File "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Iberostar\JSON\CreateVMTemplate.json" -Context $context -Container templates
Set-AzureStorageBlobContent -File "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Iberostar\JSON\Parameters.json" -Context $context -Container templates

# Crear VM
$templatePath = "https://" + $storageName + ".blob.core.windows.net/templates/CreateVMTemplate.json"
$parametersPath = "https://" + $storageName + ".blob.core.windows.net/templates/Parameters.json"
New-AzureRmResourceGroupDeployment -ResourceGroupName "JSON" -Name "JSONDeployment" -TemplateUri $templatePath -TemplateParameterUri $parametersPath