<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        ...................

    ***************************************
    This script will 

    see: https://docs.microsoft.com/en-us/azure/cost-management/tutorial-export-acm-data

    by: bfrank
    version: 1.0.0.0
#>

<#Login to Azure#>
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Set-AzContext


#region variables
    $CostsRG = "ACDMY-Costs"
    $Location = "West Europe"
   
    #some random storage account name
    $costsSAName = $([string]$("sa4costs{0:D4}" -f (Get-Random -Maximum 9999)).ToLower())
    $containerName = "costs"
#endregion

#for clarity we create a separate RG
New-AzResourceGroup -Name $CostsRG -Location $Location

#We need a storage account to hold the daily costs export CSV
New-AzStorageAccount -Name $costsSAName -ResourceGroupName $CostsRG -SkuName Standard_LRS -Location $Location -Kind StorageV2 -AccessTier Cool

#a container
New-AzRmStorageContainer -Name $containerName -ResourceGroupName $CostsRG -StorageAccountName $costsSAName

