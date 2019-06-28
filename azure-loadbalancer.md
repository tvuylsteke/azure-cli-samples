```sh
subscription="MSDN THOVUY P130"

#select subscription
az account set --subscription "$subscription"

#Resource Group
rg=az-lb-rg
az group create -n $rg -l westeurope

#WE VNET
vnet=azlb-vnet
subnet=servers
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/24 -l westeurope

#create subnet
az network public-ip create --resource-group $rg --name mypublicipinbound --sku standard
az network public-ip create --resource-group $rg --name mypublicipoutbound --sku standard

az network lb create \
    --resource-group $rg \
    --name lb \
    --sku standard \
    --backend-pool-name bepoolinbound \
    --frontend-ip-name myfrontendinbound \
    --location eastus2 \
    --public-ip-address mypublicipinbound

az network lb address-pool create \
    --resource-group $rg \
    --lb-name lb \
    --name bepooloutbound

az network lb frontend-ip create \
    --resource-group $rg \
    --name myfrontendoutbound \
    --lb-name lb \
    --public-ip-address mypublicipoutbound

az network lb probe create \
    --resource-group $rg \
    --lb-name lb \
    --name http \
    --protocol http \
    --port 80 \
    --path /

#disables outbound-snat
az network lb rule create \
--resource-group $rg \
--lb-name lb \
--name inboundlbrule \
--protocol tcp \
--frontend-port 80 \
--backend-port 80 \
--probe http \
--frontend-ip-name myfrontendinbound \
--backend-pool-name bepoolinbound \
--disable-outbound-snat

#outbound rule
az network lb outbound-rule create \
 --resource-group $rg \
 --lb-name lb \
 --name outboundrule \
 --frontend-ip-configs myfrontendoutbound \
 --protocol All \
 --idle-timeout 15 \
 --outbound-ports 10000 \
 --address-pool bepooloutbound

```