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

    $Context = @{
        ResourceGroup      = "rg-bicepmodules-$RunId"
        ResourceName       = "sql-pesterrun-$RunId"
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
    Write-Host "##[command]Executing bicep deployment - Scope '$($Context.ResourceName)'..."
    $resourceName = $Context.ResourceName | Out-String -Stream
    $tags = ($Context.Tags | ConvertTo-Json -Compress).Replace('"', "'")

    $password = '$ecUreP@ssw0rd'

    $bicepFile = "$workingDir/src/iac/az-modules/az-resources/Microsoft.Sql/sqlserver/main.bicep"

    az deployment group create `
        --resource-group $Context.ResourceGroup `
        --template-file $bicepFile `
        --name "pesterrun-$RunId" `
        --parameters `
        name=$resourceName `
        tags=$tags `
        administratorLogin=$Context.administratorLogin `
        administratorLoginPassword=$password
}

Describe "SQL Server" -Tag sqlserver, bicep, azcli {
    Context "Validate SQL Server" {

        It "SQL Server must no be null" {
            $sqlServer = az sql server list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlServer | Should -Not -Be $null
        }

        It "SQL Server must have the correct location" {
            $sqlServer = az sql server list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlServer.location | Should -Be $Context.Location
        }

        It "SQL must contain master database" {
            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.ResourceName `
                --query "[?name=='master']" `

            $sqlDb | Should -Not -Be $null
        }

        It "Master database must have the diagnotics settings" {

            $sqlDb = az sql db list `
                --resource-group $Context.ResourceGroup `
                --server $Context.ResourceName `
                --query "[?name=='master']" `
            | ConvertFrom-Json -AsHashtable

            $diagnosticSettings = az monitor diagnostic-settings categories list `
                --resource $sqlDb.id `
            | ConvertFrom-Json -AsHashtable

            $diagnosticSettings | Should -Not -Be $null
        }

        It "SQL Server must allow azure services to access" {
            $firewallRule = az sql server firewall-rule list `
                --resource-group $Context.ResourceGroup `
                --server $Context.ResourceName `
                --query "[?name=='AllowAllWindowsAzureIps']" `
            | ConvertFrom-Json -AsHashtable

            $firewallRule.startIpAddress | Should -Be "0.0.0.0"
            $firewallRule.endIpAddress | Should -Be "0.0.0.0"
        }

        It "Sql server must have public network access enabled" {
            $sqlServer = az sql server show `
                --resource-group $Context.ResourceGroup `
                --name $Context.ResourceName `
            | ConvertFrom-Json -AsHashtable

            $sqlServer.publicNetworkAccess | Should -Be "Enabled"
        }

        It "Sql server must have minimal TLS version" {
            $sqlServer = az sql server show `
                --resource-group $Context.ResourceGroup `
                --name $Context.ResourceName `
            | ConvertFrom-Json -AsHashtable

            $sqlServer.minimalTlsVersion | Should -Be "1.2"
        }
    }
}

AfterAll {
    # Remove the resource created during the test
    Write-Host "##[command]Removing resource group '$($Context.ResourceGroup)'..."

    az group delete -n $Context.ResourceGroup -y --no-wait
}
