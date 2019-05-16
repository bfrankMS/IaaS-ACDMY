Logout-AzAccount
$Credential = [System.Management.Automation.PSCredential]( Get-Credential -Message "Your Azure User")

$login = Login-AzAccount -Credential $Credential

if (!($login)) {break}
$RG = (Get-AzResourceGroup | where ResourceGroupName -Match '[ACDMY]+.*[sync]+.*' | Out-GridView -Title 'Please Select Your File Sync Resource Group' -PassThru).ResourceGroupName
$StorageSyncServiceName = (Get-AzResource -ResourceGroupName $RG -ResourceType Microsoft.StorageSync/storageSyncServices | Out-GridView -Title "Please Select your Storage Sync Service" -PassThru).Name

if (!($StorageSyncServiceName)){break}
#$HostName = ([System.Net.Dns]::GetHostByAddress('172.16.101.12')).HostName
$HostName = $env:COMPUTERNAME.Replace('WWW','RDS')

#run commmand on other server.
Invoke-Command -ComputerName $HostName -ArgumentList $Credential.UserName,$Credential.GetNetworkCredential().Password,$RG,$StorageSyncServiceName -ScriptBlock { 

    Param(
        $UserName,
        $UserPassword,
        $RG,
        $StorageSyncServiceName
    )
    #import the Azure File Sync Powershell module
    Start-Transcript "C:\temp\RegisterOtherServer4AzureFileSync.ps1.log"
    
    Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.PowerShell.Cmdlets.dll"
    #set proxy settings
    Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.ServerCmdlets.dll"
    Set-StorageSyncProxyConfiguration -Address 172.16.101.1 -Port 800 

    #login to azure and file sync
    $Password = ConvertTo-SecureString $UserPassword -AsPlainText -Force 
    $UserCredential = New-Object System.Management.Automation.PSCredential ($UserName, $Password)
    $accountInfo = Connect-AzureRmAccount -Credential $UserCredential 
    
    #register server within sync service
    Login-AzureRMStorageSync -SubscriptionId $accountInfo.Context.Subscription.Id -TenantId $accountInfo.Context.Tenant.Id -ResourceGroupName $RG -Credential $UserCredential
    $registeredServer = Register-AzureRmStorageSyncServer -StorageSyncServiceName $StorageSyncServiceName 
    
    $ServerLocalPath = (get-smbshare -Name shared).Path
    $syncGroupName = (Get-AzureRmStorageSyncGroup -ResourceGroupName $RG -StorageSyncServiceName $StorageSyncServiceName | Select-Object -First 1).Name
    
    # make this server to be an endpoint
    New-AzureRMStorageSyncServerEndpoint `
            -StorageSyncServiceName $StorageSyncServiceName `
            -SyncGroupName $syncGroupName `
            -ServerId $registeredServer.Id `
            -ServerLocalPath $ServerLocalPath `
            -CloudTiering $true `
            -VolumeFreeSpacePercent 20
    Stop-Transcript
}

