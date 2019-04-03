<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Create the VM Backup

    ***************************************
    This script will create 


    see: https://docs.microsoft.com/en-us/azure/backup/quick-backup-vm-powershell

    by: bfrank
    version: 1.0.0.0
#>

#region Variables
    $BackupRG = "ACDMY-VMBackup"
    $Location = "West Europe"
   
    $VMName = "VMOne"
    $vaultName ="$VMName-Vault" 
    $VMBackupPoliyName = "$VMName-BkUpPolicy"
    
#endregion


#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription

#Create the Network Resource Group
New-AzResourceGroup -Name $BackupRG -Location $Location

#First time you use Azure Backup with PowerShell?...
Register-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"

#Create a Recovery Services vault ... restore points will land in this 'container'
$Error.Clear()
New-AzRecoveryServicesVault -ResourceGroupName $BackupRG -Name $vaultName -Location $Location
if ($Error)   #in case we need a more complex vaultname
{
    $vaultName = $([string]$($vaultName+"{0:D4}" -f (Get-Random -Maximum 9999)).ToLower())
    New-AzRecoveryServicesVault -ResourceGroupName $BackupRG -Name $vaultName -Location $Location
}


#Get the vault
$vault = Get-AzRecoveryServicesVault -Name $vaultName 
#Note: Don'T use "Set-AzRecoveryServicesVaultContext" ..."The cmdlet is being deprecated. There will be no replacement for it."

#Enable backup for an Azure VM
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy" -VaultId $vault.ID

    #want to define a different schedule & retention policy?
    <#  
$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"

$schPol.ScheduleRunFrequency = 'Daily'

$todays  = Get-Date
$var = [System.DateTime]::new($todays.Year,$todays.Month,$todays.Day,21,00,00,[System.DateTimeKind]::Utc)
$SchPol.ScheduleRunTimes.RemoveRange(0,$SchPol.ScheduleRunTimes.Count)
$schPol.ScheduleRunTimes.Add($var)
$retPol.DailySchedule.DurationCountInDays     = 365   # x days of daily backups will be kept
$retPol.MonthlySchedule.DurationCountInMonths = 24    # x monthly backups will be kept
$retPol.WeeklySchedule.DurationCountInWeeks   = 52    #
$retPol.YearlySchedule.DurationCountInYears   = 3     # 

New-AzRecoveryServicesBackupProtectionPolicy -Name "$VMBackupPoliyName" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol
#>
    
$vm = Get-AzVM | Out-GridView -OutputMode Single -Title "Select Your VM For Backup"
Enable-AzRecoveryServicesBackupProtection -Name $vm.Name -VaultId $vault.ID -Policy $policy -ResourceGroupName $vm.ResourceGroupName

#Start a backupjob
$backupcontainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName $vm.Name

$item = Get-AzRecoveryServicesBackupItem -Container $backupcontainer -WorkloadType "AzureVM"

Backup-AzRecoveryServicesBackupItem -Item $item

#Monitor the backup job
Get-AzRecoveryservicesBackupJob -VaultId $vault.ID -Verbose | ft Operation,WorkloadName, Status, StartTime,Endtime,Duration,JobId -AutoSize

<#Cleanup
Disable-AzRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints
$vault = Get-AzRecoveryServicesVault -Name $vaultName
Remove-AzRecoveryServicesVault -Vault $vault
Remove-AzResourceGroup -Name $BackupRG

#>