**Backup von einer VM einrichten.**

[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne' 
  -> Operations -> Backup

Recovery Services vault -> 'Create new'
'VMOne-vault'

Resource Group -> 'Create new' -> 'ACDMY-VMBackup'
Choose backup policy -> '(new) DailyPolicy'

  ->Enable Backup

Screenshot

Open script '4.1 - RunBeforeBackup.ps1' in your favorite editor (e.g. right click -> edit)
Execute it - you might need to uncoomment the login to azure first
The script will be run within the VM you choose and create a file in c:\temp with a timestamp.

**Trigger the backup manually**
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne'
   ->Operation -> Backup -> 'Backup Now'

Screenshot Backup trigger
ScreenshotBackupJobs

**Do a file recovery**
Once a backup is done the view changes and you can restore from the 'vault'
[Azure Portal] -> Resource Groups -> ACDMY-VMOne -> 'VMOne'
...
   

File Recorvery machen. ("c:\temp\rundate.txt")

**Do a vm recovery**
"4.2 - RunBeforeRestore.ps1" -> (erzeugt einen Storage Account in den wiederhergestellt werden kann.) -> Restore VM machen.