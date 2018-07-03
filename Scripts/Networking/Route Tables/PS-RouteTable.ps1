# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear una ruta que se use para enviar todo el tráfico destinado a la subred de back-end (192.168.2.0/24) para enrutarse a FW1 (192.168.0.4) 
$route = New-AzureRmRouteConfig -Name RouteToBackEnd -AddressPrefix 192.168.2.0/24 -NextHopType VirtualAppliance -NextHopIpAddress 192.168.0.4

# Crear una tabla de ruta llamada UDR-FrontEnd en la región West Europe que contenga la ruta creada anteriormente 
$routeTable = New-AzureRmRouteTable -ResourceGroupName TestRG -Location westeurope -Name UDR-FrontEnd -Route $route

# Crear una variable que contenga la red virtual donde está la subred. En nuestro ejemplo, la red virtual se llama TestVNet 
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName TestRG -Name TestVNet

# Asociar la tabla de ruta creada anteriormente a la subred FrontEnd 
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name FrontEnd -AddressPrefix 192.168.1.0/24 -RouteTable $routeTable 

# Guardar la nueva configuración 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Crear una ruta que se use para enviar todo el tráfico destinado a la subred de front-end (192.168.1.0/24) para enrutarse a FW1 (192.168.0.4) 
$route = New-AzureRmRouteConfig -Name RouteToFrontEnd -AddressPrefix 192.168.1.0/24 -NextHopType VirtualAppliance -NextHopIpAddress 192.168.0.4

# Crear una tabla de ruta llamada UDR-BackEnd en la región uswest que contenga la ruta creada anteriormente. 
$routeTable = New-AzureRmRouteTable -ResourceGroupName TestRG -Location westeurope -Name UDR-BackEnd -Route $route

# Asociar la tabla de ruta creada anteriormente a la subred BackEnd 
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name BackEnd -AddressPrefix 192.168.2.0/24 -RouteTable $routeTable

# Guardar la nueva configuración de subred de Azure 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

# Crear NIC
$IPconfig = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "192.168.1.5" -SubnetId "/subscriptions/0d893838-7933-413c-8ffe-e1adcfdd47a1/resourceGroups/TestRG/providers/Microsoft.Network/virtualNetworks/TestVNet/subnets/FrontEnd"
New-AzureRmNetworkInterface -Name "NetworkInterface1" -ResourceGroupName TestRG -Location westeurope -IpConfiguration $IPconfig

# Habilitar el reenvío IP en FW1 
# Crear una variable que contenga la configuración de la NIC usada por FW1. En nuestro escenario, la NIC se llama “NetworkInterface1” 
$nicfw1 = Get-AzureRmNetworkInterface -ResourceGroupName TestRG -Name NetworkInterface1

#Habilitar el reenvío IP y guarde la configuración de NIC 
$nicfw1.EnableIPForwarding = 1 
Set-AzureRmNetworkInterface -NetworkInterface $nicfw1