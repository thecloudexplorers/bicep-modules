param (
    [Parameter()]
    [string]$ResourceGroupsToRemove
)

# TODO: Create powershell module
function Remove-ResourceGroup {
    param (
        [hashtable]$Tags,
        [bool]$IsDryRun = $true
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
    PesterRun = "true"
}

if ($ResourceGroupsToRemove -eq "local") {
    $tags.PesterRunId = "local"
}

Remove-ResourceGroup -Tags $tags -IsDryRun $false
