# PowerShell Module für Azure installieren und eine VM damit erstellen #

Referenzen:  
[Planning for an Azure Files deployment](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-planning)  
[Planning for an Azure File Sync deployment](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-planning)  
[Deploy Azure File Sync](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-deployment-guide)

Für Azure File Sync brauchen wir:
* [0. (Optional) Bereit für File Sync? Test mit dem Azure File Sync evaluation tool](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-planning#evaluation-tool)
* [1. Storage Sync Service erstellen](#1)
* [2. (**onprem**) Installation des Sync Agents ](#2)
* [3. (**onprem**) Windows Server am Storage Sync Service registrieren](#3)
* [4. Eine Sync Group und einen Cloud Endpoint erstellen](#4)
* [5. Einen Server Endpoint erstellen](#5)
* [6. File Sync testen](#6)


## 1 
## Storage Sync Service erstellen
Die Verwaltung von Azure File Sync passiert in einem Storage Sync Service. **Server** können jeweils **nur bei einem Sync Service registriert werden**.
```
[Azure Portal] -> "+" Create a resource -> 'Azure File Sync'

Name: myFirstStorageSync  
Subscription: z.B. Azure Pass  
Resource Group: -> Create New -> 'ACDMY-AzureFileSync'  
Location: 'North Europe'  
```
## 2
## (**onprem**) Installation des Sync Agents
Der Sync Agent ist ein Stück SW um Dateien auf einem Windows Server in einen Azure file share zu syncen.  
Die SW hat 3 wichtige Komponenten:
* _FileSyncSvc.exe_ - überwacht Änderungen und startet sync.
* _StorageSync.sys_ - Ein Filesystem-Filter, zuständig für das 'Tiering' von Dateien nach Azure Files.
* _PowerShell management cmdlets_ - Um Azure File Sync via PowerShell verwalten zu können (d.h. ist noch nicht Bestandteil der Azure PowerShell-Module).

Installieren Sie den Agent per Doppelklick von _"C:\temp\StorageSyncAgent_V6_WS2019.msi"_ .  
[Offizieller Download Azure File Sync agent](https://go.microsoft.com/fwlink/?linkid=858257)  

```
Next -> Accept Eula -> Next -> Feature selection 'Azure File Sync' -> Next
```

Wichtig: Die richtigen Proxy Einstellungen tätigen:
```
Proxy Settings -> Configure custom proxy settings for Storage Sync Agent  

Host: 172.16.101.1  
Port: 800  

-> Next -> "Use Microsoft Update" ->Agent auto-update....make settings as you wish.
```

## 3 
## (onprem) Windows Server am Storage Sync Service registrieren
Den Anmelde Dialog des Sync Agents mit einem Doppelklick auf:  
```
C:\Program Files\Azure\StorageSyncAgent\ServerRegistration.exe 
```
manuell erzwingen und an Azure anmelden:    
![Azure File Sync - Server Registration](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/registerServer1.PNG)

Nach dem einloggen den Storage Sync Service auswählen:  
![Azure Sync Service registration](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/registerServer2.PNG)  
```
Azure Subscription: z.B. Azure Pass  
Resource Group: 'ACDMY-AzureFileSync'  
Storage Sync Service: 'myFirstStorageSync' 
->Register klicken 
```

Nach erfolgreicher Registrierung sollte der Server im Azure Portal unter:
```
[Azure Portal] -> Resource Groups -> 'ACDMY-AzureFileSync' -> myFirstStorageSync -> Registered Servers
```
auftauchen.  
![Registered Server](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/registerServer4InAzurePortal.PNG)

## 4 
## Eine Sync Group und einen Cloud Endpoint erstellen
Eine **Sync-Gruppe definiert die Sync-Einstellungen** für einen Satz **von Dateien**.  
Sog. **Endpoints** innerhalb einer Synchrongruppe **werden synchron gehalten**.

**Pro Sync-Gruppe gibt es:**
* 1 Cloud Endpoint = 1 Azure File Share  
* X Server Endpoints = X **Ablageorte** (z.B. Dateiordner) **auf** einer Anzahl von **registrierten Servern** (onprem)  

Beim **Anlegen der Sync-Gruppe im Portal wird der Cloud Endpoint gleich mit angelegt**.  
Dieser **Cloud Endpoint** basiert auf einem **Azure File Share welcher vorher vorhanden sein muss**.  

**Daher müssen wir:**
* a) zunächst Storage Account erstellen  
* b) darin einen Azure File Share anlegen.  
```
[Azure Portal] -> '+' Create a resource -> 'Storage Account' -> Create

Resource Group: 'ACDMY-AzureFileSync'
Storage account name: mysyncsa0815   (einzigartig und kleinbuchstaben)
Location: 'North Europe' (muss in derselben Region als der Sync Service sein.)
Performance: Standard
Account kind: Storagev2
Replication: Locally-redundant storage (LRS)
Access tier: Hot

->Next: Advanced -> Next: Tags -> Next: review + create
```
![Storage Account](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/storageAccount1.PNG)

Wenn der Storage Account erstellt wurde dann erzeugen wir einen Azure File Share darin:
```
Resource groups -> ACDMY-AzureFileSync -> mysyncsa....->'Overview' -> Files -> 
'+' File share

Name: syncshare (Kleinbuchstaben)
Quota: 10GB
```
![Image File Share](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/storageAccount3-FileShare.PNG)

Danach erstellen wir die Sync Gruppe und den Cloud enpoint:
```
[Azure Portal] -> Resource Groups -> ACDMY-AzureFileSync -> myFirstStorageSync -> Sync groups -> '+' Sync group

Sync group name: 'FirstSyncGroup'
Storage account -> Select storage account -> mysyncsa....
Azure File Share: syncshare
```
![Image Sync Group.](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/SyncGroup1.PNG)


## 5
## Einen Server Endpoint erstellen
Der Server-Endpoint gibt den Ort auf einem registrierten Server an, der ge-sync'ed werden soll.  
Anm.: Es darf mehrere Server-Endpoints (=Ablageorte) auf dem gleichen Server geben diese dürfen sich aber nicht überschneiden.
```
[Azure Portal] -> Resource Groups -> ACDMY-AzureFileSync -> myFirstStorageSync -> Sync groups
```
Auf die Sync Gruppe **'FirstSyncGroup'** klicken.

![Image sync gruppe](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/AddServerEndpoint.PNG)

Add server endpoint ->  
![Image add server endpoint](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/AddServerEndpoint2.PNG)

```
Registered server: ACDMYxx-WWW.contoso.com 
Path: z.B. G:\ (ist die DatenDisk1 auf dem WWW Server)
```
![image Datendisk](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/AddServerEndpoint3.PNG)

Cloud Caching einschalten wenn gewünscht.

![ImageCloud Caching](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/AddServerEndpoint4CloudCache.PNG)

## 6
## Jetzt wird gesynched.
Bevor es losgeht nehmen wir noch einen weiteren onprem Server in den Sync Verbund mit auf.  
(Der Agent ist bereits auf dem anderen 2. Server installiert.)  
Um Zeit zu sparen öffnen Sie bitte das PowerShell Skript:
```
"C:\temp\RegisterOtherServer4AzureFileSync.ps1"
```
im Editor (Rechter Mouseklick -> Edit)

![RegisterOtherServer4AzureFileSync in ISE](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/RegisterOtherServer4AzureFileSync.PNG)

und starten dieses (F5).

a) Melden Sie sich mit Ihrem Azure User an.  
b) Wählen Sie die ACDMY-AzureFileSync Gruppe.  
c) Wählen Sie den korrekten Azure Storage Sync Service aus.  

Das Script registriert den 2. Server am ausgewälten Azure File Sync Service und fügt einen Ablageort (= Server Endpoint) hinzu.  
Wir können diesen Ablageort einsehen. **Öffnen Sie dazu den Share**
```
\\172.16.101.12\Shared
```

Jetzt wird gesync'ed

Wir erstellen uns 10 Dateien mit zufälligem Inhalt - und warten wie lange es dauert bis sie auf \\172.16.101.12\Shared gesync'ed werden.

Dazu starten wir das Script 
```
"C:\temp\WriteRandomDataFiles.ps1"
```
->Rechter Mouseklick -> Run with PowerShell -> und wählen die DatenDisk1

![Random Data](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%20Azure%20File%20Sync/WriteRandomFiles.PNG)

Fragen:
* Wie lange dauert es bis die Files am anderen Server auftauchen?
* Werden Änderungen bei den Berechtigungen mitrepliziert?
* Ein Löschen einer Datei auf dem 2. Server führt zu....?

