@description('Azure Bicep Registry location.')
param location string = resourceGroup().location

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

@minLength(3)
@maxLength(3)
@description('Instance number of the resource on the lifecycle.')
param instanceNumber string = '001'

module naming '../../az-modules/az-naming-convention/namingConventionResources/main.bicep' = {

  name: 'naming'
  params: {
    workloadAffix: workloadAffix
    applicationSufix: applicationSufix
    environment: environment
    instanceNumber: instanceNumber
  }
}

module acr '../../az-modules/az-resources/Microsoft.ContainerRegistry/registry/main.bicep' = {
  name: 'acr'
  params: {
    name: naming.outputs.azContainerRegistryName
    location: location
    tags: tags
  }
}

output acrName string = naming.outputs.azContainerRegistryName
output acrId string = acr.outputs.loginServer
