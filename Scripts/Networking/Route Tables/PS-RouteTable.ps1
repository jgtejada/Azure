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