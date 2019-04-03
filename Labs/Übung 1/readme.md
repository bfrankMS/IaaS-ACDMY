# PowerShell Module für Azure installieren und eine VM damit erstellen #

* [1. PowerShell Az Module für Azure installieren ](#1)
* [2. Erste Schritte ...](#2)
* [3. VM mit PowerShell erstellen](#3)

## 1
## PowerShell Az Module für Azure installieren
PowerShell starten und folgenden Befehl ausführen: 
```
Install-Module Az
```

Mit 'Y' die installation des Nuget Providers erlauben:
```
NuGet provider is required to continue
PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact with NuGet-based repositories. The NuGet
 provider must be available in 'C:\Program Files\PackageManagement\ProviderAssemblies' or
'C:\Users\Administrator\AppData\Local\PackageManagement\ProviderAssemblies'. You can also install the NuGet provider by
 running 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force'. Do you want PowerShellGet to install
and import the NuGet provider now?
[Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y
```
Und mit 'A' der PowerShell Gallery als Code-Quelle vertrauen:
```
Untrusted repository
You are installing the modules from an untrusted repository. If you trust this repository, change its
InstallationPolicy value by running the Set-PSRepository cmdlet. Are you sure you want to install the modules from
'PSGallery'?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "N"): a
```
Die installation der PowerShell Module kann etwas dauern. Die installierten Module lassen sich mit dem Befehl:
```
get-module Az* -ListAvailable

```
anzeigen:
```
    Directory: C:\Program Files\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.4.0      Az.Accounts                         {Disable-AzDataCollection, Disable-AzContextAutosave, Enab...
Script     1.0.1      Az.Aks                              {Get-AzAks, New-AzAks, Remove-AzAks, Import-AzAksCredentia...
Script     1.0.2      Az.AnalysisServices                 {Resume-AzAnalysisServicesServer, Suspend-AzAnalysisServic...
Script     1.0.0      Az.ApiManagement                    {Add-AzApiManagementRegion, Get-AzApiManagementSsoToken, N...
Script     1.0.0      Az.ApplicationInsights              {Get-AzApplicationInsights, New-AzApplicationInsights, Rem...
Script     1.2.0      Az.Automation                       {Get-AzAutomationHybridWorkerGroup, Remove-AzAutomationHyb...
Script     1.0.0      Az.Batch                            {Remove-AzBatchAccount, Get-AzBatchAccount, Get-AzBatchAcc...
Script     1.0.0      Az.Billing                          {Get-AzBillingInvoice, Get-AzBillingPeriod, Get-AzEnrollme...
Script     1.1.0      Az.Cdn                              {Get-AzCdnProfile, Get-AzCdnProfileSsoUrl, New-AzCdnProfil...
Script     1.0.1      Az.CognitiveServices                {Get-AzCognitiveServicesAccount, Get-AzCognitiveServicesAc...
Script     1.6.0      Az.Compute                          {Remove-AzAvailabilitySet, Get-AzAvailabilitySet, New-AzAv...
Script     1.0.0      Az.ContainerInstance                {New-AzContainerGroup, Get-AzContainerGroup, Remove-AzCont...
Script     1.0.1      Az.ContainerRegistry                {New-AzContainerRegistry, Get-AzContainerRegistry, Update-...
.
.
.
```

## 2
## Erste Schritte...
Bei Azure anmelden:
```
Login-AzAccount
```
Die verfügbaren Azure Subscriptions auflisten:
```
Get-AzSubscription

Name                     Id                                   TenantId                             State
----                     --                                   --------                             -----
Azure Pass - Sponsorship 79021c9b-147b-4dc0-ab8c-a3de94905f3f c097c15f-e692-4b72-8f72-490b95209f57 Enabled

```
Eine bestimmte Subscription für die weitere Verarbeitung wählen:
```
Get-AzSubscription | Out-GridView -PassThru | Set-AzContext
```
Die verfügbaren VM-Typen in der Region auflisten lassen:
```
Get-AzVMSize -Location 'west europe'

Name                   NumberOfCores MemoryInMB MaxDataDiskCount OSDiskSizeInMB ResourceDiskSizeInMB
----                   ------------- ---------- ---------------- -------------- --------------------
Standard_A0                        1        768                1        1047552                20480
Standard_A1                        1       1792                2        1047552                71680
Standard_A2                        2       3584                4        1047552               138240
Standard_A3                        4       7168                8        1047552               291840
.
.
.

```
Alle Befehle in dem PowerShell Modul für virtuelle Computer in Azure anzeigen:
```
Get-Command -Module Az.Compute

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           Get-AzVmssDiskEncryptionStatus                     1.6.0      Az.Compute
Alias           Get-AzVmssVMDiskEncryptionStatus                   1.6.0      Az.Compute
Alias           Repair-AzVmssServiceFabricUD                       1.6.0      Az.Compute
Cmdlet          Add-AzContainerServiceAgentPoolProfile             1.6.0      Az.Compute
Cmdlet          Add-AzImageDataDisk                                1.6.0      Az.Compute
Cmdlet          Add-AzVhd                                          1.6.0      Az.Compute
.
.
.
```
Hilfe mit Beispielen zu einem bestimmten Befehl:
```
help New-AzVM -Examples
```
liefert so o.ä.
```
...
SYNOPSIS
    Creates a virtual machine.


    ------------- Example 1: Create a virtual machine -------------

    PS C:\> New-AzVM -Name MyVm -Credential (Get-Credential)
...
```

## 3
## VM mit PowerShell erstellen

Navigieren Sie in der PowerShell in das Verzeichnis mit dem Script 'CreateVMOne.ps1' und starten Sie dieses:
```
PS C:\> cd C:\Labs\
PS C:\Labs> dir

    Directory: C:\Labs

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       03.04.2019     14:18           6779 CreateVMOne.ps1

PS C:\Labs> .\CreateVMOne.ps1
```
Melden Sie sich bei Azure an.  
![Melden Sie sich bei Azure an.](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%201/01-ScriptStartLogin2Azure.png)

Wählen Sie die korrekte Azure Subscription aus.    
![Wählen Sie die korrekte Azure Subscription aus.](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%201/02-SelecSubscription.png)

Nehmen Sie als größe die Standard_DS2_v2:   
![Nehmen Sie als größe die Standard_DS2_v2](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%201/03-VMGroesse.png)

Wählen Sie ein hinreichend komplexes Passwort:    
![Wählen Sie ein hinreichend komplexes Passwort.](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%201/04-VMUser.png)

Warten Sie bis das PowerShell Script fertig ist:  
![Warten Sie bis das PowerShell Script fertig ist](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%201/05-PowerShell%20Job%20erfolgreich.png)