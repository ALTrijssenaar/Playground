param(
   [Parameter(Mandatory = $true)]
   [string]$ApplicationName,
   [Parameter(Mandatory = $true)]
   [string]$Subscription,
   [Parameter(Mandatory = $true)]
   [string]$Name,
   [Parameter()]
   [string]$Repo = "ALTrijssenaar/Playground",
   [Parameter()]
   [string]$Ref = "refs/heads/main"
)

$ErrorActionPreference = "Stop"

# Create the Active Directory application.
$adApp = az ad app create --display-name $ApplicationName | ConvertFrom-Json
Write-Host "AZURE_CLIENT_ID=$($adApp.appId)" -ForegroundColor Green
Write-Host "APPLICATION-OBJECT-ID=$($adApp.objectId)" -ForegroundColor Green
$adApp

# Create a service principal
Write-Host "Retrieving service principal..."
if ( -not ($sp = az ad sp show --id $adApp.appId | ConvertFrom-Json)) {
   $sp = az ad sp create --id $adApp.appId | ConvertFrom-Json
}
Write-Host "AZURE_TENANT_ID=$($sp.appOwnerTenantId)" -ForegroundColor Green

# Create a new role assignment by subscription and object
$roleAssignment = az role assignment create --role contributor --subscription $Subscription --assignee-object-id  $sp.objectId --assignee-principal-type ServicePrincipal | ConvertFrom-Json

# # Create a new federated identity credential
# $uri = "https://graph.microsoft.com/beta/applications/$($adApp.objectId)/federatedIdentityCredentials"
# $body = [PSCustomObject]@{
#    name        = $Name
#    issuer      = "https://token.actions.githubusercontent.com"
#    subject     = "repo:$($Repo):ref:$($Ref)"
#    description = "Testing"
#    audiences   = @("api://AzureADTokenExchange")
# }
# $bodyCompressedJson = $body | ConvertTo-Json -Compress
# $uri
# $bodyCompressedJson
# $federatedIdentity = az rest --verbose --method POST --uri $uri --headers ["Bearer ", "Content-Type=application/json"] --body $bodyCompressedJson

# az identity federated-credential create --identity-name Test

# az identity federated-credential list