**1. VNET, PUPIP, AVSet einzeln im Portal erstellen**

**Create a Resource Group in Azure:**
```
[Azure Portal] -> Resource Groups -> '+ Add' ->
Name: ACDMY-Network
Region: West Europe
->Create
```
**Add an Azure virtual network (VNET) in the resource group**
```
[Azure Portal] -> Resource Groups -> ACDMY-Network ->'+ Add' ->
-> type 'Virtual Network' -> Create

Name: myVNET
Address Space: 10.10.0.0/16
Resource Group: ACDMY-Network
Subnet: Name: VMSubnet1
Address Range 10.10.10.0/24
```

**Add a public IP Address in the ACDMY-VMOne(new)**
```
[Azure Portal] -> '+ Create a resource' ->
-> type 'Public IP address' -> Create
Name: VMOne-IP
SKU: Basic
IP Version: IPv4
IP address assignment: Dynamic / Static (your choice / What is the difference?)
DNS name Label: try one - needs to be unique
Resource Group -> Create New -> ACDMY-VMOne
Location: West Europe
```

**Add an 'Availability Set' to the Res-Group: ACDMY-VMOne**
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne ->'+ Add' -> 
'Availability Set'
Name: VMOne-AVSet
RG: ACDMY-VMOne
Location: West Europe
Fault Domains:2
Update Domains:5
```
[Read: Manage the availability of Windows virtual machines in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/manage-availability?toc=%2Fazure%2Fvirtual-machines%2Fwindows%2Fclassic%2Ftoc.json)
