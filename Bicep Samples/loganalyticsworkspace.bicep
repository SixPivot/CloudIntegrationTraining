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
param keyvault_name string = '$(keyvault_name)'

//****************************************************************
// Variables
//****************************************************************

var loganalyticsWorkspace_name = 'log-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var actionGroupName = 'ag-${toLower(BaseName)}-${toLower(EnvironmentName)}'
var appInsights_name = 'appi-${toLower(BaseName)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 73c42c96-874c-492b-b04d-ab87d138a893    BuiltInRole     Log Analytics Reader
// 92aaf0da-9dab-42b6-94a3-d43ce8d16293    BuiltInRole     Log Analytics Contributor

var LogAnalyticsReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893')
var LogAnalyticsContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')

//****************************************************************
// Azure Log Anaytics Workspace
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: loganalyticsWorkspace_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    enabled: true
    groupShortName: actionGroupName
    emailReceivers: [
      {
        emailAddress: 'bill@biztalkbill.com'
        name: 'Bill Chesnut'
        useCommonAlertSchema: true
      }
    ]
  }
}

module nestedTemplateAppConfigloganalyticsWorkspacename './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'loganalyticsworkspace-name'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace-name'
    variables_value: loganalyticsWorkspace.name
  }
}

module nestedTemplateAppConfigloganalyticsWorkspaceresourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'loganalyticsworkspace-resourcegroup'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace-resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Application Insights
//****************************************************************

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  kind:'web'
  properties:{
    Application_Type:'web'
    Request_Source: 'rest'
    WorkspaceResourceId: loganalyticsWorkspace.id
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

resource keyvaultSecretAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'appinsights-instrumentationKey'
  parent: keyvault
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    value: appinsights.properties.InstrumentationKey
  }
}

module nestedTemplateAppConfigAppInsightsInstrumentationKey './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'appinsights-instrumentationKey'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'appInsights-InstrumentationKey'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsInstrumentationKey.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource keyvaultSecretAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'applicationinsights-connectionstring'
  parent: keyvault
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    value: appinsights.properties.ConnectionString
  }
}

module nestedTemplateAppConfigAppInsightsConnectionString './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'applicationinsights-connectionstring'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights-connectionstring'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsConnectionString.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

output loganalyticsWorkspace_name string = loganalyticsWorkspace.name
output loganalyticsWorkspace_id string = loganalyticsWorkspace.id
output loganalyticsWorkspace_location string = loganalyticsWorkspace.location
output loganalyticsWorkspace_customerId string = loganalyticsWorkspace.properties.customerId
output loganalyticsWorkspace_resourcegroup string = resourceGroup().name

output appinsights_name string = appinsights.name
output appinsights_id string = appinsights.id
output appinsights_location string = appinsights.location
output appinsights_kind string = appinsights.kind
output appinsights_AppId string = appinsights.properties.AppId
output appinsights_ApplicationId string = appinsights.properties.ApplicationId
output appinsights_ConnectionString string = appinsights.properties.ConnectionString
output appinsights_HockeyAppId string = appinsights.properties.HockeyAppId
output appinsights_HockeyAppToken string = appinsights.properties.HockeyAppToken
output appinsights_InstrumentationKey string = appinsights.properties.InstrumentationKey
output appinsights_WorkspaceResourceId string = appinsights.properties.WorkspaceResourceId
