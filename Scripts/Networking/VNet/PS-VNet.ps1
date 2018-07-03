# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear Grupo de recursos 
New-AzureRmResourceGroup -Name TestRG -Location westeurope 

# Crear Vnet TestVNet 
New-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet -AddressPrefix 192.168.0.0/16 -Location westeurope 

# Almacenar el objeto de red virtual en una variable
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet 

# Agregar la red frontend a la variable de red virtual 
Add-AzureRmVirtualNetworkSubnetConfig -Name FrontEnd -VirtualNetwork $vnet -AddressPrefix 192.168.1.0/24 

# Agregar la red backend a la variable de red virtual 
Add-AzureRmVirtualNetworkSubnetConfig -Name BackEnd -VirtualNetwork $vnet -AddressPrefix 192.168.2.0/24 

# Guardar los datos creados 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Eliminar grupo de recursos con dependencias
Remove-AzureRmResourceGroup -Name TestRG