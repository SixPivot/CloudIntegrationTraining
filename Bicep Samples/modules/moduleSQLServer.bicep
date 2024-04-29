// environment parameters
param BaseName string 
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool
param enableDiagnostic bool
param enablePrivateLink bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param privatelinkSubnetName string 
param publicNetworkAccess string

// tags
param tags object = {}

// Service Bus Namespace settings
// param ServiceBusSKUName string = 'Standard'
// param ServiceBusCapacity int = 1
// param ServiceBusTierName string = 'Standard'

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
//param loganalyticsWorkspace_name string 

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var sqlServer_name = 'sql-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

// resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
//   name: loganalyticsWorkspace_name
// }

//****************************************************************
// SQL Server
//****************************************************************

resource sqlserver 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServer_name
  location: AppLocation
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: 'Disabled'
    administrators:{
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'bill@biztalkbill.com'
      sid: 'e84a079c-0ca6-452f-a592-9ee3f8cff4f8'
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }  
}

// resource SQLServerAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: sqlserver
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

// resource SQLServerDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: sqlserver
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
// Add Private Link for SQL Server
//****************************************************************

module moduleSQLServerPrivateLink './moduleSQLServerPrivateLink.bicep' = if (enablePrivateLink) {
  name: 'moduleSQLServerPrivateLink'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    sqlserver_name: sqlserver.name
  }
}

//****************************************************************
// Add SQL Server details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuesqlservername './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'sqlserver_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'sqlserver_name'
    variables_value: sqlserver.name
  }
}

module moduleAppConfigKeyValuesqlserverresoucegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'sqlserver_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'sqlserver_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output sqlserver_name string = sqlserver.name
output sqlserver_resourcegroup string = resourceGroup().name
