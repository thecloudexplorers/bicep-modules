# Azure Bicep Modules

This repository is contains Azure Bicep Modules that can be reused.

The repository is organized in modules and workloads.

## Modules
Modules contains low level implementation of Azure resources, it contains ideally one resource, which must be combined with other resources at Workload level. In certain cases, for some resources might be necessary include extra resources.

## Workloads

Workloads are sets of Azure resources that supports a defined process. In this repository Azure Modules are combined to create Workloads that can be reused in during the deployments.
