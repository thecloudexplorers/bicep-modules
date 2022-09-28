## Purpose
This module provision an Azure Container Registry.

## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Inputs

| Name     | Description                             | Type   | Default               | Required | Size | Allowed values |
| -------- | --------------------------------------- | ------ | --------------------- | :------: | ---- | -------------- |
| name     | Resource Group name                     | string |                       |   yes    |      |                |
| location | Resource Group location                 | string | deployment().location |   yes    |      |                |
| acrSku   | A tier of your Azure Container Registry | string | Basic                 |    no    |      |                |
| tags     | Resource Group tags                     | object |                       |    no    |      |                |

## Outputs

| Name        | Description                             |
| ----------- | --------------------------------------- |
| loginServer | The login server property for later use |
