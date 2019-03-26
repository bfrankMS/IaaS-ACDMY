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
    $VMSimpleRG = "ACDMY-VMSimple"
    $Location = "North Europe"       #to save some costs ;-)
   
    $VMName = "VMSimple"
#endregion

New-AzResourceGroup -Name $VMSimpleRG -Location $Location

#a new VM is as simple as that! 
New-AzVM -Name $VMName -Credential (Get-Credential) -ResourceGroupName $VMSimpleRG

#Really? What is missing?

#cleanup
Read-Host -Prompt 'Press any key to delete Resource Group!'
Remove-AzResourceGroup -Name $VMSimpleRG -Force -AsJob
