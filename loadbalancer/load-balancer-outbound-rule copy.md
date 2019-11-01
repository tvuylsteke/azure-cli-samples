az login

subscription="MSDN THOVUY P130b"

lb="outboundsnat2-lb"
location="eastus"

az account set --subscription "$subscription"

#Resource Group
rg=az-snatlb2-rg
az group create -n $rg -l $location

#WE VNET
vnet=snat-vnet
subnet=servers
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/24 -l $location

admin_password=UpdateTosometh.
admin_user=azadmin
#dissaociate the IP's later! We don't need/want them for this kind of tests.
az vm create --image ubuntults -g $rg -n testvmsnat1-we --admin-password $admin_password --admin-username $admin_user -l $location --vnet-name $vnet --subnet $subnet --os-disk-size 30 --storage-sku Standard_LRS --no-wait
az vm create --image ubuntults -g $rg -n testvmsnat2-we --admin-password $admin_password --admin-username $admin_user -l $location --public-ip-sku Standard --vnet-name $vnet --subnet $subnet --os-disk-size 30 --storage-sku Standard_LRS --no-wait 


#IPS
az network public-ip create --resource-group $rg --name outboundip1 --sku standard
az network public-ip create --resource-group $rg --name outboundip2 --sku standard
az network public-ip create --resource-group $rg --name outboundip3 --sku standard

az network public-ip create --resource-group $rg --name inboundip1 --sku standard
az network public-ip create --resource-group $rg --name inboundip2 --sku standard
az network public-ip create --resource-group $rg --name inboundip3 --sku standard

#LB
az network lb create \
    --resource-group $rg \
    --name $lb \
    --public-ip-address inboundip1 \
    --frontend-ip-name frontendInbound1 \
    --backend-pool-name inboundBackendPool \
    --sku Standard

#2nd backend pool
az network lb address-pool create \
    --resource-group $rg \
    --lb-name $lb \
    --name outboundBackendPool

#frontend IPs
az network lb frontend-ip create \
    --resource-group $rg \
    --name frontendOutbound1 \
    --lb-name $lb \
    --public-ip-address outboundip1

az network lb frontend-ip create \
    --resource-group $rg \
    --name frontendOutbound2 \
    --lb-name $lb \
    --public-ip-address outboundip2

az network lb frontend-ip create \
    --resource-group $rg \
    --name frontendOutbound3 \
    --lb-name $lb \
    --public-ip-address outboundip3

az network lb frontend-ip create \
    --resource-group $rg \
    --name frontendInbound2 \
    --lb-name $lb \
    --public-ip-address inboundip2

az network lb frontend-ip create \
    --resource-group $rg \
    --name frontendInbound3 \
    --lb-name $lb \
    --public-ip-address inboundip3

#probe

az network lb probe create \
    --resource-group $rg \
    --lb-name $lb \
    --name httpProbe \
    --protocol tcp \
    --port 80

#outbound rule
az network lb outbound-rule create \
 --resource-group $rg \
 --lb-name $lb \
 --name outboundrule \
 --frontend-ip-configs frontendOutbound1 frontendOutbound2 frontendOutbound3\
 --protocol All \
 --idle-timeout 15 \
 --outbound-ports 0 \
 --address-pool outboundBackendPool

#inbound rule
az network lb rule create \
    --resource-group $rg \
    --lb-name $lb \
    --name inboundDummyRule1 \
    --protocol tcp \
    --frontend-port 80 \
    --backend-port 80 \
    --frontend-ip-name frontendInbound1 \
    --backend-pool-name inboundBackendPool \
    --probe-name httpProbe

az network lb rule create \
    --resource-group $rg \
    --lb-name $lb \
    --name inboundDummyRule2 \
    --protocol tcp \
    --frontend-port 81 \
    --backend-port 81 \
    --frontend-ip-name frontendInbound2 \
    --backend-pool-name inboundBackendPool \
    --probe-name httpProbe

az network lb rule create \
    --resource-group $rg \
    --lb-name $lb \
    --name inboundDummyRule3 \
    --protocol tcp \
    --frontend-port 82 \
    --backend-port 82 \
    --frontend-ip-name frontendInbound3 \
    --backend-pool-name inboundBackendPool \
    --probe-name httpProbe

#show SNAT on inbound rule
az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule1 --query 'disableOutboundSnat'
az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule2 --query 'disableOutboundSnat'
az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule3 --query 'disableOutboundSnat'

az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule1
az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule2
az network lb rule show -g $rg --lb-name $lb -n inboundDummyRule3

#disable SNAT on inbound rule
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule1 --disable-outbound-snat
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule2 --disable-outbound-snat
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule3 --disable-outbound-snat

#enable SNAT on inbound rule
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule1 --disable-outbound-snat false
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule2 --disable-outbound-snat false
 az network lb rule update -g $rg --lb-name $lb -n inboundDummyRule3 --disable-outbound-snat false

#show outbound rule
az network lb outbound-rule show \
 --resource-group $rg \
 --lb-name $lb \
 --name outboundrule \

#delete outbound rule
az network lb outbound-rule delete \
 --resource-group $rg \
 --lb-name $lb \
 --name outboundrule 

 #a nodes to backend pool!



 az network lb show \
 --resource-group $rg \
 --name $lb \