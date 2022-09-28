## Purpose
This workload provision an Azure Container Registry using the module Microsoft.ContainerRegistry/registry in this repository.

This workload uses relative path reference on this repository, in order to provision the Azure Container Registry to publish other modules.

## Pipelines

This Workload contains an Azure DevOps pipeline with the capabilities:
* Bootstrap the Azure Container Registry with its Resource Group
* Push bicep modules on this repository
* Create git tags for each module

## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Inputs

| Name             | Description                                      | Type   | Default                  | Required | Size | Allowed values          |
| ---------------- | ------------------------------------------------ | ------ | ------------------------ | :------: | ---- | ----------------------- |
| location         | Resource Group location                          | string | resourceGroup().location |   yes    |      |                         |
| tags             | Resource Group tags                              | object |                          |    no    |      |                         |
| workloadAffix    | Business workload affix                          | string | wl                       |   yes    | 2    |                         |
| applicationSufix | Application sufix                                | string | app                      |   yes    | 3    |                         |
| environment      | Application environment                          | string | exp                      |   yes    | 3    | exp, dev, qua, uat, prd |
| instanceNumber   | Instance number of the resource on the lifecycle | string | 001                      |    no    | 3    | Number on format 001    |

## Outputs

| Name    | Description                             |
| ------- | --------------------------------------- |
| acrName | Azure Container Registry name           |
| acrId   | The login server property for later use |
