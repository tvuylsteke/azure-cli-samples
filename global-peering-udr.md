subscription="MSDN THOVUY P130"
admin_password=UpdateThisValue
admin_user=azadmin

#select subscription
az account set --subscription "$subscription"

#Resource Group
rg=udr-global-peering-rg
az group create -n $rg -l westeurope

#WE VNET
vnet=we-vnet
subnet=servers
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/24 -l westeurope

#create subnet
subnet=AzureFirewallSubnet
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix 10.1.1.0/24

#NE VNET
vnet=ne-vnet
subnet=servers
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $subnet --subnet-prefix 10.2.0.0/24 -l northeurope

#VNET Peering
az network vnet peering create -g $rg -n we-to-ne --vnet-name we-vnet --remote-vnet ne-vnet
az network vnet peering create -g $rg -n ne-to-we --vnet-name ne-vnet --remote-vnet we-vnet --allow-forwarded-traffic

#Azure Firewall
#https://github.com/Azure/azure-cli-extensions/tree/master/src/azure-firewall
az extension add -n azure-firewall
fwName=azfw
az network firewall create --name $fwName --resource-group $rg -l westeurope
az network firewall ip-config create -f $fwName -n ipconfig --public-ip-address "$fwName-pip" -g $rg --vnet-name we-vnet

#Route table
rt=testRTNE
az network route-table create  -g $rg -n $rt -l northeurope
az network route-table route create -n toWEVNET -g $rg --route-table-name $rt --address-prefix 10.1.0.0/16  --next-hop-type VirtualAppliance  --next-hop-ip-address 10.1.1.4
az network vnet subnet update --vnet-name ne-vnet -n servers -g $rg  --route-table $rt

#Route table
rt=testRTWE
az network route-table create  -g $rg -n $rt -l westeurope
az network route-table route create -n toNEVNET -g $rg --route-table-name $rt --address-prefix 10.2.0.0/16  --next-hop-type VirtualAppliance  --next-hop-ip-address 10.1.1.4
az network vnet subnet update --vnet-name we-vnet -n servers -g $rg  --route-table $rt

#test VMs
az vm create --image ubuntults -g $rg -n testvm-we --admin-password $admin_password --admin-username $admin_user -l westeurope --public-ip-address testvm-we-pip --vnet-name we-vnet --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --no-wait
az vm create --image ubuntults -g $rg -n testvm-ne --admin-password $admin_password --admin-username $admin_user -l northeurope --public-ip-address testvm-ne-pip --vnet-name ne-vnet --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --no-wait