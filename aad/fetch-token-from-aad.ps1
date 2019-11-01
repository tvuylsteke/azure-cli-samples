#source: https://github.com/xstof

#
# Gets token from AAD using client credentials and puts it onto clipboard
# If not provided, the Audience parameter is taken from the pipeline
# Library used for token redemption is MSAL
# For more information see: https://docs.microsoft.com/en-us/azure/active-directory/develop/reference-v2-libraries
#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$False)]
  [string]$AADTenantName, # example: yourdomain.onmicrosoft.com
 
  [Parameter(Mandatory=$False)]
  [string]$ClientID,

  [Parameter(Mandatory=$False)]
  [string]$ClientSecret,

  [Parameter(Mandatory=$True, ValueFromPipeline)]
  [string]$Audience
  
)

Write-Output "Generating token for audience: $Audience"

# If none provided, fetch client id and client secret in json format from clipboard
if([String]::IsNullOrWhiteSpace($ClientID) -and [String]::IsNullOrWhiteSpace($ClientSecret)){
    $ClientCreds = Get-Clipboard | ConvertFrom-Json
    $ClientID = $ClientCreds.clientId
    $ClientSecret = $ClientCreds.secret
    Write-Output "Got client credentials (Client ID, $ClientID, and its Secret) from the clipboard."
}

# Get tenant if not provided
if([String]::IsNullOrWhiteSpace($AADTenantName)){
    $aad_id =  az account show --query "tenantId" -o tsv
    $AADTenantName = $aad_id
}

# Load MSAL
Add-Type -Path ".\MSAL\Microsoft.Identity.Client.dll"

# Create Client Creds
$secret = New-Object Microsoft.Identity.Client.ClientCredential($ClientSecret)

# Create Confidential App
$authority = "https://login.microsoftonline.com/$AADTenantName"
$tokencache = New-Object Microsoft.Identity.Client.TokenCache
$confapp = New-Object Microsoft.Identity.Client.ConfidentialClientApplication($ClientID, $authority, "http://redirect-uri-not-used", $secret, $null, $tokencache)

# Define the resources and scopes we want access to
$scopes = New-Object System.Collections.ObjectModel.Collection["string"]
#$scopes.Add("http://serverapp/.default")
$scopes.Add("$Audience")

# Gettoken
$authResult = $confapp.AcquireTokenForClientAsync($scopes).GetAwaiter().GetResult()

# Create Authorization Header
Write-Host ""
$authHeader = $authResult.CreateAuthorizationHeader()
$authHeader | clip

# Output the header value
Write-Host "Bearer Token: $authHeader"

Write-Host ""

. ./parse-jwttoken.ps1
Parse-JWTtoken $authHeader.Replace("Bearer ","")
