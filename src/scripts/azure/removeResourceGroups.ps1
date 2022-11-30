# TODO: Create powershell module
function Remove-ResourceGroup {
    param (
        [hashtable]$Tags,
        [bool]$IsDryRun = $true,
        [bool]$SkipConfirmation = $false
    )

    # Return if no tags are provided
    if ($Tags.Count -eq 0) {
        Write-Host "No tags provided, skipping..."
        return
    }

    ($Tags.GetEnumerator() | ForEach-Object { "tags.$($_.Key) == '$($_.Value)'" }) -join ' && '

    $tagsParam = ($Tags.GetEnumerator() | ForEach-Object { "tags.$($_.Key) == '$($_.Value)'" }) -join ' && '

    $tagsParam = $tagsParam.Trim()

    $resourceGroups = az group list `
        --query "[?$tagsParam].[name]" `
        -o tsv

    if ($resourceGroups) {
        Write-Host "The following resource groups will be removed:" -ForegroundColor Yellow
        $resourceGroups | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }

        if (-not $SkipConfirmation) {
            $confirmation = Read-Host "Do you want to continue? (y/n)"
            if ($confirmation -ne "y") {
                Write-Host "Exiting..." -ForegroundColor Red
                return
            }
        }

        $resourceGroups | ForEach-Object {
            if ($IsDryRun) {
                Write-Host "[Dry run execution]" -ForegroundColor Yellow
                Write-Host "Would remove resource group: $_" -ForegroundColor Yellow
            } else {
                Write-Host "Removing resource group: $_" -ForegroundColor Yellow
                az group delete `
                    --name $_ `
                    --yes `
                    --no-wait
            }
        }
    } else {
        Write-Host "No resource groups found with tags: $($Tags | ConvertTo-Json -Compress)"
    }
}

$tags = @{
    ToRemove = "true"
}

Remove-ResourceGroup -Tags $tags -IsDryRun $false -SkipConfirmation $true
