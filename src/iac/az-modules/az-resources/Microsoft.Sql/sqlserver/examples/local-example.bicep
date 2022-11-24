@minLength(5)
@maxLength(50)
@description('The name of the SQL logical server.')
param name string = 'sql-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'adminuser'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string = '$ecUreP@ssw0rd'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

module sqlServer '../main.bicep' = {
  name: 'sqlServer'
  params: {
    name: name
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
    tags: tags
  }
}
