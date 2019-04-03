# Backup einer VM einrichten. #

* [1. Backup Vault erstellen](#1)
* [2. Eine Datei in der VM erstellen.](#2)
* [3. Erstes Backup manuell starten.](#3)
* [4. Eine Datei wiederherstellen.](#4)
* [5. Eine VM wiederherstellen.](#5)

## 1
## Backup Vault erstellen
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne' 
  -> Operations -> Backup

Recovery Services vault -> 'Create new' -> 'VMOne-vault'
Resource Group -> 'Create new' -> 'ACDMY-VMBackup'
Choose backup policy -> '(new) DailyPolicy'
  ->Enable Backup
```
![EnableBackup](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/EnableBackup.PNG)

## 2
## Eine Datei in der VM erstellen.
Navigieren Sie in der PowerShell in das Verzeichnis mit dem Script **RunBeforeBackup.ps1**  
und starten Sie dieses.  
Das Script führt Code innerhalb der Azure VM aus, der eine Datei ins Verzeichnis c:\temp schreibt.  
Wir werden diese Datei aus dem Backup später wiederherstellen.

## 3 
## Erstes Backup manuell starten.
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne'
   ->Operation -> Backup -> 'Backup Now'
```
![TriggerBackup](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/TriggerBackupNJobs.PNG)

Der angestossene Backup-Job ist hier einsehbar:  
![ScreenshotBackupJobs](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/BackupJob.PNG)

## 4
## Eine Datei wiederherstellen.
Nach erfolgreichem Backup ändert sich die Ansicht und man kann aus dem 'Vault' die Wiederherstellung starten.  
Beim Wiederherstellen von Dateien lädt man ein Tool herunter. Die Disk der VM aus dem Backup wird am lokalen System 'gemountet'.  
Danach kann man die zu wiederherstellen Dokumente 'browsen' und kopieren.
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne'
  -> Backup -> File restore 
  1. Select a recovery point (in time)
  2. Download the executable -> execute with Admin priviledges -> enter the password as shown in the portal
```
![FileRec1](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/FileRecovery1.PNG)
```
  3. In the mounted drive browse to the path "c:\temp" and recover the file from the vm.
```
![FileRec2](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/FileRecovery2.PNG)


## 5 
## Eine VM wiederherstellen.
Navigieren Sie in der PowerShell in das Verzeichnis mit dem Script **RunBeforeRestore.ps1**  
und starten Sie dieses.
Das Script führt erstellt einen Storage Account der temporär für die wiederherstellung einer VM genutzt wird.
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne'
  -> Backup -> Restore VM
     -> Select the latest restore point
        ->Restore Type: Create Virtual Machine
        VM Name: VMTwo
```
![VMRec](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%204/VMRecovery.PNG)