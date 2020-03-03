Install-Module MSOnline

#specify credentials for azure ad connect
$Msolcred = Get-credential
#connect to azure ad
Connect-MsolService -Credential $MsolCred
 
#disable AD Connect / Dir Sync
Set-MsolDirSyncEnabled –EnableDirSync $false
 
#confirm AD Connect / Dir Sync disabled
(Get-MSOLCompanyInformation).DirectorySynchronizationEnabled
 

#If you choose to re-enable the AD Connect, just change the flag to TRUE.
#Set-MsolDirSyncEnabled –EnableDirSync $true
 
 Get-MsolUser | Out-GridView -OutputMode Multiple | Remove-MsolUser -Force 