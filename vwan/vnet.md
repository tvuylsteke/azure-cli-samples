```
subscription="MSDN THOVUY P45"
admin_password=Microsoft123!
admin_user=azadmin
loc="westeurope"
rg=az-vwan-routing-rg

#select subscription
az account set --subscription "$subscription"

#Resource Group
az group create -n $rg -l $loc

#VNET in North Europe
vnet=ne-vnet
subnet=servers
az network vnet create -g $rg -n $vnet --address-prefix 10.101.24.0/24 --subnet-name $subnet --subnet-prefix 10.101.24.0/25 -l northeurope
subnet=AzureFirewallSubnet
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix 10.101.24.128/25

#test vm
name=vm-ne-vnet
az vm create --image ubuntults -g $rg -n $name --admin-password $admin_password --admin-username $admin_user -l northeurope --public-ip-address "$name-pip" --vnet-name ne-hub-vnet --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --size Standard_B1s --no-wait

#VNET in West Europe
vnet=we-vnet
subnet=servers
az network vnet create -g $rg -n $vnet --address-prefix 10.101.14.0/24 --subnet-name $subnet --subnet-prefix 10.101.14.0/25 -l westeurope
subnet=AzureFirewallSubnet
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix 10.101.14.128/25

name=vm-we-vnet
az vm create --image ubuntults -g $rg -n $name --admin-password $admin_password --admin-username $admin_user -l westeurope --public-ip-address "$name-pip" --vnet-name we-vnet --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --size Standard_B1s --no-wait

#route tables for testing!!
fwIP=10.101.11.132
rt=we-vnet-servers-RT
az network route-table create -g $rg -n $rt -l $loc
az network route-table route create -n toSpoke2 -g $rg --route-table-name $rt --address-prefix 10.101.13.0/24  --next-hop-type VirtualAppliance  --next-hop-ip-address $fwIP
az network vnet subnet update --vnet-name we-vnet -n servers -g $rg  --route-table $rt
```