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

$jobs = $null
"StartTime: {0}" -f $(Get-date)
$rmvms=Get-AzureRmVM -Status
"found {0} VM(s)." -f $rmvms.count 
# Add info about VM's from the Resource Manager to the array

foreach ($vm in $rmvms)
{    
    if ($vm.PowerState -eq "VM deallocated")
    {
        "Action: Starting: {0} in RG: {1}" -f $vm.Name, $vm.ResourceGroupName
        Start-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -AsJob
        Start-Sleep -Seconds 1
    }
    else
    {
        "No action on {0}" -f $vm.Name
    }
}

$jobs = Get-Job | where Command -Like "Start-*vm"
if ($jobs -ne $null)
{
    $jobs | Wait-Job -Timeout 300
    $jobs | Receive-Job
    foreach ($job in $jobs)
    {
        "{0} = {1}" -f $job.Name,$job.State
    }
 }

Get-Job | where State -EQ 'completed' | Remove-Job

"EndTime: {0}" -f $(Get-date)