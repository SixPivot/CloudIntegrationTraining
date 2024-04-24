// environment parameters
param BaseName string 
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string 
param Instance int = 1
param publicNetworkAccessForIngestion string
param publicNetworkAccessForQuery string
param publicNetworkAccess string
param enablePrivateLink bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 

// tags
param tags object = {}

// service principals and groups
param AzureDevOpsServiceConnectionId string 
param AppConfigAdministratorsGroupId string 
param AppConfigReaderGroupId string 

@allowed([
  'Free'
  'Standard'
])
param appConfigSku string = 'Standard'

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var appconfig_name = 'appcs-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'
var loganalyticsWorkspace_name = 'log-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'


//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b    BuiltInRole     App Configuration Data Owner
// 516239f1-63e1-4d78-a4de-a74fb236a071    BuiltInRole     App Configuration Data Reader

var AppConfigurationDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var AppConfigurationDataReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

//****************************************************************
// Azure Log Anaytics Workspace
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: loganalyticsWorkspace_name
  location: AppLocation
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

//****************************************************************
// Azure App Config
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-08-01-preview' = {
  name: appconfig_name
  location: AppLocation
  tags: tags
  sku: {
    name: appConfigSku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
  }
}

//****************************************************************
// Add Private Link for App Config 
//****************************************************************

module moduleAppConfigurationPrivateLink './moduleAppConfigurationPrivateLink.bicep' = if (enablePrivateLink) {
  name: 'moduleAppConfigurationPrivateLink'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    appconfig: appconfig
  }
}

resource appconfigAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appconfig
  name: 'AuditSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
  }
}

resource appconfigDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: appconfig
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appconfigRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(AzureDevOpsServiceConnectionId)) {
  scope: appconfig
  name: guid(appconfig.id, AzureDevOpsServiceConnectionId, AppConfigurationDataOwner)
  properties: {
    roleDefinitionId: AppConfigurationDataOwner
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppConfigAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(AppConfigAdministratorsGroupId)) {
  scope: appconfig
  name: guid(appconfig.id, AppConfigAdministratorsGroupId, AppConfigurationDataOwner)
  properties: {
    roleDefinitionId: AppConfigurationDataOwner
    principalId: AppConfigAdministratorsGroupId
    principalType: 'Group'
  }
}

resource appconfigRoleAssignmentAppConfigReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(AppConfigReaderGroupId)) {
  scope: appconfig
  name: guid(appconfig.id, AppConfigReaderGroupId, AppConfigurationDataReader)
  properties: {
    roleDefinitionId: AppConfigurationDataReader
    principalId: AppConfigReaderGroupId
    principalType: 'Group'
  }
}

output appconfig_name string = appconfig.name
output appconfig_id string = appconfig.id
output appconfig_principalId string = appconfig.identity.principalId
output appconfig_tenantId string = appconfig.identity.tenantId
output appconfig_identityType string = appconfig.identity.type
output appconfig_location string = appconfig.location
output appconfig_endpoint string = appconfig.properties.endpoint
output appconfig_resourcegroup string = resourceGroup().name
