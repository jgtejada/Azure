# Logarse en la suscripción desde una ventana de PowerShell
Login-AzureRmAccount

# Comprobar suscripciones del usuario
Get-AzureRmSubscription

# Seleccionar subscripción
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription

# Añadir bloqueo "CanNotDelete" a la VM
New-AzureRmResourceLock -LockLevel CanNotDelete -LockName LockVMPS -ResourceName (VMName) -ResourceType Microsoft.Compute/virtualMachines -ResourceGroupName (GRName)

# Eliminar el blqoueo
$lockId = (Get-AzureRmResourceLock -ResourceGroupName GR-Name -ResourceName VMName -ResourceType Microsoft.Compute/virtualMachines).LockId
Remove-AzureRmResourceLock -LockId $lockId