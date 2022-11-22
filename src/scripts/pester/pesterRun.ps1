param(
    [Parameter()]
    [string]$WorkingDirectory,
    [Parameter()]
    [string]$ModuleName
)

$container = New-PesterContainer -Path "*.tests.ps1" -Data @{ workingDir = $WorkingDirectory }

$config = New-PesterConfiguration
$config.TestResult.Enabled = $true
$config.TestResult.OutputFormat = "NUnitXML"

$config.TestResult.OutputPath = Join-Path "$WorkingDirectory" -ChildPath "testResults/testResults.xml"

$config.Run.Container = $container
$config.Output.Verbosity = "Detailed"

$tags = @("deployment", "azcli", "bicep")

if ($ModuleName -ne "all") {
    $tags += $ModuleName
}

$config.Filter.Tag = $tags

Invoke-Pester -Configuration $config
