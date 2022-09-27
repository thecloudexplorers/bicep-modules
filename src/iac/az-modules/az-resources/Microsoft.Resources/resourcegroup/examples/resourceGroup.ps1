New-AzSubscriptionDeployment `
    -Location "westeurope" `
    -TemplateFile "../main.bicep" `
    -TemplateParameterFile "./resourceGroup.parameters.json" `
    -Tag @{"key1" = "value1"; "key2" = "value2"; }