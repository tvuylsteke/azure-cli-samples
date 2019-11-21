az login
subscription="MSDN THOVUY P45"
az account set --subscription "$subscription"

az provider list
az provider show --namespace Microsoft.Network --query "resourceTypes[*].resourceType" --out table
 az feature list --namespace Microsoft.Network

 az feature list --namespace Microsoft.Network --query "[?name=='Microsoft.Network/AllowP2SCortexAccess']"


 