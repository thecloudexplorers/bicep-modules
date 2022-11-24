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
