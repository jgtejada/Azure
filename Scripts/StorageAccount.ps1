## RG Variables
$ResourceGroupName = "RG-TEST-STORAGE"
$ResourceGroupLocation = "West Europe"

## Storage variables
$RGSA = $ResourceGroupName
$StorageAccountFile = "sastdtajafile"
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


# Create or check for existing storage account
$storageaccount = Get-AzureRmStorageAccount -ResourceGroupName $RGSA -Name $StorageAccountFile -ErrorAction SilentlyContinue
if(!$storageaccount)
{
    Write-Host "Storage account '$StorageAccountFile' does not exist." -ForegroundColor Yellow;
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating storage account '$StorageAccountFile' in location '$resourceGroupLocation'" -ForegroundColor Green;
    New-AzureRmStorageAccount -ResourceGroupName $RGSA -AccountName $StorageAccountFile -Type $Type -Location $resourceGroupLocation

}
else{
    Write-Host "Using existing storage account '$StorageAccountFile'" -ForegroundColor Cyan;
}


# Create container
$AccountKey    = (Get-AzureRmStorageAccountKey -StorageAccountName $StorageAccountFile -ResourceGroupName $RGSA).Value[0]
$ctx           = New-AzureStorageContext -StorageAccountName $StorageAccountFile -StorageAccountKey $AccountKey
$FileName = "fileshare"
New-AzureStorageShare -Name $FileName -Context $ctx
Set-AzureStorageShareQuota -ShareName $FileName -Quota 1024 -Context $ctx

# Create directiory
$DirectoryName = "Tajamar"
New-AzureStorageDirectory -Context $ctx -ShareName $FileName -Path $DirectoryName

# Put the current date and time into a new file on your scratch drive
Get-Date | Out-File -FilePath "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Test.txt" -Force

# Upload that newly created file to your Azure file share
$SourceFile = "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Test.txt"
$PathShare = "Tajamar\Test.txt"
Set-AzureStorageFileContent -Context $ctx -ShareName $FileName -Source $SourceFile -Path $PathShare

# Delete an existing file by the same name as SampleDownload.txt, if it exists because you've run this example before.
$PathTarget = "C:\Users\javier.gonzalez\Desktop\Test.txt"
Remove-Item -Path $PathTarget -Force -ErrorAction SilentlyContinue
Get-AzureStorageFileContent -Context $ctx -ShareName $FileName -Path $PathShare -Destination $PathTarget

# Connect as a network drive