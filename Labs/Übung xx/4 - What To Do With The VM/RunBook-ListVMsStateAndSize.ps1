<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
#>

$connectionName = "AzureRunAsConnection"

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$rmvms=Get-AzureRmVM -Status
# Add info about VM's from the Resource Manager to the array
foreach ($vm in $rmvms)
{    
     # Add values to the array:
    $vmarray += New-Object PSObject -Property @{
            RG=$vm.ResourceGroupName; 
            Name=$vm.Name; 
            PowerState=$vm.PowerState ; #(get-culture).TextInfo.ToTitleCase(($vm.statuses)[1].code.split("/")[1]); 
            Size=$vm.HardwareProfile.VmSize
            'UTCTimestamp' = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm")
    }
}

$vmarray | Select-Object 'UTCTimestamp',Name,RG,PowerState,Size | ft