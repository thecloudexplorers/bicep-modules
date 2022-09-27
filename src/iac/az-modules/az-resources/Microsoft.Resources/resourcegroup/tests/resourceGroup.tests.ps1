BeforeAll {

    # TODO: Load modules

    $PesterRunId = Get-Random -Minimum 00000 -Maximum 99999

    Write-Host "Pester Run Id: $PesterRunId"

    $Context = @{
        WorkloadAffix    = "wl"
        ApplicationSufix = "pst"
        Environment      = "exp"
        Template         = "./src/modules/Microsoft.Resources/resourceGroup/main.bicep"
        PesterRunId      = $PesterRunId
    }
}

Describe "Resource Group" -Tag resourceGroup {
    Context "Validate Resource Group" {
        It "Should be created successfully" {
            
            New-AzSubscriptionDeployment -Location westeurope `
                -TemplateFile ./src/modules/Microsoft.Resources/resourceGroup/main.bicep `
                -TemplateParameterFile ./src/modules/Microsoft.Resources/resourceGroup/examples/resourceGroup.parameters.json `
                -Tag @{"Test" = "true"; "Pester" = "true"; "PesterRunId" = "$($Context.PesterRunId)" }

            $resourceGroup = Get-AzResourceGroup -name "rg-test"
            
            $resourceGroup.ResourceGroupName | Should -Be "rg-test"
        }
    }
}

AfterAll {
    Write-Host "Removing resources..."

    # TODO: Change module to use Azure PowerShell instead of Azure CLI
    Import-Module ./pipelines/common/scripts/helpers/AzureHelpers.psm1

    Remove-ResourceGroupByName -name "rg-test"

    $resourceGroups = (az group list --query "[].[name]" -o tsv) 
    
    if ($resourceGroups.Count -eq 0) {
        Write-Error "No resource groups found"
    } else {       
        az group delete -n $name -y
    }
}