# SQL Server Bicep module
---

## Purpose
Provision a SQL Server instance
## Info
**Module Name**: sqlserver

**Module Version**: 0.1.1

## Requirements


| Name | Version |
| --- | --- |
 | Bicep | 0.12.40.16777 |
## Examples
### Bicep - Local repository
```bicep
@minLength(5)
@maxLength(50)
@description('The name of the SQL logical server.')
param name string = 'sql-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'adminuser'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string = '$ecUreP@ssw0rd'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

module sqlServer '../main.bicep' = {
  name: 'sqlServer'
  params: {
    name: name
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
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
$moduleName = "sqlserver"
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
az group create -n $resourceGroup -l $Region --tags ModuleExample="true"

# Create SQL Server instance
az deployment group create `
    --resource-group $resourceGroup `
    --template-file $bicepFile `
    --name "example-$randomId" `
    --parameters `
    name=$sQLServerName `
    administratorLogin=$sqlServerAdmin `
    administratorLoginPassword=$password
```
## Inputs
| Name | Type | Description | DefaultValue | AllowedValues |
| --- | --- | --- | --- | --- |
 | administratorLogin| string | The administrator username of the SQL logical server. | adminuser |  |
 | administratorLoginPassword| secureString | The administrator password of the SQL logical server. | $ecUreP@ssw0rd |  |
 | location| string | Provide a location. | [resourceGroup().location] |  |
 | logAnalyticsName| string | The name of loganalytics workspace. |  |  |
 | name| string | The name of the SQL logical server. | [format('sql-{0}', uniqueString(subscription().subscriptionId, resourceGroup().id))] |  |
 | tags| object | Resource tags. |  |  |
## Resources
| Resource Name | Resource Type |
| --- | --- |
 | [parameters('name')]| Microsoft.Sql/servers |
 | [variables('masterDatabase')]| Microsoft.Sql/servers/databases |
 | [variables('diagnosticSettingsName')]| Microsoft.Insights/diagnosticSettings |
 | [format('{0}/DefaultAuditingSettings', parameters('name'))]| Microsoft.Sql/servers/auditingSettings |
 | [format('{0}/AllowAllWindowsAzureIps', parameters('name'))]| Microsoft.Sql/servers/firewallRules |
