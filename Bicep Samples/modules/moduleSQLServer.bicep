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
param enablePrivateLink bool 
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''

// tags
param tags object = {}

// Service Bus Namespace settings
param ServiceBusSKUName string = 'Standard'
param ServiceBusCapacity int = 1
param ServiceBusTierName string = 'Standard'

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
//param loganalyticsWorkspace_name string = ''

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
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    administrators:{
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'trevor.booth@wilsongroupau.com'
      sid: '1ed092a2-ee71-4e8b-a626-8244daa06189'
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
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
