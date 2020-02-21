#https://docs.microsoft.com/en-us/azure/application-gateway/quick-create-cli

rg="aks-appgw-v2-rg"
az group create --name $rg --location westeurope

#existing VNET
rg2="aks-learning"
vnet=aks-learn-vnet

az network vnet subnet create \
  --name appgateway \
  --resource-group $rg2 \
  --vnet-name $vnet   \
  --address-prefix 10.1.9.0/24

#app gw resources  
vnet=/subscriptions/182b812e-c741-4b45-93c6-26bdc3e4353b/resourceGroups/aks-learning/providers/Microsoft.Network/virtualNetworks/aks-learn-vnet
az network vnet subnet list \
    --resource-group $rg2 \
    --vnet-name $vnet \
    --query [].id --output tsv

#export subnetid=$(az network vnet show --resource-group $rg2 --name $vnet --query id -o tsv)
export subnetid=$(az network vnet subnet show --resource-group $rg2 --name appgateway --vnet-name $vnet --query id -o tsv)
  
az network public-ip create \
  --resource-group $rg \
  --name appgateway2-pip \
  --allocation-method Static \
  --sku Standard

az network application-gateway create \
  --name aksappgateway \
  --location westeurope \
  --resource-group $rg \
  --capacity 1 \
  --sku Standard_v2 \
  --public-ip-address appgateway2-pip \
  --vnet-name $vnet \
  --subnet $subnetid