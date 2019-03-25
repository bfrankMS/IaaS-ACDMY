**3. Hybrid Networking mit VPN**

In diesen Lab erstellen wir eine VPN Site2Site Verbindung von Azure zu interxion

Dinge die man für S2S VPN braucht:
```
[Azure]
* VPN Gateway in eigenem Subnet.
* VPN GWay braucht eine Public IP (dynamic)
* Definition wie die onprem VPN / FWall zu erreichen ist (aka LocalNetworkGateway)
* Verbindungs Objekt mit 'Schlüssel-informationen' ;-)
[onprem]
* ein von Azure unterstütztes VPN-Device

```
**Gateway subnet erstellen**
```
[Azure Portal] -> '+ Create a resource' -> type "Virtual network gateway"
  -> Create

Name: myAzVPNGWay
Gateway type: VPN
VPN Type: Route based
SKU: VpnGw1
Virtual Network -> 'Choose a virtual network' -> myVNET
Gateway subnet address range: 10.10.250.0/24
Public IP address -> create new -> 'myAzVPNGWay-IP'
Resource Group: ACDMY-Network
Location: West Europe
```
![image](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%203/VPNGWay.PNG)

-> the GW will take approx 30 mins. to create -> come back later....

**Local Network Gateway konfiguration erstellen**
```
[Azure Portal] -> Resource Groups -> ACDMY-Network ->'+ Add' ->
-> type 'Local network gateway' -> Create

Name: interxion-ipfire.....
IP Address: ask your instructor ;-)
Address Space: 172.16.101.0/24
Resource Group: ACDMY-Network
Location: West Europe

->Create
```
![Local Network Gateway](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%203/LocalNetworkGW.png)

**Verbindungs Objekt mit 'Schlüssel-informationen'**
```
[Azure Portal] -> Resource Groups -> ACDMY-Network -> myAzVPNGWay
 -> Connections -> 

 Name: azure-to-interxion
 Connection Type: Site-to-Site (IPSec)
 Virtual Network Gateway: myAzVPNGWay
 Local Network Gateway: interxion-ipfire....
 Shared Key: ************** (your choice here)
 Resource Group: ACDMY-Network
``` 

**[onprem] VPN Gerät konfigurieren (e.g. ipfire)**
IPfire -> Services -> 'Connection Status and -Control' -> 'Add'
   -> 'Net-to-Net Virtual Private Network'  -> Add
![IPFire1](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%203/ipfire1.PNG)

   Remote host/IP: Enter the public IP of your Azure VPN Gway ([Azure Portal] -> ACDMY-Network -> myAzVPNGWay-IP )
   Remote subnet: Enter the address Range of your VNET in Azure (10.10.0.0/255.255.0.0)
   Use a pre-shared key: ************** (take the key you used above)
![IPFire2](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%203/ipfire2.PNG)

   You need to modify the default cipher settings in your ipfire:
![IPFire3](https://github.com/bfrankMS/IaaS-ACDMY/blob/master/Labs/%C3%9Cbung%203/ipfire3.PNG)



