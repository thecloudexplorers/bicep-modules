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
        PesterRunId   = "pesterrun-$RunId"

        Template      = "$workingDir/src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/main.bicep"
        ParameterFile = "$workingDir/src/iac/az-modules/az-resources/Microsoft.OperationalInsights/logAnalyticsWorkspace/tests/main.parameters.json"

        ResourceGroup = "rg-bicepmodules"
        ResourceName  = "log-pesterrun-$RunId"
        Location      = "westeurope"
        Tags          = $Tags
    }
}

Describe "Deployment" -Tag deployment, bicep, azcli {
    Context "Validate Bicep deployment on Azure" {

        It "Deployment must be sucessfull" {
            $resourceName = $Context.ResourceName | Out-String -Stream
            $tags = ($Context.Tags | ConvertTo-Json -Compress).Replace('"', "'")

            $deployment = az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.Template `
                --name $Context.PesterRunId `
                --parameters $Context.ParameterFile `
                --parameters `
                name=$resourceName `
                tags=$tags `
            | ConvertFrom-Json

            $deploymentState = $deployment.properties.provisioningState

            $deploymentState | Should -Be "Succeeded"
        }

        It "Resource must be created" {
            $resourceName = $Context.ResourceName | Out-String -Stream
            $runId = $Context.RunId | Out-String -Stream
            $resource = az resource list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$resourceName']" `
            | ConvertFrom-Json

            $resource.name | Should -Not -Be $null
        }
    }
}

Describe "Log Analytics Workspace" -Tag logAnalyticsWorkspace, bicep, azcli {
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
    # Remove the resource created with the tag PesterRunId
    Write-Host "Removing resources created by Pester"
    $tags = @{
        PesterRun   = "true"
        PesterRunId = $Context.RunId
    }

    $tagsParam = ($Tags.GetEnumerator() | ForEach-Object { "tags.$($_.Key) == '$($_.Value)'" }) -join ' && '

    $tagsParam = $tagsParam.Trim()

    az resource list `
        --query "[?$tagsParam].[name]" `
        -o tsv `
    | ForEach-Object {
        Write-Host "Removing resource $_"
        az resource delete -n "$_" -g $Context.ResourceGroup --resource-type "Microsoft.OperationalInsights/workspaces"
    }
}
