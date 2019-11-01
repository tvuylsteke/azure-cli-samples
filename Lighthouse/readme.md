#https://azurecitadel.com/automation/lighthouse/onboarding/

subscriptionID=dccc2c3d-5ed0-4e2b-8573-7a0090c6a54d
subscriptionName=MSDN THOVUY P130

az ad user show --upn-or-object-id thovuy@microsoft.com --query objectId -o tsv
f1d870ec-d43c-42d4-a8be-b06458f0015b

az account show
72f988bf-86f1-41af-91ab-2d7cd011db47

# Login
az login

subscription="MSDN THOVUY P130"

#select subscription
az account set --subscription "$subscription"


# Run the onboarding templates
az deployment create --name LighthouseOnboarding --location westeurope --template-file delegatedResourceManagement.json --parameters delegatedResourceManagement.parameters.json