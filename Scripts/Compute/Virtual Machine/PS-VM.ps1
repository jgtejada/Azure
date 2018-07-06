# Logarse en la suscripción desde una ventana de PowerShell 
Login-AzureRmAccount

# Seleccionar subscripción 
Get-AzureRmSubscription (comprobar suscripciones del usuario) 
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription (seleccionar suscripción) 

# Crear variable con Región y otra con Resource Group 
$locName = “westeurope” 
$rgName = “TestRG02”

# Crear Resource group 
New-AzureRmResourceGroup -Name $rgName -Location $locName

# Comprobar que el nombre que se va a poner al Storage Account es único 
$stName = “sastddemoibdiag”

# Crear cuenta de Almacenamiento para boot diagnostics
$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $stName -SkuName “Standard_LRS” -Kind "Storage” -Location $locName

# Crear subred FrontEnd1 
$subnetName = “FrontEnd1”
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 192.168.1.0/24

# Crear la red virtual y asociar la subred 
$vnetName = “TestVNet02”
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $locName -AddressPrefix 192.168.0.0/16 -Subnet $singleSubnet 

# Crear IP Pública 
$ipName = "IPPublic02"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic

# Crear interfaz de red 
$nicName = “ethernet01”
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id 

# Establecer usuario y contraseña administrador del equipo 
$cred = Get-Credential -Message “Escribir el nombre del usuario administrador del equipo”

# Crear nombre y configuración de la VM 
$vmName = “VMtest01” 
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize “Standard_A1”

# Definir la imagen que se usará para la VM (imágenes disponibles) 
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus  2016-Datacenter-smalldisk -Version "latest" 

# Agregar interfaz de red 
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id 

# Definir configuración para el SO 
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

# Escribir nombre de disco y agregar información a la configuración
$diskName = “VMtest01-SO” 
$diskSize = “70"
$diskaccountType = “Standard_LRS”
$vm = Set-AzureRmVMOSDisk -CreateOption fromImage -VM $vm -DiskSizeInGB $diskSize -Name $diskName -StorageAccountType $diskaccountType -Windows

# Por último, crear la VM 
New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm