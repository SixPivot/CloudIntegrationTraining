// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool = false
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''

// tags
param tags object = {}

// Service Bus Namespace settings
param SQLDatabaseSKUName string = 'Standard'
param SQLDatabaseCapacity int = 10
param SQLDatabaseTierName string = 'Standard'

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param sqlserver_name string = ''
//param loganalyticsWorkspace_name string = ''

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var sqlDatabase_name = 'sqldb-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource sqlserver 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlserver_name
}

// resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
//   name: loganalyticsWorkspace_name
// }

//****************************************************************
// SQL Server
//****************************************************************

resource sqldatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: sqlDatabase_name
  parent: sqlserver
  location: AppLocation
  tags: tags
  sku: {
    capacity: SQLDatabaseCapacity
    name: SQLDatabaseSKUName
    tier: SQLDatabaseTierName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 107374182400
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    zoneRedundant: false
  }  
}

// resource keyvaultAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: servicebusnamespace
//   name: 'AuditSettings'
//   properties: {
//     workspaceId: loganalyticsWorkspace.id
//     logs: [
//       {
//         categoryGroup: 'Audit'
//         enabled: true
//       }
//     ]
//   }
// }

// resource keyvaultDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: servicebusnamespace
//   name: 'DiagnosticSettings'
//   properties: {
//     workspaceId: loganalyticsWorkspace.id
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
// }

//****************************************************************
// Add Service Bus Namespace details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuesqldatabasename './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'sqldatabase_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'sqlserver_name'
    variables_value: sqldatabase.name
  }
}

module moduleAppConfigKeyValuesqldatabaseresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'sqldatabase_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'sqldatabase_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output sqldatabase_name string = sqldatabase.name
output sqldatabase_resourcegroup string = resourceGroup().name
