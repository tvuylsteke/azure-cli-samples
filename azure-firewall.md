```sh
subscription="MSDN THOVUY P130"
admin_password=UpdateThisValue
admin_user=azadmin

#select subscription
az account set --subscription "$subscription"

#Resource Group
rg=az-firewall-rg
az group create -n $rg -l westeurope

#WE VNET
vnet=azfw-vnet
subnet=servers
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/24 -l westeurope

#create subnet
subnet=AzureFirewallSubnet
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix 10.1.1.0/24

#Azure Firewall
#https://github.com/Azure/azure-cli-extensions/tree/master/src/azure-firewall
az extension add -n azure-firewall
fwName=azfw
az network firewall create --name $fwName --resource-group $rg -l westeurope
az network public-ip create -g $rg -n "$fwName-pip"  --allocation-method Static --sku Standard
az network firewall ip-config create -f $fwName -n ipconfig --public-ip-address "$fwName-pip" -g $rg --vnet-name $vnet

#Route table
rt=testRTWE
az network route-table create -g $rg -n $rt -l westeurope
az network route-table route create -n toInternet -g $rg --route-table-name $rt --address-prefix 0.0.0.0/0  --next-hop-type VirtualAppliance  --next-hop-ip-address 10.1.1.4
az network vnet subnet update --vnet-name $vnet -n $subnet -g $rg  --route-table $rt

#test VMs
az vm create --image ubuntults -g $rg -n testvm-we --admin-password $admin_password --admin-username $admin_user -l westeurope --public-ip-address testvm-we-pip --vnet-name $vnet --subnet $subnet --os-disk-size 30 --storage-sku Standard_LRS --no-wait
```