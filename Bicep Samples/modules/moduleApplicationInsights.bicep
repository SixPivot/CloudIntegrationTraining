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

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param loganalyticsWorkspace_name string = ''
param keyvault_name string = ''

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var appInsights_name = 'appi-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// Azure Application Insights
//****************************************************************

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsights_name
  location: AppLocation
  tags: tags
  kind:'other'
  properties:{
    Application_Type:'other'
    Request_Source: 'rest'
    WorkspaceResourceId: loganalyticsWorkspace.id
  }
}

module moduleAppConfigKeyValueapplicationinsightsname './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'applicationinsights_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights_name'
    variables_value: appinsights.name
  }
}

module moduleAppConfigKeyValueapplicationinsightsresourcegroup './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'applicationinsights_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights_resourcegroup'
    variables_value: resourceGroup().name
  }
}

resource keyvaultSecretAppInsightsInstrumentationKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'appinsights-instrumentationKey'
  parent: keyvault
  tags: tags
  properties:{
    value: appinsights.properties.InstrumentationKey
  }
}

module moduleAppConfigKeyValueAppInsightsInstrumentationKey './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'appinsights_instrumentationKey'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'appInsights_InstrumentationKey'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsInstrumentationKey.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource keyvaultSecretAppInsightsConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'applicationinsights-connectionstring'
  parent: keyvault
  tags: tags
  properties:{
    value: appinsights.properties.ConnectionString
  }
}

module moduleAppConfigKeyValueAppInsightsConnectionString './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'applicationinsights_connectionstring'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights_connectionstring'
    variables_value: '{"uri":"${keyvaultSecretAppInsightsConnectionString.properties.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

output appinsights_name string = appinsights.name
output applicationinsights_resourcegroup string = resourceGroup().name
output appinsights_id string = appinsights.id
output appinsights_location string = appinsights.location
output appinsights_kind string = appinsights.kind
output appinsights_AppId string = appinsights.properties.AppId
output appinsights_ApplicationId string = appinsights.properties.ApplicationId
output appinsights_ConnectionString string = appinsights.properties.ConnectionString
output appinsights_InstrumentationKey string = appinsights.properties.InstrumentationKey
output appinsights_WorkspaceResourceId string = appinsights.properties.WorkspaceResourceId
