<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        ...................

    ***************************************
    This script will 

    see: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-quickstart-create-templates-use-visual-studio-code?tabs=CLI

    by: bfrank
    version: 1.0.0.0
#>

#region variables
$ARMRG = "ACDMY-ARM"
$Location = "North Europe"
#endregion

<# Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

New-AZResourceGroup -Name $ARMRG -Location $Location

#copy URI of sample template to clipboard
"https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-storage-account-create/azuredeploy.json" | clip

<#Do:
VSCODE -> File -> Open File -> Press 'STRG-V'
Save file as "sa.json" in Folder
#>

#Deploy the template with a parameter filled
$TemplateParameters = @{
"storageAccountType" = [string]"Standard_GRS";   #Geo redundant store
}

#Deploy template to Azure
New-AZResourceGroupDeployment -TemplateFile ".\sa.json" -Name "SAwithParam" -ResourceGroupName $ARMRG -TemplateParameterObject $TemplateParameters #-Mode Incremental

#cleanup
#Remove-AZResourceGroup -Name $ARMRG -Force -AsJob