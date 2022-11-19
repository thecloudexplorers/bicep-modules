@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Log Analytics Workspace')
param name string = 'log${uniqueString(resourceGroup().id)}'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Provide the tier of your Log Analytics Workspace.')
param sku string = 'PerGB2018'

@description('Resource Group tags.')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
  }
}
