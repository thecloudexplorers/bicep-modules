param (
    [Parameter(Mandatory = $true)][string]$ModuleName,
    [Parameter(Mandatory = $false)][string]$WorkingDirectory = "./"
)

# Find directory based on module name
$moduleDirectory = Get-ChildItem -Path "$WorkingDirectory/src/iac" -Filter $ModuleName -Recurse -Directory

& "$moduleDirectory/examples/runBicep-example.ps1"
