metadata module = {
  name: 'sqlserver'
  displayName: 'SQL Server'
  description: 'Provision a SQL Server instance'
  owner: 'Wesley Camargo'
  version: '0.1.1'
}

@minLength(5)
@maxLength(50)
@description('The name of the SQL logical server.')
param name string = 'sql-${uniqueString(subscription().subscriptionId, resourceGroup().id)}'

@description('The administrator username of the SQL logical server.')
param administratorLogin string = 'adminuser'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string = '$ecUreP@ssw0rd'

@description('Provide a location.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

@description('The name of loganalytics workspace.')
param logAnalyticsName string = ''

@description('The name of the SQL logical server.')
var masterDatabase = '${name}/master'

resource azureSqlDatabase_serverName 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: '1.2'
  }
}

resource masterDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: masterDatabase
  location: location
  dependsOn: [
    azureSqlDatabase_serverName
  ]
}

// Existing Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (logAnalyticsName != '' ) {
  name: logAnalyticsName
}

var diagnosticSettingsName = 'SQLSecurityAuditEvents_3d229c42-c7e7-4c97-9a99-ec0d0d8b86c1'

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (logAnalyticsName != '' ) {
  scope: masterDB
  name: diagnosticSettingsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
}

resource azureSqlDatabase_serverName_DefaultAuditingSettings 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = {
  name: '${name}/DefaultAuditingSettings'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
  dependsOn: [
    azureSqlDatabase_serverName
  ]
}

resource azureSqlDatabase_serverName_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallrules@2020-02-02-preview' = {
  name: '${name}/AllowAllWindowsAzureIps'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
  dependsOn: [
    azureSqlDatabase_serverName
  ]
}
