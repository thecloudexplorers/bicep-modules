metadata module = {
  name: 'keyvaultaccesspolicy'
  displayName: 'Key Vault Access Policy'
  description: 'Provisions access policies in an existing Azure Key Vault'
  owner: 'Wesley Camargo'
  version: '0.1.0'
}

@description('The name of the Key Vault to provision the access policy in')
param keyVaultName string

@description('Azure AD object ID to grant access to')
param objectId string

param secretsAuthorization array = [
  'get'
  'list'
  'set'
  'delete'
  'backup'
  'restore'
  'recover'
  'purge'
]

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultName}/add'

  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
          ]
          secrets: secretsAuthorization
        }
      }
    ]
  }
}
