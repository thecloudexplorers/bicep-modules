## Purpose
This workload provision an Azure Resource Group using the module Microsoft.Resources/resourcegroup in this repository.


## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Inputs

| Name             | Description             | Type   | Default                  | Required | Size | Allowed values          |
| ---------------- | ----------------------- | ------ | ------------------------ | :------: | ---- | ----------------------- |
| location         | Resource Group location | string | resourceGroup().location |   yes    |      |                         |
| tags             | Resource Group tags     | object |                          |    no    |      |                         |
| workloadAffix    | Business workload affix | string | wl                       |   yes    | 2    |                         |
| applicationSufix | Application sufix       | string | app                      |   yes    | 3    |                         |
| environment      | Application environment | string | exp                      |   yes    | 3    | exp, dev, qua, uat, prd |

## Outputs

| Name              | Description               |
| ----------------- | ------------------------- |
| resourceGroupName | Azure Resource Group name |
