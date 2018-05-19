## Global Variables
$ResourceGroupName = "XXX"
$ResourceGroupLocation = "West Europe"


## Network Variables
$VNetName   = "XXX"
$AddressPrefixVNet = "172.31.0.0/20"
$SubnetName = "XXX"
$AddressPrefixSubnet = "172.31.1.0/24"
$VNetResourceGroupName = "XXX"
$PrivateIpAddressRT = "172.30.1.16"


## Image publisher
$imagePublisher  = "credativ"
$imageOffer      = "Debian"
$VersionOSSku    = "9"
$VMSize          = "Standard_B2s"


## Compute Variables
$VMNameRT = "XXX"
$OSDiskNameRT = ($VMNameRT.ToLower()+'-OS')
$diskSize = "30"
$diskaccountType = "StandardLRS"
$VMResourceGroupNameRT = $ResourceGroupName
$NICNameRT = $VMNameRT + "-PrimaryNIC"
$PIPNameRT = $VMNameRT + "-PIP"


## Storage variables
$RGSADiag = "XXX"
$StorageAccountDiag = "XXX"
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
$VNet = Get-AzureRmVirtualNetwork -ResourceGroupName $VNetResourceGroupName -Name $VNetName -ErrorAction SilentlyContinue
if(!$VNet)
{
    Write-Host "VNet '$VNetName' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating VNet '$VNetName' in location '$resourceGroupLocation'" -ForegroundColor Green;
    New-AzureRmVirtualNetwork -ResourceGroupName $VNetResourceGroupName -Name $SubnetName -Location $resourceGroupLocation -AddressPrefix $AddressPrefixVNet
}
else{
    Write-Host "Using existing VNet '$VNetName'" -ForegroundColor Cyan;
}

## Create or check for existing Subnet
$Subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet -ErrorAction SilentlyContinue
if(!$VNet)
{
    Write-Host "Sunet '$VNetName' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating Subnet '$SubnetName' in location '$resourceGroupLocation'" -ForegroundColor Green;
    Add-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $AddressPrefixSubnet -VirtualNetwork $VNet
}
else{
    Write-Host "Using existing Subnet '$SubnetName'" -ForegroundColor Cyan;
}

## Network Script
$VNet   = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $VNetResourceGroupName
$Subnet = Get-AzureRMVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet
$GetPIPRT    = Get-AzureRmPublicIPAddress -Name $PIPNameRT -ResourceGroupName $ResourceGroupName

## Create the Interface
$IPconfigRT    = New-AzureRmNetworkInterfaceIpConfig -Name $VMNameRT -PrivateIpAddressVersion IPv4 -PrivateIpAddress $PrivateIpAddressRT -SubnetId $Subnet.Id #-PublicIpAddressId $GetPIPRT.Id -Primary
$InterfaceRT   = New-AzureRmNetworkInterface -Name $NICNameRT -ResourceGroupName $ResourceGroupName -Location $ResourceGroupLocation -IpConfiguration $IPconfigRT

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


## Create a public IP address
$pip         = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName  -Location $ResourceGroupLocation -AllocationMethod Dynamic -Name $PIPNameRT
$GetPIPRT    = Get-AzureRmPublicIPAddress -Name $PIPNameRT -ResourceGroupName $ResourceGroupName

## Create a virtual network card and associate with public IP address
$IPconfigRT    = New-AzureRmNetworkInterfaceIpConfig -Name $VMNameRT -PrivateIpAddressVersion IPv4 -PrivateIpAddress $PrivateIpAddressRT -SubnetId $Subnet.Id -PublicIpAddressId $GetPIPRT.Id -Primary
$InterfaceRT   = New-AzureRmNetworkInterface -Name $NICNameRT -ResourceGroupName $ResourceGroupName -Location $ResourceGroupLocation -IpConfiguration $IPconfigRT

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
$tags = @{PROPIETARIO="Tajmar";CENTRO_COSTE="Infraestructura"}
Set-AzureRmResource -ResourceGroupName $ResourceGroupName -Name $VMNameRT -ResourceType "Microsoft.Compute/VirtualMachines" -Tag $tags -Force


## Enable BootDiagnostics
$VM = Get-AzureRmVM -DisplayHint Expand -ResourceGroupName $ResourceGroupName -Name $VMNameRT
Set-AzureRmVMBootDiagnostics -VM $VM -Enable -ResourceGroupName $RGSADiag -StorageAccountName $StorageAccountDiag
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $VM

## Clear variables
Remove-Variable * -ErrorAction SilentlyContinue
