## Purpose

This module provision an Azure Log Analytics Workspace.

## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Example

### Reference module

```bicep
@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Log Analytics Workspace')
param name string = 'log${uniqueString(resourceGroup().id)}'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Provide the tier of your Log Analytics Workspace.')
param sku string = 'PerGB2018'

@description('Resource Group tags.')
param tags object = {}

module logAnalyticsWorkspace 'br:dotcedevcr001.azurecr.io/bicep/modules/loganalyticsworkspace:latest' = {
  name: 'logAnalyticsWorkspace'
  params: {
    name: name
    location: location
    sku: sku
    tags: tags
  }
}
```

### Execute bicep script

```powershell
az group create -n rg-bicepexample -l westeurope
az deployment group create -f $PSScriptRoot/logAnalyticsWorkspace-example.bicep -g rg-bicepexample
```

## Inputs

| Name     | Description                                  | Type   | Default               | Required | Size | Allowed values                                                                          |
| -------- | -------------------------------------------- | ------ | --------------------- | :------: | ---- | --------------------------------------------------------------------------------------- |
| name     | Resource Group name                          | string |                       |   yes    |      |                                                                                         |
| location | Resource Group location                      | string | deployment().location |   yes    |      |                                                                                         |
| sku      | A tier of your Azure Log Analytics Workspace | string | Basic                 |    no    |      |                                                                                         |
| tags     | Resource Group tags                          | object |                       |    no    |      | Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018 |

## Outputs

| Name        | Description                             |
| ----------- | --------------------------------------- |
| loginServer | The login server property for later use |
