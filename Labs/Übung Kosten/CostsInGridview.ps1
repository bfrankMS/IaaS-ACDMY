<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        ...................

    ***************************************
    This script will 

    see: https://docs.microsoft.com/en-us/azure/cost-management/tutorial-export-acm-data

    by: bfrank
    version: 1.0.0.0
#>


<#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

#region Helper Functions
    function ShowOpenFileDialog ([string]$Title,[string]$InitialDirectory,[string]$FileFilter)
    {
    $myDialog = New-Object System.Windows.Forms.OpenFileDialog
    $myDialog.Title = "$Title"
    $myDialog.Multiselect = $true
    $myDialog.InitialDirectory = "$InitialDirectory"
    $myDialog.Filter = "$FileFilter"
    $result = $myDialog.ShowDialog()
    
    If($result -eq “OK”) 
    {
        #$myDialog.FileName
        $myDialog.FileNames
    }
    else 
    {
        $null
    }
}

function OpenFolderDialog ()
{
    $ui = new-object -ComObject "Shell.Application"
    $path = $ui.BrowseForFolder(0,"Select a folder",0,0x11)
    $path.Self.Path
}
#endregion

#After your created a daily export in Azure -> download a file ...

#region what directory are we in?
    if ($host.name -eq 'ConsoleHost') # or -notmatch 'ISE'
    {
      $currentPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
    }
    else
    {
      $currentPath = split-path $psISE.CurrentFile.FullPath -parent
    }
#endregion  

#Get the files to import
$file = ShowOpenFileDialog "What is your CSV to import?" "$currentPath" "CSV (*.csv)|*.csv|All files (*.*)|*.*"

#$costs = Import-Csv "C:\Users\bfrank\Downloads\dailyAzureExport_9374ad48-2dec-48f6-8a76-cbbf6eb3f7ce.csv"
$costs = Import-Csv $file -Delimiter ','
#$costs | Out-GridView

#Felder optimiert z.B. '.' -> ',' InstanceName abgekürzt
$costs2Export = $costs| select-object UsageDateTime,ResourceGroup, ResourceLocation, MeterCategory,MeterSubcategory,MeterName,@{L='InstanceID';E={ Split-Path $_.InstanceID -Leaf}},@{L='UsageQuantity';E={ $_.UsageQuantity.Replace('.',',')}},@{L='ResourceRate';E={ $_.ResourceRate.Replace('.',',')}},@{L='PreTaxCost';E={ $_.PreTaxCost.Replace('.',',')}},Currency | Out-GridView -OutputMode Multiple

$currentPath = ""
#region what directory are we in?
    if ($host.name -eq 'ConsoleHost') # or -notmatch 'ISE'
    {
      $currentPath = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
    }
    else
    {
      $currentPath = split-path $psISE.CurrentFile.FullPath -parent
    }
#endregion 

#export des subsets in eigene CSV 
$costs2Export | Export-Csv -Path "$currentPath\Export.csv" -Delimiter ';' -Encoding UTF8 -NoTypeInformation

