<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Run before Restore 

    ***************************************
    This script will create a storage account 'recoverVMxxxx' that can be used during VM


    see: https://docs.microsoft.com/en-us/azure/backup/quick-backup-vm-powershell

    by: bfrank
    version: 1.0.0.0
#>

<#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

#region Variables
    $VMName = "VMOne"
    $restoreSAName = $([string]$($VMName+"recoverysa{0:D4}" -f (Get-Random -Maximum 9999)).ToLower())
#endregion 

#Resource Group Selector
$BackupRG = Get-AzResourceGroup | Out-GridView -PassThru -Title "Select Your Backup Resource Group."

$vm = Get-AzVM -Name $VMName

#Create storageaccount for the staging 
New-AzStorageAccount -Name $restoreSAName -ResourceGroupName $BackupRG.ResourceGroupName -SkuName Standard_LRS -Location $vm.Location -Kind StorageV2