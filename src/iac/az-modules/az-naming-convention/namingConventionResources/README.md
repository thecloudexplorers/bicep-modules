## Purpose
This module provides a naming convention for Azure Resources based on the [Matroska naming convention](https://www.devjev.nl/posts/2022/the-perfect-azure-naming-convention/) proposed by Jev Suchoi.

## Requirements

| Name      | Version |
| --------- | ------- |
| Bicep CLI | 0.10.61 |

## Inputs

| Name             | Description                                      | Type   | Default | Required | Size | Allowed values          |
| ---------------- | ------------------------------------------------ | ------ | :-----: | :------: | :--: | ----------------------- |
| workloadAffix    | Business workload affix                          | string |   wl    |   yes    |  2   |                         |
| applicationSufix | Application sufix                                | string |   app   |   yes    |  3   |                         |
| environment      | Application environment                          | string |   exp   |   yes    |  3   | exp, dev, qua, uat, prd |
| instanceNumber   | Instance number of the resource on the lifecycle | string |   001   |    no    |  3   | Number on format 001    |

## Outputs

| Name                    | Description                   |
| ----------------------- | ----------------------------- |
| azContainerRegistryName | Azure Container Registry name |
