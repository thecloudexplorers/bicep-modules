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

@allowed([
  'get'
  'list'
  'set'
  'delete'
  'backup'
  'restore'
  'recover'
  'purge'
  'encrypt'
  'decrypt'
  'sign'
  'verify'
  'wrapKey'
  'unwrapKey'
])
@description('Permissions to grant to secrets')
param secretsAuthorization array = []

module accessPolicy '../keyvaultaccesspolicy.bicep' = {
  name: 'accessPolicy'
  params: {
    keyVaultName: keyVaultName
    objectId: objectId
    secretsAuthorization: secretsAuthorization
  }
}
