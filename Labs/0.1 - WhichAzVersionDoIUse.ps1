<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Compare your installed Azure PowerShell modules version vs. the online

    ***************************************

    by: bfrank
    version: 1.0.0.0
#>
   
# $installed = Get-InstalledModule -Name AzureRm*          -> works with PowerShellGet >= 2.0
#get a list of the latest version of an installed AzureRM module
$installed = get-module -ListAvailable -Name "Az*" |  Group-Object -Property Name | % {$_.Group | Sort-Object Version -Descending | select-object -first 1}

#find latest version online
$available = Find-Module -Name Az*

"Installed`t Availabe `t Module Name"
"--------------------------------------"
#complete comparison
foreach ($item in $installed)
{
   "{1}`t {2} `t {0}" -f $item.name,$item.Version,$(switch (($available | where Name -eq $item.Name).Version -eq $item.Version)
{
    $true {" = latest"}
    $false {" < " +($available | where Name -eq $item.Name).Version}
})
}

#you might want to update - here is the command
#Update-Module -Name Az*
