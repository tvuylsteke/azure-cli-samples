```powershell
#create app registration
$clientSecret = new-guid
$name = "ftaweb"
$audience = "http://ftaweb"
az ad app create --display-name $name --password $clientSecret --identifier-uri $audience
$clientID=$(az ad app list --display-name ftaweb --query [].appId -o tsv)
$clientID

#Create Service Principal
#when granting permissions through UI it will auto create the principal as well
az ad sp create --id $clientID

#get Azure AD tenant ID
$AADTenantID = az account show --query "tenantId" -o tsv
$AADTenantID

#print parameters
$params = @{
    AADTenantID = $AADTenantID
    clientID = $clientID
    clientSecret = $clientSecret    
}
$params

#OIDC flow
#make sure to add http://localhost as redirect URI on the web app
$RedirectUri = "http://localhost"
$UrlEncodedRedirectUri = [System.Web.HttpUtility]::UrlEncode($RedirectUri)
#form_post
#$UrlToSendClientTowards = "https://login.microsoftonline.com/$AADTenantId/oauth2/v2.0/authorize?client_id=$ClientId&response_type=id_token&redirect_uri=$UrlEncodedRedirectUri&response_mode=form_post&scope=openid%20profile&state=12345&nonce=678910&prompt=login" 
#fragment
$UrlToSendClientTowards = "https://login.microsoftonline.com/$AADTenantId/oauth2/v2.0/authorize?client_id=$ClientId&response_type=id_token&redirect_uri=$UrlEncodedRedirectUri&response_mode=fragment&scope=openid%20profile&state=12345&nonce=678910&prompt=login"
Start-Process microsoft-edge:$UrlToSendClientTowards

#copy from URL
$idtoken = "http://localhost/#id_token=eyJ0eXAiOiJK..."
$idtoken = $idtoken.replace("http://localhost/#id_token=","")
$idtoken = $idtoken.split("&")[0]
. ./parse-jwttoken.ps1
Parse-JwtToken $idtoken

#create app registration for the API
$apipwd = new-guid
$apiname = "ftaapi"
$apiaud = "http://ftaapi"
az ad app create --display-name $apiname --password $apipwd --identifier-uri $apiaud
$apiAppId=$(az ad app list --display-name ftaapi --query [].appId -o tsv)
#Create Service Principal
#required if you want to require user assignment later on
az ad sp create --id $apiAppId

#print parameters
$paramsAPI = @{
    AADTenantID = $AADTenantID
    APIclientID = $apiAppId
    APIclientSecret = $apipwd    
}
$paramsAPI

#the web app is asking for a token for the API
.\fetch-token-from-aad.ps1 -AADTenantName $AADTenantID -ClientID $clientID -ClientSecret $clientSecret -Audience "http://mklservice/.default"

# change API to require user assignment
# navigate to service principal\properties
# user assignment required: true

#Exception calling "GetResult" with "0" argument(s): "AADSTS501051: Application
#'fde32877-2b84-47ef-96ed-25d54f014499'(episerver) is not assigned to a role for the application
#'http://mklservice'(mklserviceapi).

#https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-add-app-roles-in-azure-ad-apps
#On the API we'll edit the manifest (appRoles)
     {
      "allowedMemberTypes": [
        "Application","User","Group"
      ],
      "displayName": "Staff",
      "id": "a53e1c2a-12ae-4203-98e9-2f8bdbf8c147",
      "isEnabled": true,
      "description": "Staff",
      "value": "staff"
    },
            {
      "allowedMemberTypes": [
        "Application","User"
      ],
      "displayName": "Admin",
      "id": "35e5ff41-be0a-4779-a4d5-42db2f3746c3",
      "isEnabled": true,
      "description": "Admin",
      "value": "admin"
    }

#on the web application we'll now request API permissions

#############other stuff#############################

#change to get a code
#https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-protocols-oauth-code
$UrlToSendClientTowards = "https://login.microsoftonline.com/$AADTenantId/oauth2/v2.0/authorize?client_id=$ClientId&response_type=code&redirect_uri=$UrlEncodedRedirectUri&response_mode=fragment&scope=openid%20profile&state=12345&nonce=678910&prompt=login"
#which should then be exchangeable with the token endpoint

#https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-permissions-and-consent

#if desired to get the access token back from the fragment, enable the "Access Token" checkbox under the heading called "Implicit Grant" within the "Authentication" blade of the app registration.
#implicit grant
$redirectUri = "http://localhost"
$AdditionalScopeToRequest = "http://webserver/.default"
$UrlEncodedRedirectUri = [System.Web.HttpUtility]::UrlEncode($RedirectUri)
$UrlEncodedAdditionalScopeToRequest = [System.Web.HttpUtility]::UrlEncode($AdditionalScopeToRequest)

$UrlToSendClientTowards = "https://login.microsoftonline.com/$AADTenantId/oauth2/v2.0/authorize?client_id=$ClientId&response_type=id_token%20token&redirect_uri=$UrlEncodedRedirectUri&response_mode=fragment&scope=openid%20profile%20$UrlEncodedAdditionalScopeToRequest&state=12345&nonce=678910&prompt=login" 
}

Start-Process microsoft-edge:$UrlToSendClientTowards

```