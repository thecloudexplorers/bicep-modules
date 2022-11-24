param(
    [Parameter()]
    [string]$workingDir
)


BeforeAll {

    # TODO: Load modules

    # Randon id to avoid collisions
    $RunId = (Get-Random -Minimum 1000 -Maximum 9999)

    $Tags = @{
        PesterRun   = 'true'
        PesterRunId = "$RunId"
    }

    $SQLServerName = "sql-pesterrun-$RunId"

    $Context = @{
        SQLServerName      = $SQLServerName
        ResourceGroup      = "rg-bicepmodules-$RunId"
        ResourceName       = "database-pesterrun-$RunId"
        Location           = "westeurope"
        Tags               = $Tags
        administratorLogin = "adminuser"
    }

    # Create resource group to run tests in
    Write-Host "##[command]Creating resource group $($Context.ResourceGroup)..."
    $tags = ($Context.Tags | ConvertTo-Json -Compress).Replace('"', "'")
    $resourceGroup = ($Context.ResourceGroup | ConvertTo-Json -Compress)

    az deployment sub create `
        --location $Context.Location `
        --template-file "$workingDir/src/iac/az-modules/az-resources/Microsoft.Resources/resourcegroup/main.bicep" `
        --name "pesterrun-$RunId" `
        --parameters `
        name=$resourceGroup `
        tags=$tags

    # Execute bicep deploy
    Write-Host "##[command]Creating bicep deployment dependencies - Scope '$($Context.SQLServerName)'..."
    $tags = ($Context.Tags | ConvertTo-Json -Compress).Replace('"', "'")

    $password = '$ecUreP@ssw0rd'

    $bicepFile = "$workingDir/src/iac/az-modules/az-resources/Microsoft.Sql/sqlserver/main.bicep"


    az deployment group create `
        --resource-group $Context.ResourceGroup `
        --template-file $bicepFile `
        --name "pesterrun-$RunId" `
        --parameters `
        name=$SQLServerName `
        tags=$tags `
        administratorLogin=$Context.administratorLogin `
        administratorLoginPassword=$password

    Write-Host "##[command]Executing bicep deployment - Scope '$($Context.ResourceName)'..."
    $resourceName = $Context.ResourceName | Out-String -Stream
    $tags = ($Context.Tags | ConvertTo-Json -Compress).Replace('"', "'")

    $bicepFile = "$workingDir/src/iac/az-modules/az-resources/Microsoft.Sql/sqldatabase/main.bicep"

    az deployment group create `
        --resource-group $Context.ResourceGroup `
        --template-file $bicepFile `
        --name "pesterrun-$RunId" `
        --parameters `
        name=$resourceName `
        tags=$tags `
        sqlServerName=$SQLServerName
}

Describe "SQL Database" -Tag sqldatabase, bicep, azcli {
    Context "Validate SQL Database" {

        It "SQL Database must no be null" {
            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.SQLServerName `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlDb | Should -Not -Be $null
        }

        It "SQL Database must have the correct location" {
            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.SQLServerName `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlDb.location | Should -Be $Context.Location
        }

        It "Database must have the diagnotics settings" {

            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.SQLServerName `
                --query "[?name=='master']" `
            | ConvertFrom-Json -AsHashtable

            $diagnosticSettings = az monitor diagnostic-settings categories list `
                --resource $sqlDb.id `
            | ConvertFrom-Json -AsHashtable

            $diagnosticSettings | Should -Not -Be $null
        }

        It "Database must have the correct sku" {

            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.SQLServerName `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlDb.sku.name | Should -Be "Basic"
        }
    }
}

AfterAll {
    # Remove the resource created during the test
    Write-Host "##[command]Removing resource group '$($Context.ResourceGroup)'..."

    az group delete -n $Context.ResourceGroup -y --no-wait
}
