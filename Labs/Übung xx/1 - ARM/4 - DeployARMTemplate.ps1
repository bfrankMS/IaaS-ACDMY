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
1) VSCODE -> File -> Open File -> Press 'STRG-V'
Save file as "sa.json" in Folder

2) Open 'sa.json' with VSCode. 
ollapse view with 'Hold STRG press K then 0'

3) expand -> resources , parameters, outputs...

4) add below to output section 
"storageUri": {
  "type": "string",
  "value": "[reference(variables('storageAccountName')).primaryEndpoints.blob]"
}
#>

#Deploy template to Azure
New-AZResourceGroupDeployment -TemplateFile ".\sa.json" -ResourceGroupName $ARMRG 

#can you see the StorageURI in Terminal output?

#cleanup
#Remove-AZResourceGroup -Name $ARMRG -Force -AsJob