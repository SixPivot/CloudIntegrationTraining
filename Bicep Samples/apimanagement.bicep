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

// existing resources
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param loganalyticsWorkspace_name string = '$(loganalyticsWorkspace_name)'
param appInsights_name string = '$(appInsights_name)'
param keyvault_name string = '$(keyvault_name)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Isolated'
  'Premium'
  'Standard'
])
param ApiManagementSKUName string = 'Developer'
param ApiManagementCapacity int = 0
param ApiManagementPublisherEmail string = 'bill@biztalkbill.com'

//****************************************************************
// Variables
//****************************************************************

var apimanagement_name = 'apim-${toLower(BaseName)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsights_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// Azure API Management
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apimanagement_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: ApiManagementSKUName
    capacity: ApiManagementCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: ApiManagementPublisherEmail
    publisherName: ApplicationTag
    virtualNetworkType: 'None'
    enableClientCertificate: false
    apiVersionConstraint: {}
  }
}

resource apiManagementAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: apimanagement
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

resource apiManagementLogging 'Microsoft.ApiManagement/service/loggers@2021-08-01'={
  name:'${appinsights.name}-logger'
  parent: apimanagement
  properties:{
    loggerType:'applicationInsights'
    description:'Logger resources for APIM'
    credentials:{
      instrumentationKey:appinsights.properties.InstrumentationKey 
    }
  }
}

resource apimAppInsights 'Microsoft.ApiManagement/service/diagnostics@2022-09-01-preview' = {
  name: 'applicationinsights'
  parent: apimanagement
  properties:{
    loggerId: apiManagementLogging.id
    alwaysLog: 'allErrors'
  }
}

// resource apiManagementDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: apimanagement
//   name: 'DiagnosticSettings'
//   properties: {
//     workspaceId: loganalyticsWorkspace.id
//     // logs: [
//     //   {
//     //     categoryGroup: 'allLogs'
//     //     enabled: true
//     //   }
//     // ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
// }

resource keyvaultRoleAssignmentAPIM 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, apimanagement.name, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: apimanagement.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//****************************************************************
// Add Key Vault name and resource group to App Configuration
//****************************************************************

module nestedTemplateAppConfigapimanagementname './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'apimanagement-name'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement-name'
    variables_value: apimanagement.name
  }
}

module nestedTemplateAppConfigapimanagementegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'apimanagement-resourcegroup'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement-resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure API Management Workspace
//****************************************************************

resource apimanagementWorkspaceTeam1 'Microsoft.ApiManagement/service/workspaces@2023-03-01-preview' = {
  name: 'team1'
  parent: apimanagement
  properties: {
    description: 'Team1 Workspace'
    displayName: 'Team1'
  }
}

resource apimanagementWorkspaceTeam2 'Microsoft.ApiManagement/service/workspaces@2023-03-01-preview' = {
  name: 'team2'
  parent: apimanagement
  properties: {
    description: 'Team2 Workspace'
    displayName: 'Team2'
  }
}

output apimanagement_name string = apimanagement.name
output apimanagement_id string = apimanagement.id
output apimanagement_location string = apimanagement.location
output apimanagement_principalId string = apimanagement.identity.principalId
output apimanagement_workspace_team1_name string = apimanagementWorkspaceTeam1.name
output apimanagement_workspace_team1_id string = apimanagementWorkspaceTeam1.id
output apimanagement_workspace_team2_name string = apimanagementWorkspaceTeam2.name
output apimanagement_workspace_team2_id string = apimanagementWorkspaceTeam2.id
