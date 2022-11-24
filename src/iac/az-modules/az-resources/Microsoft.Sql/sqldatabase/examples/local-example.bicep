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
