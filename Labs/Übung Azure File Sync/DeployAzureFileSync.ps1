$resourceGroupName = 'ACDMY-AzureFileSync'
$Location = 'North Europe' 

Login-AzAccount 
Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription

New-AzResourceGroup -Name $resourceGroupName -Location $location

$TemplateParameters = @{
    "StorageSyncServiceName" = [string](Read-Host -Prompt "Name of the Storage Sync Service");
}
 $currentPath = (Get-Location).Path

New-AzResourceGroupDeployment `
 -TemplateFile "$currentPath\AzureFileSync.json" `
 -TemplateParameterObject $TemplateParameters `
 -ResourceGroupName $resourceGroupName #-Debug -Verbose
