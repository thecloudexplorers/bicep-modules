[CmdletBinding()]

param (
    [ValidateSet("AzureContainerRegistry", "LocalRepository")]
    [Parameter(Mandatory = $false)][string]$ModulesSource = "LocalRepository",
    [Parameter(Mandatory = $false)][string]$Region = "westeurope"
)

$randomId = Get-Random -Minimum 1000 -Maximum 9999
$moduleName = "sqldatabase"
$resourceGroup = "rg-bicepmodules-$moduleName-$randomId"
$password = '$ecUreP@ssw0rd'
$sqlServerAdmin = "adminuser"
$sQLServerName = "sql-example-$randomId"

if ($ModulesSource -eq "AzureContainerRegistry") {
    $bicepFile = "acr-example.bicep"
} else {
    $bicepFile = "local-example.bicep"
}

Set-Location $PSScriptRoot

# Create dependencies

# Create resource group to run tests in
az group create -n $resourceGroup -l $Region

# Create SQL Server dependency
$sqlServerBicepFile = "../../sqlserver/main.bicep"

az deployment group create `
    --resource-group $resourceGroup `
    --template-file $sqlServerBicepFile `
    --name "example-$randomId" `
    --parameters `
    name=$sQLServerName `
    administratorLogin=$sqlServerAdmin `
    administratorLoginPassword=$password

# Execute bicep deploy
az deployment group create `
    -f $PSScriptRoot/$bicepFile `
    -g $resourceGroup `
    --parameters sqlServerName=$sQLServerName
