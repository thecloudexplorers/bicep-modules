// parameters

@minLength(1)
@maxLength(3)
@description('Business workload affix.')
param workloadAffix string = 'wl'

@minLength(1)
@maxLength(3)
@description('Application sufix.')
param applicationSufix string = 'app'

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

// variables
var sharedNamePrefixes = loadJsonContent('./prefixes.json')
var globalAffix = '${workloadAffix}-${applicationSufix}-${environment}'
var globalAffixNoDashes = replace(globalAffix, '-', '')

output azContainerRegistryName string = '${globalAffixNoDashes}${sharedNamePrefixes.containerRegistryPrefix}${instanceNumber}'
