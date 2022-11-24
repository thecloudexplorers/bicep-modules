param (
    [Parameter(Mandatory = $true)][string]$ModuleName,
    [Parameter(Mandatory = $false)][string]$WorkingDirectory = "./"
)

# Find directory based on module name
$moduleDirectory = Get-ChildItem -Path "$WorkingDirectory/src/iac" -Filter $ModuleName -Recurse -Directory

$RunId = (Get-Random -Minimum 1000 -Maximum 9999)

$resourceGroup = "rg-bicepmodules-$ModuleName-$RunId"

Write-Host "Creating resource group: $resourceGroup"

az group create `
    -n $resourceGroup `
    -l westeurope `
    --tags `
    PesterRun="true" `
    PesterRunId="local"

az deployment group create -f "$($moduleDirectory.FullName)/main.bicep" -g $resourceGroup
