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

$Tags = @(
    "ModuleExample=true"
    "ToRemove=true"
)

Write-Host "##[section]Provisioning dependencies" -ForegroundColor Green

Write-Host "##[command]Provisioning resource group" -ForegroundColor Blue
az group create `
    -n $resourceGroup `
    -l $Region `
    --tags $Tags

$keyVaultName = "kv-bcp-$moduleName-$randomId"

az keyvault create `
    -g $resourceGroup `
    -n $keyVaultName `
    -l $Region `
    --tags $Tags

Write-Host "##[command]Obtaining AAD ObjectId from current user" -ForegroundColor Blue
$currentUserId = az ad signed-in-user show --query "[id]" -o tsv

$secretPermissions = (@("get", "list") | ConvertTo-Json -Compress).Replace('"', "'")

Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
az deployment group create `
    --resource-group $resourceGroup `
    --template-file $bicepFile `
    --name "example-$randomId" `
    --parameters `
    keyVaultName=$keyVaultName `
    objectId=$currentUserId `
    secretsAuthorization=$secretPermissions
