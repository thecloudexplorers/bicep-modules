BeforeAll {

    # TODO: Load modules

    $Context = @{
        # WorkloadAffix    = "wl"
        # ApplicationSufix = "pst"
        # Environment      = "exp"
        Template      = "../main.bicep"
        ResourceGroup = "rg-bicepmodules"
    }
}

Describe "Log Analytics Workspace" -Tag logAnalyticsWorkspace, bicep, azcli {
    Context "Validate Log Analytics Workspace" {

        It "Deployment must be sucessfull" -Skip {
            # $deployment = New-AzDeployment  -Location westeurope `
            #     -TemplateFile $Context.Template `
            #     -workloadAffix $Context.WorkloadAffix `
            #     -applicationSufix $Context.ApplicationSufix `
            #     -environment $Context.Environment
            $deployment = az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.Template | ConvertFrom-Json

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
