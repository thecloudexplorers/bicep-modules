param (
    [Parameter(Mandatory = $true)][string]$ModuleName,
    [Parameter(Mandatory = $false)][string]$WorkingDirectory = "./"
)

# Find directory based on module name
$moduleDirectory = Get-ChildItem -Path "$WorkingDirectory/src/iac" -Filter $ModuleName -Recurse -Directory

$exampleRun = "$moduleDirectory/examples/runBicep-example.ps1"

if (Test-Path($exampleRun)) {
    Write-Host "Running example for module: $ModuleName"
    & $exampleRun
} else {
    $exampleRun = "$moduleDirectory/examples/run-bicep-example.ps1"
    Write-Host "Running example for module: $ModuleName"
    & $exampleRun
}
