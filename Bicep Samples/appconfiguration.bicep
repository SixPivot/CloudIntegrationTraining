
// environment parameters
param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'CIT'
param EnvironmentName string = 'Global'
param EnvironmentShortName string = 'Gbl'
param AppLocation string = resourceGroup().location

// tags
param LocationTag string = resourceGroup().location
param OwnerTag string = 'CloudIntegrationTraining'
param OrganisationTag string = 'CloudIntegrationTraining'
param EnvironmentTag string = 'CloudIntegrationTraining'
param ApplicationTag string = 'CloudIntegrationTraining'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'

// existing azure resouces
param loganalyticsWorkspace_name string = '$(loganalyticsWorkspace_name)'

@allowed([
  'Free'
  'Standard'
])
param appConfigSku string = 'Free'

//****************************************************************
// Variables
//****************************************************************

var appconfig_name = 'appcs-${toLower(BaseName)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b    BuiltInRole     App Configuration Data Owner
// 516239f1-63e1-4d78-a4de-a74fb236a071    BuiltInRole     App Configuration Data Reader

var AppConfigurationDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var AppConfigurationDataReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

//****************************************************************
// Azure App Config
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appconfig_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: appConfigSku
  }
  identity: {
    type: 'SystemAssigned'
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

resource appconfigRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AzureDevOpsServiceConnectionId, AppConfigurationDataOwner)
  properties: {
    roleDefinitionId: AppConfigurationDataOwner
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppConfigAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AppConfigAdministratorsGroupId, AppConfigurationDataOwner)
  properties: {
    roleDefinitionId: AppConfigurationDataOwner
    principalId: AppConfigAdministratorsGroupId
    principalType: 'Group'
  }
}

resource appconfigRoleAssignmentAppConfigReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
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
