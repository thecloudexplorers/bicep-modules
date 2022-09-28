BeforeAll {

    # TODO: Load modules

    $Context = @{
        WorkloadAffix    = "wl"
        ApplicationSufix = "pst"
        Environment      = "exp"
        Template         = "./src/modules/NamingConvention/namingConventionResources/main.bicep"
    }
}

Describe "Naming Convention Azure Resources" -Tag namingConventionResources {
    Context "Validate Naming Convention for Azure Container Registry" {
        It "Should Not be null" {
            $deployment = New-AzSubscriptionDeployment -Location westeurope `
                -TemplateFile $Context.Template `
                -workloadAffix $Context.WorkloadAffix `
                -applicationSufix $Context.ApplicationSufix `
                -environment $Context.Environment
                                
            $resourceGroupName = $deployment.outputs['azContainerRegistryName'].Value
                       
            $resourceGroupName | Should -Not -Be $null
        }

        It "Should contains workload" {
            $deployment = New-AzSubscriptionDeployment -Location westeurope `
                -TemplateFile $Context.Template `
                -workloadAffix $Context.WorkloadAffix `
                -applicationSufix $Context.ApplicationSufix `
                -environment $Context.Environment 
                
            $resourceGroupName = $deployment.outputs['azContainerRegistryName'].Value
                       
            $resourceGroupName | Should -BeLike "$($Context.WorkloadAffix)-*"
        }

        It "Should contains application" {
            $deployment = New-AzSubscriptionDeployment -Location westeurope `
                -TemplateFile $Context.Template `
                -workloadAffix $Context.WorkloadAffix `
                -applicationSufix $Context.ApplicationSufix `
                -environment $Context.Environment 
                
            $resourceGroupName = $deployment.outputs['azContainerRegistryName'].Value
                       
            $resourceGroupName | Should -BeLike "*-$($Context.ApplicationSufix)-*"
        }

        It "Should contains environment" {
            $deployment = New-AzSubscriptionDeployment -Location westeurope `
                -TemplateFile $Context.Template `
                -workloadAffix $Context.WorkloadAffix `
                -applicationSufix $Context.ApplicationSufix `
                -environment $Context.Environment 
                
            $resourceGroupName = $deployment.outputs['azContainerRegistryName'].Value
                       
            $resourceGroupName | Should -BeLike "*-$($Context.Environment)-*"
        }
        
    }
}