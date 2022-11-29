metadata module = {
  name: 'keyvault'
  displayName: 'Key Vault'
  description: 'Provisions an Azure Key Vault'
  owner: 'Wesley Camargo'
  version: '0.1.0'
}

@description('The name of the Azure Key Vault.')
param name string = 'kv-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: [
      // {
      //   tenantId: subscription().tenantId
      //   objectId: reference(azureAppService_webSiteName.id, '2019-08-01', 'full').identity.principalId
      //   permissions: {
      //     secrets: [
      //       'get'
      //     ]
      //   }
      // }
    ]
  }
}

output keyVault_name string = keyVault.name
