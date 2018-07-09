# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Crear Grupo de recursos 
New-AzureRmResourceGroup -Name TestRG -Location westeurope

# Asignar tags a VM
$tags = @{Propietario="SoftwareONE";Centro_Coste="Desarrollo"}
Set-AzureRmResource -ResourceGroupName $ResourceGroupName -Name $VMNameRT -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -Force