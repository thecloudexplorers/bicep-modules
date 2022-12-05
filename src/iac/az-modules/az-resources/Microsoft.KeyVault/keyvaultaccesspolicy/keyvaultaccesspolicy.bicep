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

@allowed(
  [
    'all'
    'backup'
    'delete'
    'get'
    'list'
    'purge'
    'recover'
    'restore'
    'set'
  ]
)
@description('Secret permissions to grant to the object ID')
param secretsAuthorization array = []

@allowed(
  [
    'all'
    'backup'
    'create'
    'decrypt'
    'delete'
    'encrypt'
    'get'
    'getrotationpolicy'
    'import'
    'list'
    'purge'
    'recover'
    'release'
    'restore'
    'rotate'
    'setrotationpolicy'
    'sign'
    'unwrapKey'
    'update'
    'verify'
    'wrapKey'
  ]
)
@description('Key permissions to grant to the object ID')
param keysAuthorization array = []

@allowed(
  [
    'all'
    'backup'
    'create'
    'delete'
    'deleteissuers'
    'get'
    'getissuers'
    'import'
    'list'
    'listissuers'
    'managecontacts'
    'manageissuers'
    'purge'
    'recover'
    'restore'
    'setissuers'
    'update'
  ]
)
@description('Certificate permissions to grant to the object ID')
param certificatesAuthorization array = []

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultName}/add'

  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: secretsAuthorization
          keys: keysAuthorization
          certificates: certificatesAuthorization
        }
      }
    ]
  }
}
