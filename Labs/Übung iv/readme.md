**2. VM - mit VM Wizard im Portal erstellen.**
```
[Azure Portal] -> Resource Groups -> ACDMY-VMOne ->'+ Add' ->
->go to resource Group -> '+ Add' -> type 'Windows Server' 
  ->Create

RG: ACDMY-VMOne
VM Name: VMOne
Region: West Europe
Availabilty Options: Availability Set   (What is an Availability Zone?) 
   -> Availabilty Set: VMOne-AVSet
Image: Windows Server 2019 Datacenter
Size: Standard F2s_v2  (Hint: you may need to deselect some options before you find F2)
Administrator Account: your choice (not Admin nor Administrator)
Password: your (complex) choice

Public inbound ports -> Allow selected ports -> allow 'RDP (3389)'

OS Disk Type: Standard SSD
VNET: myVNET
Subnet: VMSubnet1 (10.10.10.0/24)
Public IP: VMOne-IP
NIC network Security Group: Basic
Public inbound ports: allow selected ports 'RDP'
Accelerated Networking: your choice
Load balancing: no
Boot Diagnostics: off
Enable auto-shutdown: your choice

next->next->create
```