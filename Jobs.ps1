$AAN = "Automatizacion-VMs-PRO"
$RN = "AUTO_START_VM_NameValue"
$RG = "GR_WEBSERVICES_SP"

$job = (Get-AzureRmAutomationJob –AutomationAccountName $AAN –RunbookName $RN -ResourceGroupName $RG | sort LastModifiedDate –desc)[0]
$job.Status
$job.JobParameters
Get-AzureRmAutomationJobOutput -ResourceGroupName $RG –AutomationAccountName $AAN -Id $job.JobId –Stream Output > C:\Users\javier.gonzalez\Desktop\AAPro.csv