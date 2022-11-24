metadata module = {
  name: 'sqlserver'
  description: 'Provision a SQL Database instance'
  owner: 'Wesley Camargo'
  version: '0.1.0'
}

@minLength(5)
@maxLength(50)
@description('The name of the SQL logical server.')
param name string = 'database${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@allowed(
  [
    'Basic'
    'Standard'
    'Premium'
    'DataWarehouse'
    'Stretch'
  ]
)
param sku string = 'Basic'

@description('The SQL Server')
param sqlServerName string

@description('The location of the SQL logical server.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

@description('The name of loganalytics workspace.')
param logAnalyticsName string = ''

var databaseName = '${sqlServerName}/${name}'

resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: sku
    tier: sku
  }
}

output databaseName string = database.name
output databaseId string = database.id
