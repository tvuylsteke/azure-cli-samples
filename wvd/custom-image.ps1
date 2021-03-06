import-module Az
Add-AzAccount
Connect-AzAccount
Select-AzSubscription -SubscriptionName "MSDN THOVUY P130b" -Tenant c5f54ad1-572c-40d7-93b2-f51f96023e32
Select-AzSubscription -SubscriptionId "182b812e-c741-4b45-93c6-26bdc3e4353b"

#packer preparation
$rgName = "custom-image-packer"
$location = "West Europe"
New-AzResourceGroup -Name $rgName -Location $location

#packer service principal
$sp = New-AzADServicePrincipal -DisplayName "PackerWVDServicePrincipal"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
New-AzRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $sp.ApplicationId

#packer image information
"Windows-10-Enterprise-multi-session-with-Office-365-ProPlus-1909": {
    "publisher": "MicrosoftWindowsDesktop",
    "offer": "office-365",
    "sku": "19h2-evd-o365pp",
    "version": "latest"
},

#Packer
#https://github.com/xstof/xstof-fta-wvd/blob/master/wvd-image-creation/README.MD
#https://packer.io/docs/builders/azure.html
#https://medium.com/slalom-build/azure-packer-592c4dc0e23a
#https://packer.io/docs/provisioners/powershell.html

#packer build
cd "C:\Users\thovuy\Documents\github\azure-cli-samples\wvd"

#$env:packer_client_id = "f9a0be43-b9d1-4fec-b068-0380c61bfc68"
#$env:packer_client_secret = "secret"
#$env:packer_tenant_id = "c5f54ad1-572c-40d7-93b2-f51f96023e32"
#$env:packer_subscription_id = "182b812e-c741-4b45-93c6-26bdc3e4353b"

.\packer.exe build -force -var "img_name=wvd-img-06" "C:\Users\thovuy\Documents\github\azure-cli-samples\wvd\Image\packer-principal_v2.json"
.\packer.exe build -force .\packer-interactive.json

#deploy new host pool
$resourceGroupName = "wvd-nonarm"
$location = "West Europe"
New-AzResourceGroup -Name $resourceGroupName -Location $location

$template_folder = "C:\Users\thovuy\Documents\github\azure-cli-samples\wvd\Templates"

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
     -TemplateFile "$template_folder\create-hostpool-template.json" `
     -TemplateParameterFile "$template_folder\create-hostpool-parameters.json"     

#make sure the service principal has access to the RG to delete VMs!
#make sure the keyvault with the 2 secrets (AD join password, WVD service principal) is created and update the references
#A deployment
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
     -TemplateFile "$template_folder\update-hostpool-template.json" `
     -TemplateParameterFile "$template_folder\update-hostpool-parameters.json" `
     -rdshNamePrefix "wvdp2a" `
     -rdshCustomImageSourceName "wvd-img-07"

#B deployment
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
     -TemplateFile "$template_folder\update-hostpool-template.json" `
     -TemplateParameterFile "$template_folder\update-hostpool-parameters.json" `
     -rdshNamePrefix "wvdp2a" `
     -rdshCustomImageSourceName "wvd-img-07"


#https://patrickvandenborn.blogspot.com/2019/10/wvd-and-vdi-automation-change-in.html