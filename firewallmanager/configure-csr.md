

# Some variables
subscription="MSDN THOVUY"
az account set --subscription "$subscription"

admin_password=Microsoft123!
admin_user=azadmin
loc="westeurope"
rg=az-fw-routing-vwan-rg

container_name=vpnconfig
blob_name=vpnconfig.json

# Pick up one storage account and find out name and key

storacc="vwanconf1234"
az storage account create --name $storacc  --resource-group $rg

#account_name=$(az storage account list -g $rg -o tsv --query [0].name)
account_key=$(az storage account keys list -g $rg --account-name $storacc --query [0].value -o tsv)

# Create a container and a SAS
az storage container create --account-name $storacc --account-key $account_key -n $container_name
sas=$(az storage container generate-sas --account-name $storacc --account-key $account_key -n $container_name -o tsv)
account_url=$(az storage account show -n $storacc --query primaryEndpoints.blob -o tsv)
blob_url=${account_url}${container_name}/${blob_name}?$sas

az network vpn-site download -g $rg --vwan-name vwan-fwrouting-lab --output-blob-sas-url $blob_url --vpn-sites OnPrem1Csr

# Once the config is in our blob, download
az storage blob download --account-name $storacc -c $container_name -n $blob_name --sas-token $sas -f $blob_name

# We can now parse the json file with jq (you might have to install jq in your OS)
site_name=$(jq -r '.[0].vpnSiteConfiguration.Name' ./vpnconfig.txt)
site_ip=$(jq -r '.[0].vpnSiteConfiguration.IPAddress' ./vpnconfig.txt)
site_asn=$(jq -r '.[0].vpnSiteConfiguration.BgpSetting.Asn' ./vpnconfig.txt)
gw0_public_ip=$(jq -r '.[0].vpnSiteConnections[0].gatewayConfiguration.IpAddresses.Instance0' ./vpnconfig.txt)
gw0_private_ip=$(jq -r '.[0].vpnSiteConnections[0].gatewayConfiguration.BgpSetting.BgpPeeringAddresses.Instance0' ./vpnconfig.txt)
gw1_public_ip=$(jq -r '.[0].vpnSiteConnections[0].gatewayConfiguration.IpAddresses.Instance1' ./vpnconfig.txt)
gw1_private_ip=$(jq -r '.[0].vpnSiteConnections[0].gatewayConfiguration.BgpSetting.BgpPeeringAddresses.Instance1' ./vpnconfig.txt)
echo "Configuration for site $site_name for the VPN device with public IP $site_ip and ASN $site_asn:"
echo " - Gateway 0 public IP address $gw0_public_ip, BGP peering IP address $gw0_private_ip"
echo " - Gateway 1 public IP address $gw1_public_ip, BGP peering IP address $gw1_private_ip"