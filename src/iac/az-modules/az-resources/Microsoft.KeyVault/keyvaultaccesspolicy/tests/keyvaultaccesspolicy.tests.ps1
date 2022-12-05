param(
    [Parameter()]
    [string]$workingDir,
    [Parameter()]
    [string]$PersistDependencies = $false
)

BeforeAll {

    # TODO: Load modules

    # Randon id to avoid collisions
    $RunId = (Get-Random -Minimum 1000 -Maximum 9999)

    if ($PersistDependencies) {
        if ($env:Pester_Run_Id) {
            $RunId = $env:Pester_Run_Id
            $existingRunId = $true
        } else {
            $env:Pester_Run_Id = $RunId
        }
    }

    $Tags = @(
        "PesterRun=true"
        "PesterRunId=$RunId"
        "ToRemove=true"
    )

    $moduleName = "kvaccesspolicy"

    if ($env:servicePrincipalId) {
        $currentUserId = $env:servicePrincipalId
    } else {
        Write-Host "##[command]Obtaining AAD ObjectId from current user" -ForegroundColor Blue
        $currentUserId = az ad signed-in-user show --query "[id]" -o tsv
    }

    $Context = [PSCustomObject]@{
        ResourceGroup = "rg-bicepmodules-$RunId"
        ResourceName  = "kv-pesterrun-$RunId"
        Location      = "westeurope"
        Tags          = $Tags
        ModuleName    = $moduleName
        KeyVaultName  = "kv-$moduleName-$RunId"
        CurrentUserId = $currentUserId
        BicepFile     = "$workingDir/src/iac/az-modules/az-resources/Microsoft.KeyVault/keyvaultaccesspolicy/keyvaultaccesspolicy.bicep"
    }

    if ($existingRunId) {
        Write-Host "##[command]Using existing dependencies" -ForegroundColor Blue
    } else {
        Write-Host "##[command]Provisioning dependencies" -ForegroundColor Blue
        Write-Host "##[command]Provisioning resource group" -ForegroundColor Blue
        az group create `
            -n $Context.ResourceGroup `
            -l $Context.Location `
            --tags $Context.Tags

        Write-Host "##[command]Provisioning Key Vault" -ForegroundColor Blue
        az keyvault create `
            -g $Context.ResourceGroup `
            -n $Context.KeyVaultName `
            -l $Context.Location `
            --no-self-perms `
            --tags $Context.Tags
    }

    Write-Host "##[session]Context variables:" -ForegroundColor Green
    Write-Host ($Context | Format-List | Out-String) -ForegroundColor Green
}


Describe "Key Vault" -Tag keyvaultaccesspolicy {
    BeforeEach {
        # TODO: Recreate key vault for each test
        Write-Host $Context.ResourceName

        # Clean up policies before each test
        az keyvault set-policy `
            -n $Context.KeyVaultName `
            --object-id $Context.CurrentUserId `
            --secret-permissions `
            --certificate-permissions `
            --key-permissions
    }

    Context "Validate Key Vault" {

        It "Key Vault must no be null" -Skip {
            $sqlServer = az keyvault list `
                --resource-group $Context.ResourceGroup `
                --query "[?name=='$($Context.ResourceName)']" `
            | ConvertFrom-Json -AsHashtable

            $sqlServer | Should -Not -Be $null
        }

        It "Key Vault must have the get and list secret permissions only" {

            $secretPermissions = @("get", "list")

            $deniedPermissions = @("backup", "delete", "recover", "restore", "set", "purge")

            $secretPermissionsJson = ($secretPermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                secretsAuthorization=$secretPermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $secretPermissions) {
                $currentUserPolicies.permissions.secrets | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check permissions that should be denied
            foreach ($permission in $deniedPermissions) {
                $currentUserPolicies.permissions.secrets | Where-Object { $_ -eq $permission } | Should -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.keys | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.certificates | Should -BeNullOrEmpty
        }

        It "Key Vault must have all secret permissions" {
            $secretPermissions = @("get", "list", "backup", "delete", "recover", "restore", "set", "purge")

            $secretPermissionsJson = ($secretPermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                secretsAuthorization=$secretPermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $secretPermissions) {
                $currentUserPolicies.permissions.secrets | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.keys | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.certificates | Should -BeNullOrEmpty
        }

        It "Key Vault must have get and list key permissions only" {
            $keyPermissions = @("get", "list")

            $deniedPermissions = @("backup", "create", "delete", "decrypt", "encrypt", "import", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey")

            $keyPermissionsJson = ($keyPermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                keysAuthorization=$keyPermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $keyPermissions) {
                $currentUserPolicies.permissions.keys | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check permissions that should be denied
            foreach ($permission in $deniedPermissions) {
                $currentUserPolicies.permissions.keys | Where-Object { $_ -eq $permission } | Should -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.secrets | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.certificates | Should -BeNullOrEmpty
        }

        It "Key Vault must have all key permissions" {
            $keyPermissions = @("get", "list", "backup", "create", "delete", "decrypt", "encrypt", "import", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey")

            $keyPermissionsJson = ($keyPermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                keysAuthorization=$keyPermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $keyPermissions) {
                $currentUserPolicies.permissions.keys | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.secrets | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.certificates | Should -BeNullOrEmpty
        }

        It "Key Vault must have get and list certificate permissions only" {
            $certificatePermissions = @("get", "list")

            $deniedPermissions = @("backup", "create", "delete", "deleteissuers", "getissuers", "import", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update")

            $certificatePermissionsJson = ($certificatePermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                certificatesAuthorization=$certificatePermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $certificatePermissions) {
                $currentUserPolicies.permissions.certificates | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check permissions that should be denied
            foreach ($permission in $deniedPermissions) {
                $currentUserPolicies.permissions.certificates | Where-Object { $_ -eq $permission } | Should -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.secrets | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.keys | Should -BeNullOrEmpty
        }

        It "Key Vault must have all certificate permissions" {
            $certificatePermissions = @("get", "list", "backup", "create", "delete", "deleteissuers", "getissuers", "import", "listissuers", "managecontacts", "manageissuers", "purge", "recover", "restore", "setissuers", "update")

            $certificatePermissionsJson = ($certificatePermissions | ConvertTo-Json -Compress).Replace('"', "'")

            Write-Host "##[command]Provisioning key vault access policy" -ForegroundColor Blue
            az deployment group create `
                --resource-group $Context.ResourceGroup `
                --template-file $Context.BicepFile `
                --name $Context.ResourceName `
                --parameters `
                keyVaultName=$($Context.KeyVaultName) `
                objectId=$($Context.CurrentUserId) `
                certificatesAuthorization=$certificatePermissionsJson

            $keyvault = az keyvault show -n $Context.KeyVaultName | ConvertFrom-Json -Depth 10
            $currentUserPolicies = $keyvault.properties.accessPolicies | Where-Object { $_.objectId -eq "$($Context.CurrentUserId)" }

            # Check permissions that should be granted
            foreach ($permission in $certificatePermissions) {
                $currentUserPolicies.permissions.certificates | Where-Object { $_ -eq $permission } | Should -Not -Be $null
            }

            # Check that no other permissions are granted
            $currentUserPolicies.permissions.secrets | Should -BeNullOrEmpty
            $currentUserPolicies.permissions.keys | Should -BeNullOrEmpty
        }
    }

    AfterAll {

        if ($PersistDependencies) {
            Write-Host "##[warning]Persisting dependencies set 'true'" -ForegroundColor Yellow
            Write-Host "##[warning]Resource group '$($Context.ResourceGroup)' will not be deleted, it must be deleted manually later on..." -ForegroundColor Yellow
        } else {
            # Remove the resource created during the test
            Write-Host "##[warning]Removing resource group '$($Context.ResourceGroup)'..."
            az group delete -n $Context.ResourceGroup -y --no-wait
            $env:Pester_Run_Id = $null
        }
    }
}
