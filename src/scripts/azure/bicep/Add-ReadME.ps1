# Based on script created by Maik van der Gaag (https://msftplayground.com/2021/02/markdown-generation-for-arm-and-powershell/)

Param (
    [Parameter(Mandatory = $true)][string]$ModuleName,
    [Parameter(Mandatory = $false)][string]$WorkingDirectory = "./",
    [Parameter(Mandatory = $false)][string]$OutputFolder = "./",
    [Parameter(Mandatory = $false)][string]$ExcludeFolders,
    [Parameter(Mandatory = $false)][bool]$KeepStructure = $false,
    [Parameter(Mandatory = $false)][bool]$IncludeWikiTOC = $false
)

BEGIN {
    Write-Output ("ModuleName           : $($ModuleName)")
    Write-Output ("WorkingDirectory     : $($WorkingDirectory)")
    Write-Output ("OutputFolder         : $($OutputFolder)")
    Write-Output ("ExcludeFolders       : $($ExcludeFolders)")
    Write-Output ("KeepStructure        : $($KeepStructure)")
    Write-Output ("IncludeWikiTOC       : $($IncludeWikiTOC)")

    $option = [System.StringSplitOptions]::RemoveEmptyEntries
    $exclude = $ExcludeFolders.Split(',', $option)

    function Build-BicepFiles {
        param (
            [Parameter(Mandatory = $true)][string]$ModuleDirectory
        )

        # Get module directory
        Write-Host "Building Bicep files..."
        if (Test-Path "$($ModuleDirectory)/main.bicep") {
            $bicepFile = "$($ModuleDirectory)/main.bicep"
        } else {
            $bicepFile = "$($ModuleDirectory)/$ModuleName.bicep"
        }

        az bicep build --file $bicepFile
    }

    function  Get-ModuleDirectory {
        param (
            [Parameter(Mandatory = $true)][string]$WorkingDirectory
        )

        Write-Host "Getting module directory..."
        return Get-ChildItem -Path "$WorkingDirectory/src/iac" -Filter $ModuleName -Recurse -Directory
    }
}
PROCESS {
    try {
        Write-Information ("Starting documentation generation for folder $($WorkingDirectory)")

        if (!(Test-Path $OutputFolder)) {
            Write-Information ("Output path does not exists creating the folder: $($OutputFolder)")
            New-Item -ItemType Directory -Force -Path $OutputFolder
        }

        # Get module directory
        $moduleDirectory = Get-ModuleDirectory -WorkingDirectory $WorkingDirectory

        $OutputFolder = $moduleDirectory.FullName

        # Generate ARM Templates from bicep files
        Build-BicepFiles -ModuleDirectory $moduleDirectory

        # Get the scripts from the folder
        $templates = Get-ChildItem $moduleDirectory -Filter "*.json" -Recurse -Exclude "*parameters.json", "*descriptions.json", "*parameters.local.json", "*version.json", "*bicepconfig.json"

        foreach ($template in $templates) {
            if (!$exclude.Contains($template.Directory.Name)) {
                Write-Information ("Documenting file: $($template.FullName)")

                if ($KeepStructure) {
                    if ($template.DirectoryName -ne $moduleDirectory) {
                        $newfolder = $OutputFolder + "/" + $template.Directory.Name
                        if (!(Test-Path $newfolder)) {
                            Write-Information ("Output folder for item does not exists creating the folder: $($newfolder)")
                            New-Item -Path $OutputFolder -Name $template.Directory.Name -ItemType "directory"
                        }
                    }
                } else {
                    $newfolder = $OutputFolder
                }

                $templateContent = Get-Content $template.FullName -Raw -ErrorAction Stop
                $templateObject = ConvertFrom-Json $templateContent -ErrorAction Stop

                if (!$templateObject) {
                    Write-Error -Message ("ARM Template file is not a valid json, please review the template")
                } else {
                    $outputFile = ("$($newfolder)/README.md")
                    Out-File -FilePath $outputFile
                    if ($IncludeWikiTOC) {
                        ("[[_TOC_]]`n") | Out-File -FilePath $outputFile
                        "`n" | Out-File -FilePath $outputFile -Append
                    }

                    if ((($templateObject | Get-Member).name) -match "metadata") {
                        # if ((($templateObject.metadata | Get-Member).name) -match "description") {
                        if ((($templateObject.metadata | Get-Member).name) -match "module") {
                            Write-Verbose ("Description found. Adding to parent page and top of the arm-template specific page")
                            ("# $($templateObject.metadata.module.displayName) Bicep module") | Out-File -FilePath $outputFile -Append
                            ("---`n") | Out-File -FilePath $outputFile -Append

                            ("## Purpose") | Out-File -FilePath $outputFile -Append
                            $templateObject.metadata.module.description | Out-File -FilePath $outputFile -Append

                            "`n## Info" | Out-File -FilePath $outputFile -Append
                            "**Module Name**: $($templateObject.metadata.module.name)" | Out-File -FilePath $outputFile -Append
                            "**Module Version**: $($templateObject.metadata.module.version)`n" | Out-File -FilePath $outputFile -Append
                        }

                        ("## Requirements") | Out-File -FilePath $outputFile -Append
                        $metadataProperties = $templateObject.metadata | Get-Member | Where-Object MemberType -EQ NoteProperty
                        $moduleMetadata = $metadataProperties | Where-Object { $_.Name -eq "_generator" }

                        foreach ($metadata in $moduleMetadata.Name) {
                            switch ($metadata) {
                                "Description" {
                                    Write-Verbose ("already processed the description. skipping")
                                }
                                Default {
                                    ("`n") | Out-File -FilePath $outputFile -Append
                                    $requirementHeader = "| Name | Version |"
                                    $requirementHeaderDivider = "| --- | --- |"
                                    $requirementHeaderRow = " | Bicep | $($templateObject.metadata.$metadata.version) |"

                                    $StringBuilderRequirments = @()
                                    $StringBuilderRequirments += $requirementHeader
                                    $StringBuilderRequirments += $requirementHeaderDivider
                                    $StringBuilderRequirments += $requirementHeaderRow

                                    $StringBuilderRequirments | Out-File -FilePath $outputFile -Append
                                }
                            }
                        }
                    }

                    ("## Examples") | Out-File -FilePath $outputFile -Append

                    if (Test-Path "$moduleDirectory\examples\local-example.bicep") {
                        ('### Bicep - Local repository') | Out-File -FilePath $outputFile -Append
                        $bicepExampleSringBuilder = @()
                        $bicepExampleSringBuilder += '```bicep'

                        Get-Content $moduleDirectory\examples\local-example.bicep | ForEach-Object {
                            $bicepExampleSringBuilder = $bicepExampleSringBuilder + $_
                        }

                        $bicepExampleSringBuilder += '```'
                        $bicepExampleSringBuilder | Out-File -FilePath $outputFile -Append
                    }

                    if (Test-Path "$moduleDirectory\examples\acr-example.bicep") {
                        ('### Bicep - Azure Container Registry') | Out-File -FilePath $outputFile -Append
                        $bicepExampleSringBuilder = @()
                        $bicepExampleSringBuilder += '```bicep'

                        Get-Content $moduleDirectory\examples\acr-example.bicep | ForEach-Object {
                            $bicepExampleSringBuilder = $bicepExampleSringBuilder + $_
                        }

                        $bicepExampleSringBuilder += '```'
                        $bicepExampleSringBuilder | Out-File -FilePath $outputFile -Append
                    }

                    if (Test-Path "$moduleDirectory\examples\runBicep-example.ps1") {
                        $powershellExample = "$moduleDirectory\examples\runBicep-example.ps1"
                    } elseif (Test-Path "$moduleDirectory\examples\run-bicep-example.ps1") {
                        $powershellExample = "$moduleDirectory\examples\run-bicep-example.ps1"
                    }

                    if ($powershellExample) {
                        ('### Powershell script') | Out-File -FilePath $outputFile -Append
                        $powershellExampleSringBuilder = @()
                        $powershellExampleSringBuilder += '```powershell'

                        Get-Content $powershellExample | ForEach-Object {
                            $powershellExampleSringBuilder = $powershellExampleSringBuilder + $_
                        }

                        $powershellExampleSringBuilder += '```'
                        $powershellExampleSringBuilder | Out-File -FilePath $outputFile -Append
                    }

                    ("## Inputs") | Out-File -FilePath $outputFile -Append
                    # Create a Parameter List Table
                    $parameterHeader = "| Name | Type | Description | DefaultValue | AllowedValues |"
                    $parameterHeaderDivider = "| --- | --- | --- | --- | --- |"
                    $parameterRow = " | {0}| {1} | {2} | {3} | {4} |"

                    $StringBuilderParameter = @()
                    $StringBuilderParameter += $parameterHeader
                    $StringBuilderParameter += $parameterHeaderDivider

                    $StringBuilderParameter += $templateObject.parameters | Get-Member -MemberType NoteProperty | ForEach-Object { $parameterRow -f $_.Name , $templateObject.parameters.($_.Name).type , $templateObject.parameters.($_.Name).metadata.description, $templateObject.parameters.($_.Name).defaultValue , (($templateObject.parameters.($_.Name).allowedValues) -join ',' ) }
                    $StringBuilderParameter | Out-File -FilePath $outputFile -Append

                    ("## Resources") | Out-File -FilePath $outputFile -Append
                    # Create a Resource List Table
                    $resourceHeader = "| Resource Name | Resource Type |"
                    $resourceHeaderDivider = "| --- | --- |"
                    $resourceRow = " | {0}| {1} |"

                    $StringBuilderResource = @()
                    $StringBuilderResource += $resourceHeader
                    $StringBuilderResource += $resourceHeaderDivider

                    $StringBuilderResource += $templateObject.resources | ForEach-Object { $resourceRow -f $_.Name, $_.Type, $_.Comments }
                    $StringBuilderResource | Out-File -FilePath $outputFile -Append

                    if ((($templateObject | Get-Member).name) -match "outputs") {
                        Write-Verbose ("Output objects found.")
                        if (Get-Member -InputObject $templateObject.outputs -MemberType 'NoteProperty') {
                            ("## Outputs") | Out-File -FilePath $outputFile -Append
                            # Create an Output List Table
                            $outputHeader = "| Name | Type | Output Value |"
                            $outputHeaderDivider = "| --- | --- | --- |"
                            $outputRow = " | {0}| {1} | {2} |"

                            $StringBuilderOutput = @()
                            $StringBuilderOutput += $outputHeader
                            $StringBuilderOutput += $outputHeaderDivider

                            $StringBuilderOutput += $templateObject.outputs | Get-Member -MemberType NoteProperty | ForEach-Object { $outputRow -f $_.Name , $templateObject.outputs.($_.Name).type , $templateObject.outputs.($_.Name).value }
                            $StringBuilderOutput | Out-File -FilePath $outputFile -Append
                        }
                    } else {
                        Write-Verbose ("This file does not contain outputs")
                    }
                }
            }
        }
    } catch {
        Write-Error "Something went wrong while generating the output documentation: $_"
    }
}
