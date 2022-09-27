targetScope = 'subscription'

@description('Azure Bicep Registry location.')
param location string = deployment().location

@description('Azure tags.')
param tags object = {}

@description('Workload affix of the Azure Bicep.')
param workloadAffix string

@description('Application sufix.')
@minLength(1)
@maxLength(3)
param applicationSufix string

@allowed([
  'exp'
  'dev'
  'qua'
  'uat'
])
param environment string = 'exp'

module rgNaming '../../az-modules/az-naming-convention/namingconventionresourcegroup/main.bicep' = {

  name: 'rgNaming'
  params: {
    workloadAffix: workloadAffix
    applicationSufix: applicationSufix
    environment: environment
  }
}

module resourceGroup '../../az-modules/az-resources/Microsoft.Resources/resourcegroup/main.bicep' = {
  name: 'resourceGroup'
  params: {
    name: rgNaming.outputs.resourceGroupName
    location: location
    tags: tags
  }
}


// module acr '../../../modules/Microsoft.ContainerRegistry/registry/main.bicep' = {
//   name: 'acr'
//   params: {
//     name: naming.outputs.azContainerRegistryName
//     location: location

//   }
// }

// output acrName string = naming.outputs.azContainerRegistryName
// output acrId string = acr.outputs.loginServer
