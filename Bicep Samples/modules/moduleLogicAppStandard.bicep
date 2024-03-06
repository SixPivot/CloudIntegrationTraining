// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param AppName string = ''
param AppShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool = false
param enableDiagnostic bool = false
param enablePrivateLink bool = false
param enableVNETIntegration bool = false
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''
param vnetintegrationSubnetName string = ''

// tags
param tags object = {}

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param keyvault_name string = ''
param keyvault_resourcegroup string = ''
param loganalyticsWorkspace_name string = ''
param loganalyticsWorkspace_resourcegroup string = ''
param applicationinsights_name string = ''
param applicationinsights_resourcegroup string = ''
param workflowhostingplan_name string = ''
param workflowhostingplan_resourcegroup string = ''
param workflowhostingplan_subscriptionId string = ''
param storage_name string = ''
param storage_resourcegroup string = ''
param storage_subscriptionId string = ''
param apimanagement_publicIPAddress string = ''

//****************************************************************
// Variables
//****************************************************************

var logicapp_app_name = !empty(AppName) ? '-${AppName}' : ''
var logicapp_appkey_name = !empty(AppName) ? '${AppName}_' : ''
var InstanceString = padLeft(Instance,3,'0')
var logicapp_name = 'logic-${toLower(BaseName)}${toLower(logicapp_app_name)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

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

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = if(enableAppConfig) {
  name: appconfig_name
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
}

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
  scope: resourceGroup(loganalyticsWorkspace_resourcegroup)
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = if (enableDiagnostic) {
  name: applicationinsights_name
  scope: resourceGroup(applicationinsights_resourcegroup)
}

resource workflowHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: workflowhostingplan_name
  scope: resourceGroup(workflowhostingplan_subscriptionId,workflowhostingplan_resourcegroup)
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storage_name
  //scope: resourceGroup(storage_subscriptionId,storage_resourcegroup)
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' existing = {
  parent: storage
  name: 'default'
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = if (enableVNETIntegration) {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = if (enableVNETIntegration) {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
}

//****************************************************************
// storage account fileshare 
//****************************************************************

resource FileServicesFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: toLower(logicapp_name)
  parent: fileService
  properties: {
    enabledProtocols: 'SMB'
  }
}

//****************************************************************
// Azure Logic App Std 
//****************************************************************

resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicapp_name
  location: AppLocation
  tags: tags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: workflowHostingPlan.id
    virtualNetworkSubnetId: enableVNETIntegration ? subnet.id : ''
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v4.0'
      functionsRuntimeScaleMonitoringEnabled: false
      ftpsState: 'Disabled'
      use32BitWorkerProcess: false
      appSettings: []
      ipSecurityRestrictions: [
        // {
        //   ipAddress: '${apimanagement_publicIPAddress}/32'
        //   action: 'Allow'
        //   priority: 100
        //   name: 'APIM'
        //   description: 'APIM'
        // }
        {
          ipAddress: '180.150.54.1/32'
          action: 'Allow'
          priority: 200
          name: 'Bill Home'
          description: 'Bill Home'
        }
      ]
      ipSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsDefaultAction: 'Allow'
      scmIpSecurityRestrictionsUseMain: false
    }
  }
}

resource LogicAppStdAppConfigSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: LogicAppStdApp
  properties: {
    APP_KIND: 'workflowApp'
    AzureFunctionsJobHost_extensionBundle_id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
    AzureFunctionsJobHost_extensionBundle_version: '[1.*,2.0.0)'
    XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_NODE_DEFAULT_VERSION: '~18'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
    WEBSITE_CONTENTSHARE: FileServicesFileShare.name
  }
}

module moduleLogicAppStandardCustomConfig './moduleLogicAppStandardCustomConfig.bicep' = if (enableDiagnostic) {
  name: 'moduleLogicAppStandardCustomConfig'
  params:{
    logicapp_name: logicapp_name
    currentAppSettings: list(resourceId('Microsoft.Web/sites/config', logicapp_name, 'appsettings'), '2022-03-01').properties
    newAppSettings: {
      APPINSIGHTS_INSTRUMENTATIONKEY: enableDiagnostic ? appinsights.properties.InstrumentationKey : ''
      APPLICATIONINSIGHTS_CONNECTION_STRING: enableDiagnostic ? appinsights.properties.ConnectionString : ''
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    }
  }
  dependsOn: [
    LogicAppStdAppConfigSettings
  ] 
}

module moduleLogicAppStandardCustomConfigAppConfig './moduleLogicAppStandardCustomConfig.bicep' = if (enableAppConfig) {
  name: 'moduleLogicAppStandardCustomConfigAppConfig'
  params:{
    logicapp_name: logicapp_name
    currentAppSettings: list(resourceId('Microsoft.Web/sites/config', logicapp_name, 'appsettings'), '2022-03-01').properties
    newAppSettings: {
      AppConfigurationEndpoint: enableAppConfig ? appconfig.properties.endpoint : ''
      AppConfigurationEnvironment: toLower(EnvironmentName)
    }
  }
  dependsOn: [
    LogicAppStdAppConfigSettings
  ] 
}

//****************************************************************
// Add Private Link for Logic App Std 
//****************************************************************

module modulePrivateLinkLogicAppStd './moduleLogicAppStandardPrivateLink.bicep' = if (enablePrivateLink) {
  name: 'modulePrivateLinkLogicAppStd'
  params: {
    AppLocation: logicapp_name
    logicappstd_name: logicapp_name
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
  }
  dependsOn: [
    LogicAppStdApp
  ]
} 

//****************************************************************
// Add VNET Integration for Logic App Std 
//****************************************************************

module moduleVNETIntegrationLogicAppStd './moduleLogicAppStandardVNETIntegration.bicep' = if (enableVNETIntegration) {
  name: 'moduleVNETIntegrationLogicAppStd'
  params: {
    AppLocation: logicapp_name
    logicappstd_name: logicapp_name
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
  }
  dependsOn: [
    LogicAppStdApp
  ]
}

//****************************************************************
// Add Logic App Std reader role to App Configuration
//****************************************************************

module moduleAppConfigRoleAssignmentAppConfigReaderLogicAppStd './moduleAppConfigurationRoleAssignment.bicep' = if (enableAppConfig) {
  name: '${logicapp_appkey_name}appconfigreader'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    appconfig_name: appconfig_name
    principalid: LogicAppStdApp.identity.principalId
    principaltype: 'ServicePrincipal'
    roledefinitionid: AppConfigurationDataReader
  }
}

//****************************************************************
// Add Logic App Std reader role to Key Vault
//****************************************************************

module moduleKeyVaultRoleAssignmentKeyVaultReaderLogicAppStd './moduleKeyVaultRoleAssignment.bicep' = {
  name: '${logicapp_appkey_name}keyvaultreader'
  scope: resourceGroup(keyvault_resourcegroup)
  params: {
    keyvault_name: keyvault_name
    principalid: LogicAppStdApp.identity.principalId
    principaltype: 'ServicePrincipal'
    roledefinitionid: KeyVaultSecretsUser
  }
}

//****************************************************************
// Add Logic App Std details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuelogicappstdname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${logicapp_appkey_name}logicappstd_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${logicapp_appkey_name}logicappstd_name'
    variables_value: LogicAppStdApp.name
  }
}

module moduleAppConfigKeyValuelogicappstdresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${logicapp_appkey_name}logicappstd_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${logicapp_appkey_name}logicappstd_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValuelogicappstdURL './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: '${logicapp_appkey_name}logicappstd_URL'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${logicapp_appkey_name}logicappstd_URL'
    variables_value: LogicAppStdApp.properties.defaultHostName
  }
}

output logicappstd_name string = LogicAppStdApp.name
output logicappstd_resourcegroup string = resourceGroup().name
output logicappstd_principalid string = LogicAppStdApp.identity.principalId
output logicappstd_URL string = LogicAppStdApp.properties.defaultHostName
output logicappstd_appsettings object = list(resourceId('Microsoft.Web/sites/config', logicapp_name, 'appsettings'), '2022-03-01').properties
