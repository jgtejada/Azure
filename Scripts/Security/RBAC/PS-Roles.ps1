# Logarse en la suscripción desde una ventana de PowerShell 
Login-AzureRmAccount

# Seleccionar subscripción 
Get-AzureRmSubscription # Comprobar suscripciones del usuario
Get-AzureRmSubscription –SubscriptionName “Pase para Azure” | Select-AzureRmSubscription # seleccionar suscripción

# Lista roles disponibles en la suscripción
Get-AzureRmRoleDefinition | FT Name, IsCustom

# Lista de roles customizados en la suscripción
Get-AzureRmRoleDefinition | ? {$_.IsCustom -eq $true} | FT Name, IsCustom

# Crear role customizado a partir del rol "Virtual Machine Contributor"
$role = Get-AzureRmRoleDefinition "Virtual Machine Contributor"
$role.Id = $null
$role.Name = "Virtual Machine Operator Custom"
$role.Description = "Can monitor and restart virtual machines."
$role.Actions.Clear()
$role.Actions.Add("Microsoft.Storage/*/read")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Resources/subscriptions/resourceGroups/read")
$role.Actions.Add("Microsoft.Insights/alertRules/*")
$role.Actions.Add("Microsoft.Support/*")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/0d893838-7933-413c-8ffe-e1adcfdd47a1")
New-AzureRmRoleDefinition -Role $role

# Lista roles disponibles en la suscripción
Get-AzureRmRoleDefinition | FT Name, IsCustom

# Lista de roles customizados en la suscripción
Get-AzureRmRoleDefinition | ? {$_.IsCustom -eq $true} | FT Name, IsCustom

# Asignar rol a un usuario
New-AzureRmRoleAssignment -SignInName <email of user> -RoleDefinitionName $role.Name -ResourceGroupName JSON