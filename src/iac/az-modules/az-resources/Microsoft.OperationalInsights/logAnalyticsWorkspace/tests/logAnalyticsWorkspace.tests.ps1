BeforeAll {

    # TODO: Load modules

    $Context = @{
        # TODO: Parametrize for local testing
        Template      = "src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/main.bicep"
        ResourceGroup = "rg-bicepmodules"
        # Randon id to avoid collisions
        RunId         = (Get-Random -Minimum 1000 -Maximum 9999)
    }
}

Describe "Log Analytics Workspace" -Tag logAnalyticsWorkspace, bicep, azcli {
    Context "Validate Log Analytics Workspace" {

        It "Deployment must be sucessfull" {
            $runId = $Context.RunId
            $tags = "{'PesterRun':'true','Cost Center':'2345-324','PesterRunId':'$($Context.RunId)'}"
            $deployment = az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.Template `
                --name pesterRun-$Context.RunId `
                --parameters `
                    name="log-pesterrun-$runId" `
                    location="westeurope" `
                    sku="PerGB2018" `
                    tags=$tags `
            | ConvertFrom-Json

            $deploymentState = $deployment.properties.provisioningState

            $deploymentState | Should -Be "Succeeded"
        }

        It "Log Analytics must no be null" {
            $logAnalytics = az monitor log-analytics workspace list `
                --resource-group $Context.ResourceGroup `
            | ConvertFrom-Json -AsHashtable

            $logAnalytics | Should -Not -Be $null
        }
    }
}

AfterAll {
    # Remove the resource created with the tag PesterRunId
    Write-Host "Removing resources created by Pester"
    Write-Host az resource list --tag PesterRunId=$Context.RunId --query "[].id" -o tsv #| ForEach-Object { az resource delete --ids $_ }
}
