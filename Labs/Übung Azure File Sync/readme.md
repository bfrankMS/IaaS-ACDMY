# PowerShell Module für Azure installieren und eine VM damit erstellen #

Referenzen:  
[Planning for an Azure Files deployment](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-planning)  
[Planning for an Azure File Sync deployment](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-planning)  
[Deploy Azure File Sync](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-deployment-guide)

Für Azure File Sync brauchen wir:
* [0. (Optional) Bereit für File Sync? Test mit dem Azure File Sync evaluation tool](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-planning#evaluation-tool)
* [1. Storage Sync Service erstellen](#1)
* [2. Installation des Sync Agents](#2)
* [3. Windows Server am Storage Sync Service registrieren](#3)
* [4. Eine Sync Group und einen Cloud Enpoint erstellen](#4)
* [5. Einen Server Endpoint erstellen](#5)
* [6. File Sync testen](#6)


## 1 
## Storage Sync Service erstellen

```
[Azure Portal] -> "+" Create a resource -> 'Azure File Sync'

Name: myFirstStorageSyncService  
Subscription: z.B. Azure Pass  
Resource Group: -> Create New -> 'ACDMY-AzureFileSync'  
Location: 'North Europe'  
```
## 2
## Installation des Sync Agents
Um via PowerShell mit Azure File Sync verwalten zu können müssen wir eine DLL importieren. Diese Dll kommt mit der Installation des Sync Agents (d.h. ist noch nicht Bestandteil der Azure PowerShell-Module).  
[Offizieller Download Azure File Sync agent](https://go.microsoft.com/fwlink/?linkid=858257)  
Alternativ auf dem Testsystem unter _"C:\temp\StorageSyncAgent_V6_WS2019.msi"_ abgelegt.

```
Next -> Accept Eula -> Next -> Feature selection 'Azure File Sync' -> Next  
Proxy Settings -> Configure custom proxy settings for Storage Sync Agent  
Host: 172.16.101.1  
Port: 800  
-> Next -> "Use Microsoft Update" ->Agent auto-update....make settings as you wish.
```

## 3 
## Register Windows Server with Storage Sync Service

C:\Program Files\Azure\StorageSyncAgent\ServerRegistration.exe
Image1

nach dem einloggen den Storage Sync Service auswählen:
Azure Subscription: Azure Pass
Resource Group: 'ACDMY-AzureFileSync'
Storage Sync Service: myFirstStorageSyncService
->Register klicken

Image2

Image3 Succes

## 4 
## Create a sync group and a cloud endpoint
[see](https://docs.microsoft.com/en-us/azure/storage/files/storage-sync-files-deployment-guide?tabs=azure-portal#create-a-sync-group-and-a-cloud-endpoint)

Zunächst müssen wir einen Storage Account erstellen welche für den 'Cloud endpoint' benötigt wird. Der 'Cloud enpoint' ist ein Azure File Share der in dem Storage Account liegt.

[Azure Portal] -> '+' Create a resource -> 'Storage Account' -> Create

Resource Group: 'ACDMY-AzureFileSync'
Storage account name: mysyncsa0815   (einzigartig und kleinbuchstaben)
Location: 'North Europe' (muss in derselben Region als der Sync Service sein.)
Performance: Standard
Account kind: Storagev2
Replication: Locally-redundant storage (LRS)
Access tier: Hot

->Next: Advanced -> Next: Tags -> Next: review + create

Wenn der Storage Account erstellt wurde dann erzeugen wir einen Azure File Share darin:
Resource groups -> ACDMY-AzureFileSync -> mysyncsa....->'Overview' -> Files -> 
'+' File share

Name: syncshare (Kleinbuchstaben)
Quota: 10GB

Image File Share

Danach erstellen wir die Sync Gruppe und den Cloud enpoint:

[Azure Portal] -> Resource Groups -> ACDMY-AzureFileSync -> myFirstStorageSync -> Sync groups -> '+' Sync group

Sync group name: 'FirstSyncGroup'
Storage account -> Select storage account -> mysyncsa....
Azure File Share: syncshare

Image Ergebnis.


## 5
## Create a server endpoint
Im Anschluss richten wir den Server enpoint ein.
Dazu auf die Sync Gruppe klicken.

Image sync gruppe

Add server endpoint ->

Registered server: ACDMYxx-WWW.contoso.com 
Path: z.B. G:\ (ist die DatenDisk1 auf dem WWW Server)

image Datendisk

Cloud Caching einschalten wenn gewünscht.

ImageCloud Caching.

## 6
## Jetzt wird gesynched.

