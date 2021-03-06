```
subscription="MSDN THOVUY P45"
subscription="Azure CXP FTA Internal Subscription THOVUY"
admin_password=Microsoft123!
admin_user=azadmin
loc="westeurope"
rg=az-vwan-routing-rg

#select subscription
az account set --subscription "$subscription"

#Resource Group
az group create -n $rg -l $loc

hubrange=10.101.11.0/24
hubserversrange=10.101.11.0/25
hubfwrange=10.101.11.128/25
fwIP=10.101.11.132

spoke1range=10.101.12.0/24
spoke1serversrange=10.101.12.0/25

spoke2range=10.101.13.0/24
spoke2serversrange=10.101.13.0/25

#VNET
#WE VNET
vnet=we-hub-vnet
subnet=servers
az network vnet create -g $rg -n $vnet --address-prefix $hubrange --subnet-name $subnet --subnet-prefix $hubserversrange -l $loc
subnet=AzureFirewallSubnet
az network vnet subnet create -g $rg -n $subnet --vnet-name $vnet --address-prefix $hubfwrange

#WE SPOKE VNET
vnet=we-spoke-vnet-01
subnet=servers
az network vnet create -g $rg -n $vnet --address-prefix $spoke1range --subnet-name $subnet --subnet-prefix $spoke1serversrange -l $loc

#WE SPOKE VNET
vnet=we-spoke-vnet-02
subnet=servers
az network vnet create -g $rg -n $vnet --address-prefix $spoke2range --subnet-name $subnet --subnet-prefix $spoke2serversrange -l $loc

#VNET Peering
az network vnet peering create -g $rg -n h-to-s1 --vnet-name we-hub-vnet --remote-vnet we-spoke-vnet-01 --allow-vnet-access
az network vnet peering create -g $rg -n s1-to-h --vnet-name we-spoke-vnet-01 --remote-vnet we-hub-vnet --allow-forwarded-traffic --allow-vnet-access

az network vnet peering create -g $rg -n h-to-s2 --vnet-name we-hub-vnet --remote-vnet we-spoke-vnet-02 --allow-vnet-access
az network vnet peering create -g $rg -n s2-to-h --vnet-name we-spoke-vnet-02 --remote-vnet we-hub-vnet --allow-forwarded-traffic --allow-vnet-access

#test VMs
name=vm-we-spoke1
az vm create --image ubuntults -g $rg -n $name --admin-password $admin_password --admin-username $admin_user -l $loc --public-ip-address "$name-pip" --vnet-name we-spoke-vnet-01 --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --size Standard_B1s --no-wait

name=vm-we-spoke2
az vm create --image ubuntults -g $rg -n $name --admin-password $admin_password --admin-username $admin_user -l $loc --public-ip-address "$name-pip" --vnet-name we-spoke-vnet-02 --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --size Standard_B1s --no-wait

name=vm-we-hub
az vm create --image ubuntults -g $rg -n $name --admin-password $admin_password --admin-username $admin_user -l $loc --public-ip-address "$name-pip" --vnet-name we-hub-vnet --subnet servers --os-disk-size 30 --storage-sku Standard_LRS --size Standard_B1s --no-wait

# Firewall in hub

#route tables
rt=we-spoke-vnet-01-servers-RT
az network route-table create -g $rg -n $rt -l $loc
az network route-table route create -n toInternet -g $rg --route-table-name $rt --address-prefix 0.0.0.0/0  --next-hop-type VirtualAppliance  --next-hop-ip-address $fwIP
az network vnet subnet update --vnet-name we-spoke-vnet-01 -n servers -g $rg  --route-table $rt

rt=we-spoke-vnet-02-servers-RT
az network route-table create -g $rg -n $rt -l $loc --disable-bgp-route-propagation true
az network route-table route create -n toInternet -g $rg --route-table-name $rt --address-prefix 0.0.0.0/0  --next-hop-type VirtualAppliance  --next-hop-ip-address $fwIP
az network vnet subnet update --vnet-name we-spoke-vnet-02 -n servers -g $rg  --route-table $rt

#firewall
fwName=wehubfw
az network firewall create --name $fwName --resource-group $rg -l $loc
az network public-ip create -g $rg -n "$fwName-pip"  --allocation-method Static --sku Standard
az network firewall ip-config create -f $fwName -n ipconfig --public-ip-address "$fwName-pip" -g $rg --vnet-name we-hub-vnet

#get IP's
az network public-ip show --name "$fwName-pip" --resource-group $rg
fwprivaddr="$(az network firewall ip-config list -g $rg -f $fwName --query "[?name=='FW-config'].privateIpAddress" --output tsv)"

az network firewall application-rule create \
   --collection-name App-Coll01 \
   --firewall-name $fwName \
   --name Allow-Google \
   --protocols Http=80 Https=443 \
   --resource-group $rg \
   --target-fqdns www.google.com \
   --source-addresses 10.0.2.0/24 \
   --priority 200 \
   --action Allow

az network firewall network-rule create \
   --collection-name PrivateTraffic \
   --destination-addresses 10.0.0.0/8 \
   --destination-ports '*' \
   --firewall-name $fwName \
   --name Allow-All \
   --protocols Any \
   --resource-group $rg \
   --priority 200 \
   --source-addresses 10.0.0.0/8 \
   --action Allow
```

Stop and start the firewall


```

$rg = "az-vwan-routing-rg"
$fw = "wehubfw"
# Stop an existing firewall
$azfw = Get-AzFirewall -Name $fw -ResourceGroupName $rg
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

# Start a firewall

$azfw = Get-AzFirewall -Name "FW Name" -ResourceGroupName "RG Name"
$vnet = Get-AzVirtualNetwork -ResourceGroupName "RG Name" -Name "VNet Name"
$publicip = Get-AzPublicIpAddress -Name "Public IP Name" -ResourceGroupName " RG Name"
$azfw.Allocate($vnet,$publicip)
Set-AzFirewall -AzureFirewall $azfw


```