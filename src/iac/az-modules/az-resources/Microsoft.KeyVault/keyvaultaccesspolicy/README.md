# Key Vault Access Policy Bicep module
---

## Purpose
Provisions access policies in an existing Azure Key Vault

## Info
**Module Name**: keyvaultaccesspolicy
**Module Version**: 0.1.0

## Requirements


| Name | Version |
| --- | --- |
 | Bicep | 0.12.40.16777 |
## Examples
### Bicep - Local repository
```bicep
metadata module = {
  name: 'keyvaultaccesspolicy'
  displayName: 'Key Vault Access Policy'
  description: 'Provisions access policies in an existing Azure Key Vault'
  owner: 'Wesley Camargo'
  version: '0.1.0'
}

@description('The name of the Key Vault to provision the access policy in')
param keyVaultName string

@description('Azure AD object ID to grant access to')
param objectId string

@allowed([
  'get'
  'list'
  'set'
  'delete'
  'backup'
  'restore'
  'recover'
  'purge'
  'encrypt'
  'decrypt'
  'sign'
  'verify'
  'wrapKey'
  'unwrapKey'
])
@description('Permissions to grant to secrets')
param secretsAuthorization array = []

module accessPolicy '../keyvaultaccesspolicy.bicep' = {
  name: 'accessPolicy'
  params: {
    keyVaultName: keyVaultName
    objectId: objectId
    secretsAuthorization: secretsAuthorization
  }
}
```
### Powershell script
```powershell
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

Write-Host "##[command]Provisioning Key Vault" -ForegroundColor Blue
$keyVaultName = "kv-bcp-$moduleName-$randomId"
az keyvault create `
    -g $resourceGroup `
    -n $keyVaultName `
    -l $Region `
    --no-self-perms `
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
```
## Parameters
| Name | Type | Description | DefaultValue | AllowedValues |
| --- | --- | --- | --- | --- |
 | certificatesAuthorization| array | Certificate permissions to grant to the object ID | System.Object[] | all,backup,create,delete,deleteissuers,get,getissuers,import,list,listissuers,managecontacts,manageissuers,purge,recover,restore,setissuers,update |
 | keysAuthorization| array | Key permissions to grant to the object ID | System.Object[] | all,backup,create,decrypt,delete,encrypt,get,getrotationpolicy,import,list,purge,recover,release,restore,rotate,setrotationpolicy,sign,unwrapKey,update,verify,wrapKey |
 | keyVaultName| string | The name of the Key Vault to provision the access policy in |  |  |
 | objectId| string | Azure AD object ID to grant access to |  |  |
 | secretsAuthorization| array | Secret permissions to grant to the object ID | System.Object[] | all,backup,delete,get,list,purge,recover,restore,set |
## Resources
| Resource Name | Resource Type |
| --- | --- |
 | [format('{0}/add', parameters('keyVaultName'))]| Microsoft.KeyVault/vaults/accessPolicies |
