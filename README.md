# Azure Bicep Modules

This repository is contains Azure Bicep Modules that can be reused.

The repository is organized in modules and workloads.

  - [Modules](#modules)
  - [Workloads](#workloads)
  - [Available Modules](#available-modules)
    - [Naming Convention](#naming-convention)
    - [Azure Resources](#azure-resources)
  - [Available Workloads](#available-workloads)

## Modules
Modules contains low level implementation of Azure resources, it contains ideally one resource, which must be combined with other resources at Workload level. In certain cases, for some resources might be necessary include extra resources.

## Workloads

Workloads are sets of Azure resources that supports a defined process. In this repository Azure Modules are combined to create Workloads that can be reused in during the deployments.

## Available Modules

### Naming Convention
- [Resource Group Naming Convention](src/iac/az-modules/az-naming-convention/namingconventionresourcegroup/README.md)
- [Resource Group Naming Convention](src/iac/az-modules/az-naming-convention/namingConventionResources/README.md)

### Azure Resources
- [Resource Group](src/iac/az-modules/az-resources/Microsoft.Resources/resourcegroup/README.md)
- [Azure Container Registry](src/iac/az-modules/az-resources/Microsoft.ContainerRegistry/registry/README.md)

## Available Workloads

- [Bootstrap Bicep Registry](src\iac\az-workloads\bicepregistry\README.md)
