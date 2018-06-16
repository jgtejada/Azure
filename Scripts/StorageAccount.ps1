## Storage variables
$RGSA = $ResourceGroupName
$StorageAccountFile = "sastdtestflshr"
$Type = "Standard_LRS"

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

# Create directiory
$DirectoryName = "myDirectory"
New-AzureStorageDirectory -Context $ctx -ShareName $FileName -Path $DirectoryName

# This expression will put the current date and time into a new file on your scratch drive
Get-Date | Out-File -FilePath "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Test.txt" -Force

# this expression will upload that newly created file to your Azure file share
$SourceFile = "C:\Users\javier.gonzalez\OneDrive - SoftwareONE\Test.txt"
$PathShare = "myDirectory\Test.txt"
Set-AzureStorageFileContent -Context $ctx -ShareName $FileName -Source $SourceFile -Path $PathShare

Get-AzureStorageFile -Context $ctx -ShareName $FileName -Path $DirectoryName

# Delete an existing file by the same name as SampleDownload.txt, if it exists because you've run this example before.
$PathTarget = "C:\Users\javier.gonzalez\Desktop\Test.txt"
Remove-Item -Path $PathTarget -Force -ErrorAction SilentlyContinue
Get-AzureStorageFileContent -Context $ctx -ShareName $FileName -Path $PathShare -Destination $PathTarget