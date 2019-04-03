# Eine Azure VM mit PowerShell erstellen

* [1. Als 'Ein-Zeiler'](#1)
* [2. Eine komplexere VM mit PowerShell erstellen.](#2)
* [Optional 3. 'Stepping Through' VM Create Skript](#3)

## 1
## Ein VM lässt sich in Azure mit nur einem PowerShell-CMDlet erzeugen:
```
New-AzVM -Name MyVm -Credential (Get-Credential)
```

Öffnen Sie parallel dazu das [Azure Portal](https://portal.azure.com) und verfolgen Sie was passiert.  
Fragen:
* In welcher Region wird die VM erstellt?
* Welche Größe hat die VM?
* Welches OS hat die VM?
* Welcher Plattentyp wird verwendet (Premium, Standard)?
* ...

Löschen Sie anschließend die VM mit:
```
Remove-AzResourceGroup -Name MyVM
```

## 2
## Eine komplexere VM mit PowerShell erstellen.
Öffnen Sie die PowerShell ISE und kopieren Sie folgenden Code:
```
<#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

#execute the line below...it will copy some examples from help to the clipboard
help New-AzVm -Examples | clip

#Do a STRG-V below here
#Take the code for Example 3 and delete the rest. Remove some line brakes to make the code work and run...
```
Arbeiten Sie sich durch die 'grünen' Kommentare!  
Lösen Sie die Fehler im Skript. Die ISE (Intellisense) hilft dabei.  
Bekommen Sie die VM erstellt?

## 3
## 'Stepping Through' VM Create Skript

Öffnen Sie die PowerShell ISE (als Administrator)
Öffnen Sie die Datei 'CreateVMTwo.ps1'
Setzen Sie den Cursor in Ziele 71 (Bei '$VNET = Get-AzVirtualNetwork...') 
Pressen Sie F9 oder Setzen Sie den Breakpoint über ISE -> Debug -> 'Toggle Breakpoint'
Starten Sie das Script ('F5')
Steppen Sie durch das Programm mit F10
Tipp: Legen Sie sich das [Azure Portal](https://portal.azure.com) (Home->All resources) auf die andere Hälfte des Screens und beobachten Sie den Fortschritt:
