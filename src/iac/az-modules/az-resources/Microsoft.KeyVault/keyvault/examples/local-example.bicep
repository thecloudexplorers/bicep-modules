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
