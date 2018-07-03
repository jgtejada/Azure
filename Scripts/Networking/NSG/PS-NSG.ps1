# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear Grupo de recursos 
New-AzureRmResourceGroup -Name TestRG -Location westeurope

## Crear NSG para red FrontEnd 
# Permitir acceso desde internet al puerto 3389 
$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 250 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

# Permitir acceso desde internet al puerto 80 
$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Allow HTTP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 200 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 

# Agregar las reglas creadas a un nuevo grupo de seguridad NSG-FrontEnd 
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName TestRG -Location westeurope -Name "NSG-FrontEnd" -SecurityRules $rule1,$rule2 

# Asociar NSG-FrontEnd a la subred FrontEnd 
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet 
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name FrontEnd -AddressPrefix 192.168.1.0/24 -NetworkSecurityGroup $nsg 

# Guardar la configuración en la virtual network de Azure 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

## Crear NSG para red FrontEnd
# Permitir acceso desde la subred FrontEnd al puerto 1433
$rule3 = New-AzureRmNetworkSecurityRuleConfig -Name frontend-rule -Description "Allow FE subnet" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix 192.168.1.0/24 -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433 

# Bloquer el acceso a internet 
$rule4 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "Block Internet" -Access Deny -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix Internet -DestinationPortRange * 

# Agregar las reglas creadas a un nuevo grupo de seguridad NSG-BackEnd 
$nsg1 = New-AzureRmNetworkSecurityGroup -ResourceGroupName TestRG -Location westeurope -Name "NSG-BackEnd" -SecurityRules $rule3,$rule4 

# Asociar NSG-BackEnd a la subred BackEnd 
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name BackEnd -AddressPrefix 192.168.2.0/24 -NetworkSecurityGroup $nsg1 

# Guardar la configuración en la virtual network de Azure 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet