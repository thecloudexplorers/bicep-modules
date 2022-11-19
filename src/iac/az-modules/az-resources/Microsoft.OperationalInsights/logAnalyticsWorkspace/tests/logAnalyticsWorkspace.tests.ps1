BeforeAll {

    # TODO: Load modules

    $Context = @{
        # TODO: Parametrize for local testing
        Template      = "src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/main.bicep"
        ResourceGroup = "rg-bicepmodules"
    }
}

Describe "Log Analytics Workspace" -Tag logAnalyticsWorkspace, bicep, azcli {
    Context "Validate Log Analytics Workspace" {

        It "Deployment must be sucessfull" {

            $tags = "{'PesterRun':'true','Cost Center':'2345-324'}"
            $deployment = az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.Template `
                --parameters `
                    name="log-pesterrun" `
                    location="westeurope" `
                    sku="PerGB2018" `
                    resourceTags=$tags `
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
