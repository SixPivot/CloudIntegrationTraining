// environment parameters
param BaseName string 
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string 
param Instance int 


param enablePrivateLink bool 
param publicNetworkAccess string
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param privatelinkSubnetName string 

// tags
param tags object = {}

// existing resources
param enableAppConfig bool 
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string
param enableDiagnostic bool  
param loganalyticsWorkspace_name string 
param loganalyticsWorkspace_resourcegroup string
param loganalyticsWorkspace_privatelinkscope_name string
param keyvault_name string 
param keyvault_resourcegroup string   

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

resource privateLinkScope 'Microsoft.Insights/privateLinkScopes@2021-07-01-preview' existing = if(enablePrivateLink) {
  name: loganalyticsWorkspace_privatelinkscope_name
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
    publicNetworkAccessForIngestion: publicNetworkAccess
    publicNetworkAccessForQuery: publicNetworkAccess
    IngestionMode: 'LogAnalytics'
  }
}

resource privateLinkScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = if(enablePrivateLink) {
  name: appinsights.name
  parent: privateLinkScope
  properties: {
    linkedResourceId: appinsights.id
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

module moduleKeyVaultSecretAppInsightsInstrumentationKey './moduleKeyVaultSecret.bicep' = {
  name: 'keyvaultSecretAppinsightsInstrumentationKey'
  scope: resourceGroup(keyvault_resourcegroup)
  params: {
    keyvault_name: keyvault_name
    tags: tags
    secretName: 'appinsights-instrumentationKey'
    secretValue: appinsights.properties.InstrumentationKey
  }
}

module moduleAppConfigKeyValueAppInsightsInstrumentationKey './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'appinsights_instrumentationKey'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'appInsights_InstrumentationKey'
    variables_value: '{"uri":"${moduleKeyVaultSecretAppInsightsInstrumentationKey.outputs.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

module moduleKeyVaultSecretAppInsightsConnectionString './moduleKeyVaultSecret.bicep' = {
  name: 'keyvaultSecretAppinsightsConnectionString'
  scope: resourceGroup(keyvault_resourcegroup)
  params: {
    keyvault_name: keyvault_name
    tags: tags
    secretName: 'applicationinsights-connectionstring'
    secretValue: appinsights.properties.ConnectionString
  }
}

module moduleAppConfigKeyValueAppInsightsConnectionString './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'applicationinsights_connectionstring'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'applicationinsights_connectionstring'
    variables_value: '{"uri":"${moduleKeyVaultSecretAppInsightsConnectionString.outputs.secretUri}"}'
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
