az group create -n rg-bicepexample -l westeurope
az deployment group create -f $PSScriptRoot/logAnalyticsWorkspace-example.bicep -g rg-bicepexample
