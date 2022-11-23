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
        ResourceGroup = "rg-bicepmodules-$RunId"
        ResourceName  = "log-pesterrun-$RunId"
        Location      = "westeurope"
        Tags          = $Tags
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

    az deployment group create `
        --resource-group $Context.ResourceGroup `
        --template-file "$workingDir/src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/main.bicep" `
        --name "pesterrun-$RunId" `
        --parameters "$workingDir/src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/tests/main.parameters.json" `
        --parameters `
        name=$resourceName `
        tags=$tags
}

Describe "Log Analytics Workspace" -Tag loganalyticsworkspace {
    Context "Validate Log Analytics Workspace" {

        It "Log Analytics must no be null" {
            $logAnalytics = az monitor log-analytics workspace list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $logAnalytics | Should -Not -Be $null
        }

        It "Log Analytics must have the correct name" {
            $logAnalytics = az monitor log-analytics workspace list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $logAnalytics.name | Should -Be $Context.ResourceName
        }

        It "Log Analytics must have the correct location" {
            $logAnalytics = az monitor log-analytics workspace list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $logAnalytics.location | Should -Be $Context.Location
        }

        It "Log Analytics must have the correct sku" {
            $logAnalytics = az monitor log-analytics workspace list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $logAnalytics.sku.name | Should -Be "PerGB2018"
        }
    }
}

AfterAll {
    # Remove the resource created during the test
    Write-Host "##[command]Removing resource group '$($Context.ResourceGroup)'..."

    az group delete -n $Context.ResourceGroup -y
}
