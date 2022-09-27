# Purpose

All bicep should be placed in this folder.

- Bicep files declaring individual reusable resources should be placed in az-resources
- Bicep modules should be placed in the az-module

Example structure:

```html
+-- iac
    |
    +-- az-modules
    |   |
    |   +-- resource-group-a-module
    |   |   |
    |   |   +-- resource-group-a-module.bicep
    |   |   |
    |   |   +-- resource-group-a-module.tests.ps1
    |   |
    |   |
    |   +-- resource-group-b-module
    |       |
    |       +-- resource-group-b-module.bicep
    |       |
    |       +-- resource-group-b-module.tests.ps1
    |
    +-- az-resources
    |   |
    |   +-- aks
    |   |   |
    |   |   +-- aks.bicep
    |   |   |
    |   |   +-- aks-example.bicep
    |   |   |
    |   |   +-- aks.tests.ps1
    |   |
    |   +-- key-vault
    |   |   |
    |   |   +-- key-vault.bicep
    |   |   |
    |   |   +-- key-vault-example.bicep
    |   |   |
    |   |   +-- key-vault.tests.ps1
    |   |
    |   +-- app-insights
    |   |   |
    |   |   +-- app-insights.bicep
    |   |   |
    |   |   +-- app-insights-example.bicep
    |   |   |
    |   |   +-- app-insights.tests.ps1
    |   |
    |   +-- law
    |   |   |
    |   |   +-- law.bicep
    |   |   |
    |   |   +-- law-example.bicep
    |   |   |
    |   |   +-- law.tests.ps1
    |
```
