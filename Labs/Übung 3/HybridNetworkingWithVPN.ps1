<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    This script will create the Azure requirements for the VPN Site2Site:
    - a VNET with a Gateway subnet
    - the local network gateway config (ipfire)
    - pub IP for the Azure VPN GWay
    - the VPN GWay
    - a connection object 

    see: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-create-site-to-site-rm-powershell

    by: bfrank
    version: 1.0.0.0
#>

<#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription
#>

#region Variables
   $NetworkRG = "ACDMY-Network"
   $Location = "West Europe"
   $VNETName = "myVNET"
   $OnPremVPNDeviceName = "interxion-ipfire"
   $OnPremVPNDevicePubIPPrefix = "88.205.106."
   $OnPremVPNDeviceAddressPrefix = @('172.16.101.0/24')
   
   $AddressSpace = @("10.10.0.0/16")
   $SubnetNames = @{
        "VMSubNet1" = "10.10.10.0/24"     #
        "DCSubnet" = "10.10.200.0/24"     #
        "GatewaySubnet"="10.10.250.0/24"  #needs to be "GatewaySubnet" for azure - don't rename!    }
   $VirtualNetworkGatewayName = "myAzVPNGWay"

   $GatewayConnectionName = "azure-to-interxion"

   $SharedKey = "S3rK0mplexesSecrE!-"
#endregion

#region User Input Helper function

    function GetGroupNumberFromUser ()
    {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "IT Camp Host einrichten"
    $objForm.Size = New-Object System.Drawing.Size(300,300) 
    $objForm.StartPosition = "CenterScreen"
    
    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
        {$x=$objTextBox.Text;$objForm.Close()}})
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
        {$objForm.Close()}})
    
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,180)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
    $objForm.Controls.Add($OKButton)
    
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,180)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)
    
    $objLabelGroup = New-Object System.Windows.Forms.Label
    $objLabelGroup.Location = New-Object System.Drawing.Size(10,20) 
    $objLabelGroup.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelGroup.Text = "Wie lautet Ihre Gruppen-Nummer?"
    $objForm.Controls.Add($objLabelGroup) 
    
    $objTextBoxGroupNumber = New-Object System.Windows.Forms.TextBox 
    $objTextBoxGroupNumber.Location = New-Object System.Drawing.Size(10,40) 
    $objTextBoxGroupNumber.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBoxGroupNumber) 
    
    $objForm.Topmost = $True
    
    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()
    
    $GroupNumber = "{0}" -f [int]$objTextBoxGroupNumber.Text
    return $GroupNumber
}

    function Show-Message ($message)
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [System.Windows.Forms.MessageBox]::Show($message)
    }

    set-variable -name groupvalue -Scope global
    do
    {
       $groupvalue = $(GetGroupNumberFromUser)
       if ($groupvalue -notmatch '^[1-9]{1}$|^[1-9]{1}[0-9]{1}$')
       {
        Show-Message "Gruppen-Nummer muss zwischen 1 und 99 sein."
        }

    }while($groupvalue -notmatch '^[1-9]{1}$|^[1-9]{1}[0-9]{1}$')

    $OnPremVPNDevicePubIP = $OnPremVPNDevicePubIPPrefix + "{0}" -f $(161+[int]$groupvalue)

#endregion

<#login to Azure
Login-AzAccount -Environment AzureCloud

#select the right subscription
#Select-AzSubscription -Subscription 'SubscriptionName'

#Create the Resource Group
New-AzResourceGroup -Name $NetworkRG -Location $Location
#>

#get VNET
$VNET = Get-AzVirtualNetwork -Name $VNETName -ResourceGroupName $NetworkRG

#get the diff
$diffs = Compare-Object -ReferenceObject $($VNET.Subnets | %{$_.Name}) -DifferenceObject $($SubnetNames.GetEnumerator() | % {$_.Name})
<#

#InputObject   SideIndicator
-----------   -------------
DCSubnet      =>           
GatewaySubnet =>           
#>
 $Subnet = $null

foreach ($diff in $diffs)
{
    $subnetName = $([string]$diff.InputObject)
    "creating {0}" -f $subnetName
    $Subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $SubnetNames["$subnetName"]
    $VNET.Subnets.Add($Subnet)
}
Set-AzVirtualNetwork -VirtualNetwork $VNET

#Onprem VPN Device and routes for it
$OnPremVPNDeviceName += "{0:D2}" -f [int]$groupvalue
New-AzLocalNetworkGateway -Name $OnPremVPNDeviceName -ResourceGroupName $NetworkRG -Location $Location -GatewayIpAddress $OnPremVPNDevicePubIP -AddressPrefix $OnPremVPNDeviceAddressPrefix


#Azure VPN Gateway Pub IP 
$gwpip= New-AzPublicIpAddress -Name $($VirtualNetworkGatewayName+"IP") -ResourceGroupName $NetworkRG -Location $Location -AllocationMethod Dynamic #must be dynamic see below (as of 23.01.2019)

<# Note:
New-AzVirtualNetworkGateway : Public IP /subscriptions/f55edc34-b2f6-42f6-b100-9f68e5110bb7/resourceGroups/TestRG/providers/Microsoft.Network/publicIPAddresses/myPubIP reference by Virtual 
Network Gateway /subscriptions/f55edc34-b2f6-42f6-b100-9f68e5110bb7/resourceGroups/VPNTestRG/providers/Microsoft.Network/virtualNetworkGateways/AzVPNGWay must have PublicIPAllocationMethod 
as Dynamic.
StatusCode: 400
ReasonPhrase: Bad Request
OperationID : 'da2a345f-6cec-4877-a5d6-76059211e283'
At line:1 char:1
+ New-AzVirtualNetworkGateway -Name $VirtualNetworkGatewayName -Resourc ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : CloseError: (:) [New-AzVirtualNetworkGateway], NetworkCloudException
    + FullyQualifiedErrorId : Microsoft.Azure.Commands.Network.NewAzureVirtualNetworkGatewayCommand
#>

$VNET = Get-AzVirtualNetwork -Name $VNETName -ResourceGroupName $NetworkRG
$GWSubnet = Get-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $VNET
$gwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name $($VirtualNetworkGatewayName + "GWIPConf") -SubnetId $GWSubnet.Id -PublicIpAddressId $gwpip.Id

#Create VPN Gateway
New-AzVirtualNetworkGateway -Name $VirtualNetworkGatewayName -ResourceGroupName $NetworkRG -Location $Location -IpConfigurations $gwipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku VpnGw1 -AsJob

do
{
   Start-Sleep -Seconds 20 
}
until ((Get-AzVirtualNetworkGateway -Name $VirtualNetworkGatewayName -ResourceGroupName $NetworkRG).ProvisioningState -eq 'Succeeded')

#Create Connection
$GW = Get-AzVirtualNetworkGateway -Name $VirtualNetworkGatewayName -ResourceGroupName $NetworkRG
$onPrem = Get-AzLocalNetworkGateway -Name $OnPremVPNDeviceName -ResourceGroupName $NetworkRG

#if you need more complex ciphers and algorithms try...
#see https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-ipsecikepolicy-rm-powershell
$ipsecMoreComplexPolicy = New-AzIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA384 -DhGroup DHGroup14 -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup PFS2048 -SALifeTimeSeconds 27000 -SADataSizeKilobytes 102400000


New-AzVirtualNetworkGatewayConnection -Name $GatewayConnectionName -ResourceGroupName $NetworkRG -Location $Location `    -VirtualNetworkGateway1 $GW -LocalNetworkGateway2 $onPrem `    -ConnectionType IPsec -RoutingWeight 10 -SharedKey $SharedKey   #-IpsecPolicies $ipsecMoreComplexPolicy <# in case of updating    $connection  = Get-AzVirtualNetworkGatewayConnection -Name $GatewayConnectionName -ResourceGroupName $NetworkRG
    $newpolicy   = New-AzIpsecPolicy -IkeEncryption AES256 -IkeIntegrity SHA384 -DhGroup DHGroup14 -IpsecEncryption AES256 -IpsecIntegrity SHA256 -PfsGroup PFS2048 -SALifeTimeSeconds 14400 -SADataSizeKilobytes 102400000
    Set-AzVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $connection -IpsecPolicies $newpolicy -UsePolicyBasedTrafficSelectors $True    (Get-AzVirtualNetworkGatewayConnection -Name $GatewayConnectionName -ResourceGroupName $NetworkRG).IpsecPolicies#>#Configure your onprem VPN Device (RRAS, etc....)$gwpip = (Get-AzPublicIpAddress -Name $($VirtualNetworkGatewayName+"IP") -ResourceGroupName $NetworkRG)"Your Azure Gateway has: `nIP: {0} your secret is ""{1}""" -f $gwpip.IpAddress,$SharedKey#cleanup#Remove-AzResourceGroup -Name $NetworkRG -force