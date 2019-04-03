<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        This file will be run within the VM in azure under a local system context

    ***************************************
    This script will just output the current time to a file in c:\temp

    see: 

    by: bfrank
    version: 1.0.0.0
#>

$filePath = "c:\temp\IwasRunAt.txt"

#if dir does't exist create
if (!(Test-Path -Path (Split-Path $filePath -Parent))) {mkdir (Split-Path $filePath -Parent)}

#write current time to file.
Get-Date | Out-File $filePath -Append

#This is really simple but imagine what else you can do to customize a vm ...