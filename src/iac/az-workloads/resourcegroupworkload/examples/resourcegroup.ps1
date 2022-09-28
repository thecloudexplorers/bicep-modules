# Create resource group
az deployment sub create `
    -f ../resourcegroup.bicep `
    -l westeurope `
    -p workloadAffix=bp applicationSufix=tst
