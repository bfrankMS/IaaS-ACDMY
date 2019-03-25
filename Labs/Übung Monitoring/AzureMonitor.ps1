<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        ...................

    ***************************************
    This script will 

    see: 

    by: bfrank
    version: 1.0.0.0
#>

<#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

#region variables
    $BackupRG = "ACDMY-..."
    $Location = "West Europe"
   
    $VMName = "VMOne"
#endregion