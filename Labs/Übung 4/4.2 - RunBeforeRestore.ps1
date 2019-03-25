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

#region Variables
    #Network relevant settings
    #$BackupRG = "ACDMY-VMBackup"
    #$Location = "West Europe"

    $VMName = "VMOne"
    $restoreSAName = $([string]$($VMName+"recoverysa{0:D4}" -f (Get-Random -Maximum 9999)).ToLower())
#endregion 

#Resource Group Selector
$BackupRG = Get-AzResourceGroup | Out-GridView -PassThru -Title "Select Your Backup Resource Group."

#Create storageaccount for the staging 
New-AzStorageAccount -Name $restoreSAName -ResourceGroupName $BackupRG.ResourceGroupName -SkuName Standard_LRS -Location $BackupRG.Location -Kind StorageV2