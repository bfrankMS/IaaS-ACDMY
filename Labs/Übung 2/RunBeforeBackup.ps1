<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Run before Backup 

    ***************************************
    This script will create execute the contents of $code within the Azure VM
    in our write a timestamp to a file just before backup


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

#create a unique file name
$tempFile = $env:TEMP + "\AzVMRunCommand"+ $("{0:D4}" -f (Get-Random -Maximum 9999))+".tmp.ps1"
$code = @"
    mkdir c:\temp
    get-date | out-file c:\temp\rundate.txt -append
    dir c:\temp
"@

$code | Out-File $tempFile    #write this Powershell code into a local file 

#VM selector
$vm = Get-AzVM | Out-GridView -OutputMode Single -Title "Select target VM."

#invoke a local Powershell script to be run within an azure VM
Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -CommandId 'RunPowerShellScript' -ScriptPath $tempFile #-Parameter @{"arg1" = "var1";"arg2" = "var2"}
Remove-Item $tempFile -Force