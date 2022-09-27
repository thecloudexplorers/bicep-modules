## Purpose
This module provision an Azure Resource Group.

## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Inputs

| Name     | Description             | Type   | Default               | Required | Size | Allowed values |
| -------- | ----------------------- | ------ | --------------------- | :------: | ---- | -------------- |
| name     | Resource Group name     | string |                       |   yes    |      |                |
| location | Resource Group location | string | deployment().location |   yes    |      |                |
| tags     | Resource Group tags     | object |                       |    no    |      |                |

## Outputs

| Name       | Description                                 |
| ---------- | ------------------------------------------- |
| name       | The name of the resource group              |
| resourceId | The resource ID of the resource group       |
| location   | The location the resource was deployed into |
