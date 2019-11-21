```
subscription="MSDN THOVUY P45"
admin_password=Microsoft123!
admin_user=azadmin
rg=az-vwan-routing-rg

#select subscription
az account set --subscription "$subscription"

#Resource Group
az group create -n $rg -l $loc

# CSR site
az vm image accept-terms --urn cisco:cisco-csr-1000v:16_10-byol:16.10.120190108 --subscription "$subscription"

loc="westeurope"
prefix=onprem1

vnetrange=10.100.0.0/16
serverrange=10.100.10.0/24
firewallrange=10.100.1.0/24
fwIP=10.100.1.5

#VNET
vnet=$prefix"-vnet"
az network vnet create --resource-group $rg --name $vnet --loc $loc --address-prefixes $vnetrange --subnet-name servers --subnet-prefix $serverrange
az network vnet subnet create --address-prefix $firewallrange --name csrnet --resource-group $rg --vnet-name $vnet

# CSR
az network public-ip create --name $prefix"-CSRpip" --resource-group $rg --idle-timeout 30 --allocation-method Static
az network nic create --name $prefix"CSRnic" -g $rg --subnet csrnet --vnet $vnet --ip-forwarding true --private-ip-address $fwIP --public-ip-address $prefix"-CSRpip"
az vm create --resource-group $rg --loc $loc --name $prefix"-CSR" --size Standard_D2_v2 --nics $prefix"CSRnic" --image cisco:cisco-csr-1000v:16_10-byol:16.10.120190108 --admin-username $admin_user --admin-password $admin_password --no-wait

# test VM
az network public-ip create --name $prefix"VMpip" --resource-group $rg --loc $loc --allocation-method Dynamic
az network nic create --resource-group $rg -n $prefix"VMnic" --loc $loc --subnet servers --vnet-name $vnet --public-ip-address $prefix"VMpip"
az vm create -n $prefix"-VM" -g $rg --image UbuntuLTS --admin-username $admin_user --admin-password $admin_password --nics $prefix"VMnic" --size Standard_B1s --no-wait

#Route Table
rt="$vnet-servers-RT"
az network route-table create --name $rt --resource-group $rg
az network route-table route create -n DefaultRoute -g $rg --route-table-name $rt --address-prefix 0.0.0.0/0  --next-hop-type VirtualAppliance  --next-hop-ip-address $fwIP
az network vnet subnet update --name servers --vnet-name $vnet --resource-group $rg --route-table $rt


# configure CSR as needed
see branch-csr-1tunnel.md or branch-csr-2tunnel.md


show crypto ike sa

sh ip bgp summ

sh ip bgp
```