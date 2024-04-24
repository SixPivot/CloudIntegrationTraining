// environment parameters
param BaseName string 
param BaseShortName string 
param AppName string 
param AppShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool 
param enableVNETIntegration bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 
//param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
//param createSubnet bool 
param networksecuritygroupName string 
param routetableName string 
param publicNetworkAccess string 

// tags
param tags object = {}

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param keyvault_name string 
param keyvault_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 
param loganalyticsWorkspace_resourcegroup string 
param applicationinsights_name string 
param applicationinsights_resourcegroup string 
param functionapphostingplan_name string 
param functionapphostingplan_resourcegroup string 
param functionapphostingplan_subscriptionId string 
param storage_name string 
param storage_resourcegroup string 
param storage_subscriptionId string 
//param apimanagement_publicIPAddress string 

param functionappWorkerRuntime string = 'dotnet-isolated'
param functionappExtentionVersion string = '~4'

//****************************************************************
// Variables
//****************************************************************

var functionapp_app_name = !empty(AppName) ? '-${AppName}' : ''
var functionapp_appkey_name = !empty(AppName) ? '${AppName}_' : ''
var InstanceString = padLeft(Instance,3,'0')
var functionapp_name = 'func-${toLower(BaseName)}${toLower(functionapp_app_name)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'


//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 4633458b-17de-408a-b874-0445c86b69e6    BuiltInRole     Key Vault Secrets User
// 516239f1-63e1-4d78-a4de-a74fb236a071    BuiltInRole     App Configuration Data Reader

var KeyVaultSecretsUser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var AppConfigurationDataReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = if (enableAppConfig) {
  name: appconfig_name
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
}

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = if (enableDiagnostic) {
  name: applicationinsights_name
  scope: resourceGroup(applicationinsights_resourcegroup)
}

resource functionappHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: functionapphostingplan_name
  scope: resourceGroup(functionapphostingplan_resourcegroup)
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storage_name
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' existing = {
  parent: storage
  name: 'default'
}

//****************************************************************
// storage account fileshare 
//****************************************************************

resource FileServicesFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: toLower(functionapp_name)
  parent: fileService
}

//****************************************************************
// Azure Function App
//****************************************************************

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionapp_name
  location: AppLocation
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    vnetContentShareEnabled: publicNetworkAccess == 'Enable' ? false : true
    serverFarmId: functionappHostingPlan.id
    publicNetworkAccess: publicNetworkAccess
    httpsOnly: true
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: false
      ftpsState: 'Disabled'
      use32BitWorkerProcess: false
      appSettings: []
      ipSecurityRestrictions: []
      ipSecurityRestrictionsDefaultAction: publicNetworkAccess == 'Enable' ? 'Allow' : 'Deny'
      scmIpSecurityRestrictionsDefaultAction: publicNetworkAccess == 'Enable' ? 'Allow' : 'Deny'
      scmIpSecurityRestrictionsUseMain: true
      publicNetworkAccess: publicNetworkAccess
    }
  }
}

resource functionAppConfigSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: functionApp
  properties: {
    FUNCTIONS_EXTENSION_VERSION: functionappExtentionVersion
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    FUNCTIONS_WORKER_RUNTIME: functionappWorkerRuntime
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    WEBSITE_CONTENTSHARE: FileServicesFileShare.name
  }
  // dependsOn: [
  //   moduleFunctionAppVNETIntegration
  // ]
}

module moduleFunctionAppCustomConfigAppInsights './moduleFunctionAppCustomConfig.bicep' = if (enableDiagnostic) {
  name: 'moduleFunctionAppCustomConfigAppInsights'
  params:{
    functionapp_name: functionapp_name
    currentAppSettings: list(resourceId('Microsoft.Web/sites/config', functionapp_name, 'appsettings'), '2022-03-01').properties
    newAppSettings: {
      APPINSIGHTS_INSTRUMENTATIONKEY: enableDiagnostic ? appinsights.properties.InstrumentationKey : ''
      APPLICATIONINSIGHTS_CONNECTION_STRING: enableDiagnostic ? appinsights.properties.ConnectionString : ''
    }
  }
  dependsOn: [
    functionAppConfigSettings
  ] 
}

module moduleFunctionAppCustomConfigAppConfig './moduleFunctionAppCustomConfig.bicep' = if (enableAppConfig) {
  name: 'moduleFunctionAppCustomConfigAppConfig'
  params:{
    functionapp_name: functionapp_name
    currentAppSettings: list(resourceId('Microsoft.Web/sites/config', functionapp_name, 'appsettings'), '2022-03-01').properties
    newAppSettings: {
      AppConfigurationEndpoint: enableAppConfig ? appconfig.properties.endpoint : ''
      AppConfigurationEnvironment: enableAppConfig ? toLower(EnvironmentName) : ''
    }
  }
  dependsOn: [
    functionAppConfigSettings
  ] 
}

//****************************************************************
// Add Private Link for Function App 
//****************************************************************

module moduleFunctionAppPrivateLink './moduleFunctionAppPrivateLink.bicep' = if (enablePrivateLink) {
  name: 'moduleFunctionAppPrivateLink'
  params: {
    AppLocation: AppLocation
    functionapp_name: functionapp_name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
  }
  dependsOn: [
    functionApp
  ]
} 

//****************************************************************
// Add VNET Integration for Function App
//****************************************************************

module moduleFunctionAppVNETIntegration './moduleFunctionAppVNETIntegration.bicep' = if (enableVNETIntegration) {
  name: 'moduleFunctionAppVNETIntegration'
  params: {
    functionapp_name: functionapp_name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    //vnetintegrationSubnetName: functionApp.name
    vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
    //createSubnet: createSubnet
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
  }
  dependsOn: [
    functionApp
  ]
}


//****************************************************************
// Add Function App Std reader role to App Configuration
//****************************************************************

module moduleAppConfigRoleAssignmentAppConfigReaderfunctionappStd './moduleAppConfigurationRoleAssignment.bicep' = if (enableAppConfig) {
  name: '${functionapp_appkey_name}appconfigreader'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    appconfig_name: appconfig_name
    principalid: functionApp.identity.principalId
    principaltype: 'ServicePrincipal'
    roledefinitionid: AppConfigurationDataReader
  }
}

//****************************************************************
// Add Function App Std reader role to Key Vault
//****************************************************************

module moduleKeyVaultRoleAssignmentKeyVaultReaderfunctionappStd './moduleKeyVaultRoleAssignment.bicep' = {
  name: '${functionapp_appkey_name}keyvaultreader'
  scope: resourceGroup(keyvault_resourcegroup)
  params: {
    keyvault_name: keyvault_name
    principalid: functionApp.identity.principalId
    principaltype: 'ServicePrincipal'
    roledefinitionid: KeyVaultSecretsUser
  }
}

//****************************************************************
// Add Function App Std details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuefunctionappstdname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${functionapp_appkey_name}functionappstd_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${functionapp_appkey_name}functionappstd_name'
    variables_value: functionApp.name
  }
}

module moduleAppConfigKeyValuefunctionappstdresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${functionapp_appkey_name}functionappstd_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${functionapp_appkey_name}functionappstd_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValuefunctionappstdURL './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${functionapp_appkey_name}functionappstd_URL'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${functionapp_appkey_name}functionappstd_URL'
    variables_value: functionApp.properties.defaultHostName
  }
}

output functionapp_name string = functionApp.name
output functionapp_resourcegroup string = resourceGroup().name
output functionapp_principalid string = functionApp.identity.principalId
output functionapp_URL string = functionApp.properties.defaultHostName
output functionapp_appsettings object = list(resourceId('Microsoft.Web/sites/config', functionapp_name, 'appsettings'), '2022-03-01').properties
