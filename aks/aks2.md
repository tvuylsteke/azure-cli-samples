#https://azure.github.io/application-gateway-kubernetes-ingress/setup/install-new/

#Resource Group
rg="aks-learning-friday"
az group create --name $rg --location westeurope

#WE VNET
vnet=aks-learn-vnet
subnet=aks
#create VNET
az network vnet create -g $rg -n $vnet --address-prefix 10.1.0.0/16 --subnet-name $subnet --subnet-prefix 10.1.0.0/21 -l westeurope

az ad sp create-for-rbac --skip-assignment -o json > auth.json
appId="62082ccb-38a9-42a6-bad3-8243a0e48958"
password="7f1ff77e-88c0-4217-b607-1937a3dc7da7"

{
  "appId": "62082ccb-38a9-42a6-bad3-8243a0e48958",
  "displayName": "azure-cli-2019-10-18-12-34-19",
  "name": "http://azure-cli-2019-10-18-12-34-19",
  "password": "7f1ff77e-88c0-4217-b607-1937a3dc7da7",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}

objectId=$(az ad sp show --id $appId --query "objectId" -o tsv)

cat <<EOF > parameters.json
{
  "aksServicePrincipalAppId": { "value": "$appId" },
  "aksServicePrincipalClientSecret": { "value": "$password" },
  "aksServicePrincipalObjectId": { "value": "$objectId" },
  "aksEnableRBAC": { "value": true }
}
EOF

wget https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/deploy/azuredeploy.json -O template.json

location="westeurope"
deploymentName="ingress-appgw"

# modify the template as needed
az group deployment create \
        -g $rg \
        -n $deploymentName \
        --template-file template.json \
        --parameters parameters.json

az aks get-credentials --resource-group $rg --name aks4f8d

az aks install-cli

alias k-kubectl

az group deployment show -g $rg -n $deploymentName --query "properties.outputs" -o json > deployment-outputs.json

# use the deployment-outputs.json created after deployment to get the cluster name and resource group name
aksClusterName=$(jq -r ".aksClusterName.value" deployment-outputs.json)
resourceGroupName=$(jq -r ".resourceGroupName.value" deployment-outputs.json)

kubectl create serviceaccount --namespace kube-system tiller-sa
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller-sa
helm init --tiller-namespace kube-system --service-account tiller-sa