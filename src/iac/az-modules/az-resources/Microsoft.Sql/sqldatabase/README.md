## Purpose
Provision a SQL Database instance
## Info
**Module Name**: sqlserver

**Module Version**: 0.1.0

## Requirements


| Name | Version | 
| --- | --- | 
 | Bicep | 0.1.0 | 


| Name | Version | 
| --- | --- | 
 | Bicep | 0.12.40.16777 | 
## Examples
### Bicep
```bicep
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name for the resource.')
param name string = 'sqldatabase${uniqueString(resourceGroup().id)}'

@description('The SQL Server')
param sqlServerName string

@description('Provide a location.')
param location string = resourceGroup().location

@description('Provide the tier of your Log Analytics Workspace.')
param sku string = 'PerGB2018'

@description('Resource Group tags.')
param tags object = {}

module sqlDatabase 'br:dotcedevcr001.azurecr.io/bicep/modules/sqldatabase:v0.1.0.153-pre-release' = {
  name: 'logAnalyticsWorkspace'
  params: {
    name: name
    sqlServerName: sqlServerName
    location: location
    sku: sku
    tags: tags
  }
}
```
### Powershell script
```powershell

$randomId = Get-Random -Minimum 1000 -Maximum 9999
$resourceGroup = "rg-bicepmodules-$ModuleName-$randomId"
$region = "westeurope"
$password = '$ecUreP@ssw0rd'
$sqlServerAdmin = "adminuser"
$sQLServerName = "sql-example-$randomId"

Set-Location $PSScriptRoot

az group create -n $resourceGroup -l $region

$sqlServerBicepFile = "../../sqlserver/main.bicep"

az deployment group create `
    --resource-group $resourceGroup `
    --template-file $sqlServerBicepFile `
    --name "example-$randomId" `
    --parameters `
    name=$sQLServerName `
    administratorLogin=$sqlServerAdmin `
    administratorLoginPassword=$password

az deployment group create -f $PSScriptRoot/example.bicep -g rg-bicepexample
```
## Inputs
| Name | Type | Description | DefaultValue | AllowedValues |
| --- | --- | --- | --- | --- | 
 | location| string | The location of the SQL logical server. | [resourceGroup().location] |  |
 | logAnalyticsName| string | The name of loganalytics workspace. |  |  |
 | name| string | The name of the SQL logical server. | [format('database{0}', uniqueString(subscription().subscriptionId, resourceGroup().id))] |  |
 | sku| string |  | Basic | Basic,Standard,Premium,DataWarehouse,Stretch |
 | sqlServerName| string | The SQL Server |  |  |
 | tags| object | Resource tags. |  |  |
## Resources
| Resource Name | Resource Type | Resource Comment |
| --- | --- | --- | 
 | [variables('databaseName')]| Microsoft.Sql/servers/databases |  | 
## Outputs
| Name | Type | Output Value |
| --- | --- | --- |  
 | databaseId| string | [resourceId('Microsoft.Sql/servers/databases', split(variables('databaseName'), '/')[0], split(variables('databaseName'), '/')[1])] | 
 | databaseName| string | [variables('databaseName')] | 
