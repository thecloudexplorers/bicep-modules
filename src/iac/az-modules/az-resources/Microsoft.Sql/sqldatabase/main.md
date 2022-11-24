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
```powershell
az group create -n rg-bicepexample -l westeurope
az deployment group create -g rg-bicepexample -f main.bicep
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
