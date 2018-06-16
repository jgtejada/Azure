﻿## Global Variables
$ResourceGroupName = "RG-TEST-LINUX"
$ResourceGroupLocation = "West Europe"

## Network Variables
$VNetName   = "VNET_LINUX"
$AddressPrefixVNet = "172.31.0.0/20"
$SubnetName = "Subred_Linux"
$AddressPrefixSubnet = "172.31.1.0/24"
$VNetResourceGroupName = $ResourceGroupName
$PrivateIpAddressRT = "172.31.1.5"

## Image publisher
$imagePublisher  = "credativ"
$imageOffer      = "Debian"
$VersionOSSku    = "9"
$VMSize          = "Standard_B1ms"

## Compute Variables
$VMNameRT = "VM-TEST-LINUX"
$OSDiskNameRT = $VMNameRT +'-OS'
$diskSize = "30"
$diskaccountType = "StandardLRS"
$VMResourceGroupNameRT = $ResourceGroupName
$NICNameRT = $VMNameRT + "-PrimaryNIC"
$PIPNameRT = $VMNameRT + "-PIP"
$NSGName = $VMNameRT + "-NSG"
$NSGRuleName = "SSH"
$DNSNameRT = "vmtestlnx"

## Storage variables
$RGSADiag = $ResourceGroupName
$StorageAccountDiag = "sastdtestlnx"
$Type = "Standard_LRS"



## Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'" -ForegroundColor Green;
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'" -ForegroundColor Cyan;
}


## Create or check for existing VNet
$VNet = Get-AzureRmVirtualNetwork -ResourceGroupName $VNetResourceGroupName -Name $ResourceGroupName -ErrorAction SilentlyContinue
if(!$VNet)
{
    Write-Host "VNet '$VNetName' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating VNet '$VNetName' in location '$resourceGroupLocation'" -ForegroundColor Green;
    New-AzureRmVirtualNetwork -ResourceGroupName $VNetResourceGroupName -Name $VNetName -Location $resourceGroupLocation -AddressPrefix $AddressPrefixVNet
}
else{
    Write-Host "Using existing VNet '$VNetName'" -ForegroundColor Cyan;
}

## Create Subnet
$GetVNet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName
Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $GetVNet -AddressPrefix $AddressPrefixSubnet
Set-AzureRmVirtualNetwork -VirtualNetwork $GetVNet

## Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName  -Location $resourceGroupLocation -AllocationMethod Static -DomainNameLabel $DNSNameRT -Name $PIPNameRT

# Create an inbound network security group rule for port 22
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name $NSGRuleName  -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $resourceGroupLocation -Name $NSGName -SecurityRules $nsgRuleRDP

# Network Script
$Subnet      = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $GetVNet
$GetPIPRT    = Get-AzureRmPublicIPAddress -Name $PIPNameRT -ResourceGroupName $ResourceGroupName


# Create a virtual network card and associate with public IP address and NSG
$IPconfigRT    = New-AzureRmNetworkInterfaceIpConfig -Name $VMNameRT -PrivateIpAddressVersion IPv4 -PrivateIpAddress $PrivateIpAddressRT -SubnetId "/subscriptions/0d893838-7933-413c-8ffe-e1adcfdd47a1/resourceGroups/RG-TEST-LINUX/providers/Microsoft.Network/virtualNetworks/VNET_LINUX/subnets/Subred_Linux" -PublicIpAddressId $GetPIPRT.Id
$InterfaceRT   = New-AzureRmNetworkInterface -Name $NICNameRT -ResourceGroupName $ResourceGroupName -Location $ResourceGroupLocation -IpConfiguration $IPconfigRT
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICNameRT
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName
$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzureRmNetworkInterface

## Create or check for existing storage account for diagnostics
$storageaccount = Get-AzureRmStorageAccount -ResourceGroupName $RGSADiag -Name $StorageAccountDiag -ErrorAction SilentlyContinue
if(!$storageaccount)
{
    Write-Host "Storage account for diagnostics '$StorageAccountDiag' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating storage account '$StorageAccountDiag' in location '$resourceGroupLocation'" -ForegroundColor Green;
    New-AzureRmStorageAccount -ResourceGroupName $RGSADiag -AccountName $StorageAccountDiag -Type $Type -Location $resourceGroupLocation

}
else{
    Write-Host "Using existing storage account '$StorageAccountDiag'" -ForegroundColor Cyan;
}


# Create Credentials
$cred            = Get-Credential -Message "Introduce el nombre del usuario y la contraseña"

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $VMNameRT -VMSize $VMSize

$vmConfig = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $InterfaceRT.Id

$vmConfig = Set-AzureRmVMSourceImage -VM $vmConfig -PublisherName $imagePublisher -Offer $imageOffer -Skus $VersionOSSku -Version latest

$vmConfig = Set-AzureRmVMOperatingSystem -VM $vmConfig -Linux -ComputerName $VMNameRT -Credential $cred

$vmConfig = Set-AzureRmVMOSDisk -CreateOption fromImage -VM $vmConfig -DiskSizeInGB $diskSize -Name $OSDiskNameRT -StorageAccountType $diskaccountType -Linux

# Create the virtual machine
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $ResourceGroupLocation -VM $vmConfig -Verbose


## Add tags
$tags = @{PROPIETARIO="Tajamar";CENTRO_COSTE="MCSE"}
Set-AzureRmResource -ResourceGroupName $ResourceGroupName -Name $VMNameRT -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -Force


## Change BootDiagnostics
$VM = Get-AzureRmVM -DisplayHint Expand -ResourceGroupName $ResourceGroupName -Name $VMNameRT
Set-AzureRmVMBootDiagnostics -VM $VM -Enable -ResourceGroupName $RGSADiag -StorageAccountName $StorageAccountDiag
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $VM


#Clear variables
Remove-Variable * -ErrorAction SilentlyContinue