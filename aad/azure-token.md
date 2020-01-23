$currentAzureContext = Get-AzContext
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile);
$profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken;

#SPN ClientId and Secret
$ClientID       = "appID" #ApplicationID
$ClientSecret   = 'key' #key from Application
$tennantid      = "tenantid"
 


 

$TokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $tennantid 
$ARMResource = "https://management.core.windows.net/";

 

$Body = @{
        'resource'= $ARMResource
        'client_id' = $ClientID
        'grant_type' = 'client_credentials'
        'client_secret' = $ClientSecret
}

 

$params = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $Body
    Method = 'Post'
    URI = $TokenEndpoint
}

 

$token = Invoke-RestMethod @params

 

$token | select access_token, @{L='Expires';E={[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($_.expires_on))}} | fl *