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
        ResourceName  = "kv-pesterrun-$RunId"
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

    $bicepFile = "$workingDir/src/iac/az-modules/az-resources/Microsoft.KeyVault/keyvault/main.bicep"

    az deployment group create `
        --resource-group $Context.ResourceGroup `
        --template-file $bicepFile `
        --name "pesterrun-$RunId" `
        --parameters `
        name=$resourceName `
        tags=$tags
}

Describe "Key Vault" -Tag keyvault {
    Context "Validate Key Vault" {

        It "Key Vault must no be null" {
            $sqlServer = az keyvault list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlServer | Should -Not -Be $null
        }
    }
}

AfterAll {
    # Remove the resource created during the test
    Write-Host "##[command]Removing resource group '$($Context.ResourceGroup)'..."

    az group delete -n $Context.ResourceGroup -y --no-wait
}
