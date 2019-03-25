<#
    Bootcamp: Intelligent Cloud Bootcamp Azure IaaS Cloud Expert

    ***************************************

        Create VNET, Subnets

    ***************************************
    This script will create the Azure for VMs and VPN Gateway


    see: 

    by: bfrank
    version: 1.0.0.0
#>

#region Variables
   #Network relevant settings
   $NetworkRG = "ACDMY-Network"
   $Location = "West Europe"
   $VNETName = "myVNET"
   
   $AddressSpace = @("10.10.0.0/16")
   $SubnetNames = @{
        "VMSubNet1" = "10.10.10.0/24"
        #"DCSubnet" = "10.10.200.0/24"     
        #"GatewaySubnet"="10.10.250.0/24"  #needs to be "GatewaySubnet" for azure - don't rename!    }

    #VM relevant settings
    $RG = "ACDMY-VMOne"
    $VMName = "VMOne"
    $NSGName = "$VMName-NSG"
    $AVSetName = "$VMName-AVSet"
    $PublicIPAddressName = "$VMName-IP"
    $NICName = "$VMName-NIC"
    $OSDiskCaching = "ReadWrite"
    $OSDiskName = "$VMName-OSDisk"
    
    $Premium_LRS = @{"P4"=32 ; "P6"=64 ; "P10"=128 ; "P20"=512 ; "P30"=1024 ; "P40"=2048 ; "P50"=4095; "P60"=8192; "P70"=16384; "P80"=32767}    #https://docs.microsoft.com/en-us/azure/virtual-machines/windows/premium-storage#premium-storage-disk-limits
    $Standard_LRS = @{"S4"=32 ; "S6"=64 ; "S10"=128 ; "S20"=512 ; "S30"=1024 ; "S40"=2048 ; "S50"=4095; "S60"=8192; "S70"=16384; "S80"=32767}    #https://docs.microsoft.com/en-us/azure/virtual-machines/windows/premium-storage#premium-storage-disk-limits
    $StandardSSD_LRS = @{"E10"=128 ; "E20"=512 ; "E30"=1024 ; "E40"=2048 ; "E50"=4095; "E60"=8192; "E70"=16384; "E80"=32767}  #https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-standard-ssd
#endregion


#Login to Azure
#Note: you may comment this out in case you already logged in with PowerShell
Login-AzAccount -Environment AzureCloud

#select the right subscription
Get-AzSubscription | Out-GridView -Title "Welche Subscription soll verwendet werden?" -PassThru | Select-AzSubscription

#Create the Network Resource Group
New-AzResourceGroup -Name $NetworkRG -Location $Location

#Create Subnets object
$Subnets = @()
foreach ($SubnetName in $SubnetNames.GetEnumerator())
{
    "{0} : {1}" -f $SubnetName.Name, $SubnetName.Value
    $Subnets += New-AzVirtualNetworkSubnetConfig -Name $SubnetName.Name -AddressPrefix $SubnetName.Value
}

#Create VNET with subnets
$VNET = New-AzVirtualNetwork -Name $VNETName -ResourceGroupName $NetworkRG -Location $Location -Subnet $Subnets -AddressPrefix $AddressSpace


#Create the VM Resource Group
New-AzResourceGroup -Name $RG -Location $Location

#Get the VNET
$VNET = Get-AzVirtualNetwork -Name $VNETName -ResourceGroupName $NetworkRG
$SubnetID = $VNET.Subnets|where Name -eq 'VMSubNet1' | select ID

#Create a Network Security Group
$NSGRules = @()
$NSGRules += New-AzNetworkSecurityRuleConfig -Name "RDP" -Priority 101 -Description "inbound RDP access" -Protocol Tcp -SourcePortRange * -SourceAddressPrefix * -DestinationPortRange 3389 -DestinationAddressPrefix * -Access Allow -Direction Inbound 
$NSG = New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RG -Location $Location -SecurityRules $NSGRules

#Create PublicIP
$Error.Clear()
$PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic -DomainNameLabel $([string]$($VMName+"{0:D4}" -f (Get-Random -Maximum 9999)).ToLower()) -ErrorAction SilentlyContinue #-DomainNameLabel 'blubber' #might fail whole operation when DNS name exists therefore we do it afterwards
if ($Error)
{
    $PIP = New-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RG -Location $Location -AllocationMethod Dynamic #when error occurs we create IP without DNS entry 
}

#Create NIC
$NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RG -Location $Location -SubnetId $SubnetID.Id -PublicIpAddressId $PIP.Id -NetworkSecurityGroupId $NSG.Id

#Create Availabilityset
$AVSet = New-AzAvailabilitySet -ResourceGroupName $RG -Name $AVSetName -Location $Location -PlatformUpdateDomainCount 1 -PlatformFaultDomainCount 1 -Sku Aligned

#Get VMSize
$VMSize = Get-AzVMSize -Location $Location | Out-GridView -PassThru -Title "Select Your Size"
$VM = New-AzVMConfig -VMName $VMName -VMSize $VMSize.Name -AvailabilitySetId $AVSet.Id

#Attach VNIC to VMConfig
$VM = Add-AzVMNetworkInterface -VM $VM -Id $NIC.Id

#Get the image e.g. "MicrosoftSQLServer" Offer: "SQL2017-WS2016"
$Publisher = "MicrosoftWindowsServer" #  (Get-AzVMImagePublisher -Location $location |  Out-GridView -PassThru).PublisherName 
$PublisherOffer = Get-AzVMImageOffer -Location $Location -PublisherName $Publisher | where Offer -EQ "WindowsServer" #Get-AzVMImageOffer -Location $Location -PublisherName $Publisher | Out-GridView -PassThru

#$VMImageSKU = (Get-AzVMImageSku -Location $Location -PublisherName $PublisherOffer.PublisherName -Offer $PublisherOffer.Offer).Skus | Out-GridView -PassThru
$VMImageSKU = "2019-Datacenter"
#select latest version
$VMImage = Get-AzVMImage -Location $Location -PublisherName $PublisherOffer.PublisherName -Offer $PublisherOffer.Offer -Skus $VMImageSKU | Sort-Object version -Descending | Select-Object -First 1
$VM= Set-AzVMSourceImage -VM $VM -PublisherName $PublisherOffer.PublisherName -Offer $PublisherOffer.Offer -Skus $VMImageSKU -Verbose -Version $VMImage.Version

#Disable Boot Diagnostics for VM    (is demo - don't need it AND it would require storage account which I don't want to provision)
$VM =  Set-AzVMBootDiagnostics -VM $VM -Disable 

#Create a Credential
$Credential = Get-Credential -Message 'Your VM Credentials Please!'
#Don't hardcode!
#$VMLocalAdminUser = "LocalAdminUser"
#$VMLocalAdminSecurePassword = ConvertTo-SecureString "V3ryStrongPwd!" -AsPlainText -Force 
#$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword)
$VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $VMName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate

#Config OSDisk (this is a Standard SSD low latencies but bandwidth throtteled i.e. 'E'-Series disk)
$VM = Set-AzVMOSDisk -VM $VM -Name $OSDiskName -Caching $OSDiskCaching -CreateOption FromImage -StorageAccountType StandardSSD_LRS -DiskSizeInGB $StandardSSD_LRS.E10

#New VM
New-AzVM -ResourceGroupName $RG -Location $location -VM $VM -Verbose -AsJob  #runs in background

#query job until finished.
$job =Get-Job -Newest 1 | where Command -EQ 'New-AzVM'
do
{
    Start-Sleep -Seconds 10
    $job =Get-Job -Newest 1 | where Command -EQ 'New-AzVM'
}
while ($job.State -eq 'Running')

#display results / success or errors
Receive-Job -Job $job -Keep

#if happy ... remove the job from the list....
#Remove-Job -Job $job



