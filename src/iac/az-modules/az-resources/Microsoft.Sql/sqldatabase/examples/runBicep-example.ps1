$randomId = Get-Random -Minimum 1000 -Maximum 9999
$resourceGroup = "rg-bicepmodules-$ModuleName-$randomId"
$region = "westeurope"
$password = '$ecUreP@ssw0rd'
$sqlServerAdmin = "adminuser"
$sQLServerName = "sql-example-$randomId"

Set-Location $PSScriptRoot

az group create -n $resourceGroup -l $region

$sqlServerBicepFile = "../../sqlserver/main.bicep"

az deployment group create `
    --resource-group $resourceGroup `
    --template-file $sqlServerBicepFile `
    --name "example-$randomId" `
    --parameters `
    name=$sQLServerName `
    administratorLogin=$sqlServerAdmin `
    administratorLoginPassword=$password

az deployment group create -f $PSScriptRoot/example.bicep -g rg-bicepexample
