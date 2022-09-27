targetScope = 'subscription'

// parameters

@description('Business workload affix.')
@minLength(1)
@maxLength(3)
param workloadAffix string = 'wl'

@description('Application sufix.')
@minLength(1)
@maxLength(3)
param applicationSufix string = 'app'

@allowed([
    'exp'
    'dev'
    'qua'
    'uat'
])
param environment string = 'exp'

// variables
var globalAffix = '${workloadAffix}-${applicationSufix}-${environment}'

output resourceGroupName string = '${globalAffix}-rg'
