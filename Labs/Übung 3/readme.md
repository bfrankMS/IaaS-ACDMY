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

