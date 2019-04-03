<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Azure Automation

    ***************************************
    This script will create an Azure Automation Account

    see: https://docs.microsoft.com/en-us/azure/automation/manage-runbooks

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
    $AutomationRG = "ACDMY-AAutomation"
    $Location = "West Europe"

    $AutomationAccountName = "myAutomationAccount"
#endregion

#Create the RG and the Azure Automation Account
New-AzResourceGroup -Name $AutomationRG -Location $Location
#New-AzAutomationAccount -Name $AutomationAccountName -Location $Location -ResourceGroupName $AutomationRG    
