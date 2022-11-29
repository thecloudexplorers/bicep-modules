# Key Vault Bicep module
---

## Purpose
Provisions an Azure Key Vault

## Info
**Module Name**: keyvault
**Module Version**: 0.1.0

## Requirements


| Name | Version |
| --- | --- |
 | Bicep | 0.12.40.16777 |
## Examples
### Bicep - Local repository
```bicep
@minLength(5)
@maxLength(50)
@description('The name of the Azure Key Vault.')
param name string = 'kv-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

module keyVault '../main.bicep' = {
  name: name
  params: {
    name: name
    location: location
    tags: tags
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

$randomId = Get-Random -Minimum 1000 -Maximum 9999
$moduleName = "keyvault"
$resourceGroup = "rg-bicepmodules-$moduleName-$randomId"

if ($ModulesSource -eq "AzureContainerRegistry") {
    $bicepFile = "acr-example.bicep"
} else {
    $bicepFile = "local-example.bicep"
}

Set-Location $PSScriptRoot

# Create dependencies

# Create resource group to run tests in
az group create -n $resourceGroup -l $Region --tags ModuleExample="true"

# Create SQL Server instance
az deployment group create `
    --resource-group $resourceGroup `
    --template-file $bicepFile `
    --name "example-$randomId"
```
## Inputs
| Name | Type | Description | DefaultValue | AllowedValues |
| --- | --- | --- | --- | --- |
 | location| string | Provide a location. | [resourceGroup().location] |  |
 | name| string | The name of the Azure Key Vault. | [format('kv-{0}', uniqueString(subscription().subscriptionId, resourceGroup().id))] |  |
 | tags| object | Resource tags. |  |  |
## Resources
| Resource Name | Resource Type |
| --- | --- |
 | [parameters('name')]| Microsoft.KeyVault/vaults |
## Outputs
| Name | Type | Output Value |
| --- | --- | --- |
 | keyVault_name| string | [parameters('name')] |
