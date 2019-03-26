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

#run this to copy some examples from help to the clipboard
help New-AzVm -Examples | clip

#Do a STRG-V below here
#Take the code for Example 3 and delete the rest. Remove some line brakes to make the code work and run...