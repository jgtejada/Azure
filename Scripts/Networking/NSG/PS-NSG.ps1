# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear Grupo de recursos 
New-AzureRmResourceGroup -Name TestRG -Location westeurope

# Crear NSG para red FrontEnd 
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