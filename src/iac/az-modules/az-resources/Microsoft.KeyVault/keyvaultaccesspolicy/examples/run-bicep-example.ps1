[CmdletBinding()]

param (
    [ValidateSet("AzureContainerRegistry", "LocalRepository")]
    [Parameter(Mandatory = $false)][string]$ModulesSource = "LocalRepository",
    [Parameter(Mandatory = $false)][string]$Region = "westeurope"
)

Set-Location $PSScriptRoot

$randomId = Get-Random -Minimum 1000 -Maximum 9999
$moduleName = "keyvault"
$resourceGroup = "rg-bicepmodules-$moduleName-$randomId"

if ($ModulesSource -eq "AzureContainerRegistry") {
    $bicepFile = "acr-example.bicep"
} else {
    $bicepFile = "local-example.bicep"
}

Write-Host "##[section]Provisioning dependencies" -ForegroundColor Green

Write-Host "##[command]Provisioning resource group" -ForegroundColor Blue
az group create `
    -n $resourceGroup `
    -l $Region `
    --tags ModuleExample="true"

Write-Host "##[command]Provisioning key vault" -ForegroundColor Blue
$keyVaultBicepModule = "../../keyvault/main.bicep"

$keyVaultOutput = az deployment group create `
    --resource-group $resourceGroup `
    --template-file $keyVaultBicepModule `
    --output json `
| ConvertFrom-Json

$keyVault = $keyVaultOutput.properties.outputs.keyVault_name.value

Write-Host "##[command]Obtaining AAD ObjectId from current user" -ForegroundColor Blue
$currentUserId = az ad signed-in-user show --query "[id]" -o tsv

$secretPermissions = (@("get", "list") | ConvertTo-Json -Compress).Replace('"', "'")

Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
az deployment group create `
    --resource-group $resourceGroup `
    --template-file $bicepFile `
    --name "example-$randomId" `
    --parameters `
    keyVaultName=$keyVault `
    objectId=$currentUserId `
    secretsAuthorization=$secretPermissions
