# Logarse en la suscripción desde una ventana de PowerShell
Connect-AzAccount

# Comprobar suscripciones del usuario
Get-AzSubscription

# Seleccionar subscripción
Get-AzSubscription –SubscriptionName “Acceso a Azure Active Directory(Converted to EA)”  | Select-AzSubscription

# Crear Grupo de recursos 
New-AzResourceGroup -Name RG-VNET -Location westeurope

# Crear Vnet TestVNet 
New-AzVirtualNetwork -ResourceGroupName RG-VNET -Name TestVNet01 -AddressPrefix 192.169.0.0/16 -Location westeurope

# Almacenar el objeto de red virtual en una variable
$vnet = Get-AzVirtualNetwork -ResourceGroupName RG-VNET -Name TestVNet01

# Agregar la red frontend a la variable de red virtual 
Add-AzVirtualNetworkSubnetConfig -Name FrontEnd -VirtualNetwork $vnet -AddressPrefix 192.169.1.0/24

# Agregar la red backend a la variable de red virtual 
Add-AzVirtualNetworkSubnetConfig -Name BackEnd -VirtualNetwork $vnet -AddressPrefix 192.169.2.0/24

# Guardar los datos creados 
Set-AzVirtualNetwork -VirtualNetwork $vnet

# Eliminar grupo de recursos con dependencias
Remove-AzResourceGroup -Name TestRG01 -Force