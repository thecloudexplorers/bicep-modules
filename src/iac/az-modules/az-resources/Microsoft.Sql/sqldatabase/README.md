## Purpose
Provision a SQL Database instance
## Info
**Module Name**: sqlserver

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
@description('Provide a globally unique name for the resource.')
param name string = 'sqldatabase${uniqueString(resourceGroup().id)}'

@description('The SQL Server')
param sqlServerName string

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource Group tags.')
param tags object = {}

module sqlDatabase '../main.bicep' = {
  name: 'sqldatabase'
  params: {
    name: name
    sqlServerName: sqlServerName
    location: location
    tags: tags
  }
}
```
### Bicep - Azure Container Registry
```bicep
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name for the resource.')
param name string = 'sqldatabase${uniqueString(resourceGroup().id)}'

@description('The SQL Server')
param sqlServerName string

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource Group tags.')
param tags object = {}

module sqlDatabase 'br:<YOUR ACR NAME>.azurecr.io/bicep/modules/sqldatabase:latest' = {
  name: 'sqldatabase'
  params: {
    name: name
    sqlServerName: sqlServerName
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
$moduleName = "sqldatabase"
$resourceGroup = "rg-bicepmodules-$moduleName-$randomId"
$password = '$ecUreP@ssw0rd'
$sqlServerAdmin = "adminuser"
$sQLServerName = "sql-example-$randomId"

if ($ModulesSource -eq "AzureContainerRegistry") {
    $bicepFile = "acr-example.bicep"
} else {
    $bicepFile = "local-example.bicep"
}

Set-Location $PSScriptRoot

# Create dependencies

# Create resource group to run tests in
az group create -n $resourceGroup -l $Region

# Create SQL Server dependency
$sqlServerBicepFile = "../../sqlserver/main.bicep"

az deployment group create `
    --resource-group $resourceGroup `
    --template-file $sqlServerBicepFile `
    --name "example-$randomId" `
    --parameters `
    name=$sQLServerName `
    administratorLogin=$sqlServerAdmin `
    administratorLoginPassword=$password

# Execute bicep deploy
az deployment group create `
    -f $PSScriptRoot/$bicepFile `
    -g $resourceGroup `
    --parameters sqlServerName=$sQLServerName
```
## Inputs
| Name | Type | Description | DefaultValue | AllowedValues |
| --- | --- | --- | --- | --- |
 | location| string | The location of the SQL logical server. | [resourceGroup().location] |  |
 | name| string | The name of the SQL logical server. | [format('database{0}', uniqueString(subscription().subscriptionId, resourceGroup().id))] |  |
 | sku| string |  | Basic | Basic,Standard,Premium,DataWarehouse,Stretch |
 | sqlServerName| string | The SQL Server |  |  |
 | tags| object | Resource tags. |  |  |
## Resources
| Resource Name | Resource Type |
| --- | --- |
 | [variables('databaseName')]| Microsoft.Sql/servers/databases |
## Outputs
| Name | Type | Output Value |
| --- | --- | --- |
 | databaseId| string | [resourceId('Microsoft.Sql/servers/databases', split(variables('databaseName'), '/')[0], split(variables('databaseName'), '/')[1])] |
 | databaseName| string | [variables('databaseName')] |
