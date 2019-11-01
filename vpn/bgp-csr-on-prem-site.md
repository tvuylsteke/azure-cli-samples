https://cloudnetsec.blogspot.com/2019/02/activeactive-azure-vpn-gateways-ikev2.html
https://github.com/erjosito/azure-wan-lab
https://github.com/yinghli/azure-vpn-csr1000v
https://github.com/jwrightazure/lab/tree/master/VWAN

```
Get-AzureRmMarketplaceTerms -Publisher "Cisco" -Product "cisco-csr-1000v" -Name "16_10-byol"
Get-AzureRmMarketplaceTerms -Publisher "Cisco" -Product "cisco-csr-1000v" -Name "16_10-byol" | Set-AzureRmMarketplaceTerms -Accept
```

```
az login

subscription="MSDN THOVUY P130b"
admin_password=UpdateThisValue
admin_user=azadmin
location="westeurope"
rg="net-onprem-1-rg"
prefix="dc1"

az account set --subscription "$subscription"

az vm image list --all --publisher cisco 
az vm image list --all --publisher cisco --offer cisco-csr-1000v --sku 16_10-byol --query '[0].urn'
az vm image accept-terms --urn cisco:cisco-csr-1000v:16_10-byol:16.10.120190108 --subscription "MSDN ThoVuy P130b"
```

# build 1 VNET, with a CSR and a linux VM in it.
```
vnet=$prefix"-vnet"
az group create --name $rg --location $location
az network vnet create --resource-group $rg --name $vnet --location $location --address-prefixes 10.100.0.0/16 --subnet-name VM --subnet-prefix 10.100.10.0/24
az network vnet subnet create --address-prefix 10.100.0.0/24 --name zeronet --resource-group $rg --vnet-name $vnet
az network vnet subnet create --address-prefix 10.100.1.0/24 --name onenet --resource-group $rg --vnet-name $vnet

az network public-ip create --name $prefix"-CSR1PublicIP" --resource-group $rg --idle-timeout 30 --allocation-method Static
az network nic create --name $prefix"CSR1OutsideInterface" -g $rg --subnet zeronet --vnet $vnet --public-ip-address $prefix"-CSR1PublicIP" --ip-forwarding true --private-ip-address 10.100.0.4
az network nic create --name $prefix"CSR1InsideInterface" -g $rg --subnet onenet --vnet $vnet --ip-forwarding true --private-ip-address 10.100.1.4
az vm create --resource-group $rg --location $location --name CSR1 --size Standard_D2_v2 --nics $prefix"CSR1OutsideInterface" $prefix"CSR1InsideInterface"  --image cisco:cisco-csr-1000v:16_10-byol:16.10.120190108 --admin-username $admin_user --admin-password $admin_password --no-wait

az network public-ip create --name $prefix"DC1VMPubIP" --resource-group $rg --location $location --allocation-method Dynamic
az network nic create --resource-group $rg -n $prefix"DC1VMNIC" --location $location --subnet VM --vnet-name $vnet --public-ip-address $prefix"DC1VMPubIP" --private-ip-address 10.100.10.4
az vm create -n $prefix"-VM" -g $rg --image UbuntuLTS --admin-username $admin_user --admin-password $admin_password --nics $prefix"DC1VMNIC" --no-wait

az network route-table create --name DC1-RT --resource-group $rg
#az network route-table route create --name To-VNET10 --resource-group $rg --route-table-name $prefix"-RT" --address-prefix 10.10.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.100.1.4
#az network route-table route create --name To-VNET20 --resource-group $rg --route-table-name $prefix"-RT" --address-prefix 10.20.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.100.1.4
#az network route-table route create --name To-DC2 --resource-group $rg --route-table-name $prefix"-RT" --address-prefix 10.101.0.0/16 --next-hop-type VirtualAppliance --next-hop-ip-address 10.100.1.4
az network vnet subnet update --name VM --vnet-name $vnet --resource-group $rg --route-table $prefix"-RT"
```

# Configure CSR

```
int loopback1
ip address 192.168.100.4 255.255.255.255

!getting internet to work behind csr
int GigabitEthernet2
ip nat inside

ip nat inside source list GS_NAT_ACL interface GigabitEthernet1 vrf GS overload 
ip nat inside source static 10.100.1.4 52.250.120.19

```
crypto ikev2 proposal azure-proposal
  encryption aes-cbc-256 aes-cbc-128 3des
  integrity sha1
  group 2
  exit
!
crypto ikev2 policy azure-policy
  proposal azure-proposal
  exit
!
crypto ikev2 keyring azure-keyring
  peer 13.66.245.82
    address 13.66.245.82
    pre-shared-key abc123
    exit
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address 13.66.245.82 255.255.255.255
  authentication remote pre-share
  authentication local pre-share
  keyring local azure-keyring
  exit
!
crypto ipsec transform-set azure-ipsec-proposal-set esp-aes 256 esp-sha-hmac
 mode tunnel
 exit

crypto ipsec profile azure-vti
  set transform-set azure-ipsec-proposal-set
  set ikev2-profile azure-profile
  set security-association lifetime kilobytes 102400000
  set security-association lifetime seconds 3600 
 exit
!
interface Tunnel0
 ip unnumbered loopback1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 13.66.245.82
 tunnel protection ipsec profile azure-vti
exit
!
router bgp 65050
 bgp router-id interface loopback1
 bgp log-neighbor-changes
 network 10.100.0.0 mask 255.255.0.0
 network 0.0.0.0
 neighbor 10.101.2.254 remote-as 65000
 neighbor 10.101.2.254 ebgp-multihop 5
 neighbor 10.101.2.254 update-source loopback1 
!
ip route 10.101.2.254 255.255.255.255 Tunnel0
ip route 10.100.0.0 255.255.0.0 10.100.1.1
```

# save config!

```
Copy running-config startup-config
wr mem
```

# Configure LNG
```
az network local-gateway create --gateway-ip-address 52.250.120.19 -n CSRsite -g AZNET --local-address-prefixes 192.168.100.4/32 --asn 65050 --bgp-peering-address 192.168.100.4 -l westus2
```
# configure connection

Get ID
```
az network vnet-gateway show -n VPNGW -g AZNET
```

Get ID
```
az network local-gateway show -n CSRsite -g AZNET
```

Create connection
```
az network vpn-connection create -n AZNETtoCSR -g AZNET --vnet-gateway1 /subscriptions/182b812e-c741-4b45-93c6-26bdc3e4353b/resourceGroups/AZNET/providers/Microsoft.Network/virtualNetworkGateways/VPNGW --enable-bgp -l westus2 --shared-key "abc123" --local-gateway2 /subscriptions/182b812e-c741-4b45-93c6-26bdc3e4353b/resourceGroups/AZNET/providers/Microsoft.Network/localNetworkGateways/CSRsite
```

# verify

https://www.cisco.com/c/en/us/support/docs/ip/border-gateway-protocol-bgp/22166-bgp-trouble-main.html

CSR
```
show crypto ike sa
sh crypto ipsec sa

sh ip bgp sum

sh ip bgp neighbors 10.101.2.254

sh ip bgp

sh ip route bgp

sh ip bgp neighbors 10.101.2.254 advertised-routes

Restart BGP thingy
clear ip bgp *
```

Azure
```
az network vpn-connection list -g AZNET -o table
az network vnet-gateway list-bgp-peer-status -g AZNET -n VPNGW -o table 
az network vnet-gateway list-learned-routes -g AZNET -n VPNGW -o table
az network nic show-effective-route-table --name AZNETVMNIC --resource-group AZNET
```

```
az network public-ip create --name DC2VMPubIP --resource-group $rg --location $location --allocation-method Dynamic
az network nic create --resource-group $rg -n DC2VMNIC --location $location --subnet onenet --vnet-name $vnet --public-ip-address DC2VMPubIP --private-ip-address 10.100.1.5
az vm create -n DC2VM -g $rg --image UbuntuLTS --admin-username $admin_user --admin-password $admin_password --nics DC2VMNIC --no-wait
```