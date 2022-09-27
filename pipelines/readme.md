# Purpose

All pipelines should be placed in this folder. For each pipeline a subfolder should be created. THe one or more .yml files should be always placed in the root of the newly created folder.
If the pipeline depends on additional pipeline specific files (scripts) these should be placed in a subfolder within the pipeline folder.

> A readme.md containing the documentation for the pipeline in question should present in the root of hte pipeline folder.

Example structure:

```html
+-- pipelines
    |
    +-- management
    |   |
    |   +-- managementStructure.yml
    |   |
    |   +-- readme.md
    |   |
    |   +-- scripts
    |       |
    |       +-- azManagementStrucutre.ps1
    |       |
    |       +-- aadManagementStrucutre.ps1
    |
    +-- workload
    |   |
    |   +-- deploy-workload.yml
    |   |
    |   +-- readme.md
    |
    +-- microservice-deploy
    |   |
    |   +-- deploy-microservice.yml
    |   |
    |   +-- readme.md
    |   |
    |   +-- helm
    |       |
    |       +-- chart.yaml
    |       |
    |       +-- provider-class.yaml
    |
```
