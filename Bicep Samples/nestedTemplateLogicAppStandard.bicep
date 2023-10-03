param variables_basename string
param variables_BaseShortName string
param variables_environmentname string
param variables_applocation string
param variables_applicationtag string
param variables_environmenttag string
param variables_locationtag string
param variables_organisationtag string
param variables_ownertag string
param variables_appconfigname string
param variables_keyvaultname string
param variables_hostingplanname string
param variables_loganalyticsworkspacename string
param variables_appinsightname string
param variables_logicappstdid string

var logicAppStdStorageName = 'stlogic${toLower(variables_logicappstdid)}${toLower(variables_BaseShortName)}${toLower(variables_environmentname)}'
var logicAppStdName = 'logic-std-${toLower(variables_logicappstdid)}-${toLower(variables_basename)}-${toLower(variables_environmentname)}'

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
//var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
//var appconfigdataowner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var appconfigdatareader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

var LogicAppStdStorageaccountcontributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: variables_appconfigname
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: variables_hostingplanname
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: variables_keyvaultname
}

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: variables_loganalyticsworkspacename
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: variables_appinsightname
}

//****************************************************************
// Azure Logic App Std Storage Account
//****************************************************************

resource LogicAppStdStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: logicAppStdStorageName
  location: variables_applocation
  tags: {
    AppDomain: variables_applicationtag
    Environment: variables_environmenttag
    Location: variables_locationtag
    Organisation: variables_organisationtag
    Owner: variables_ownertag
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: LogicAppStdStorage
  name: 'default'
  properties:{}
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: LogicAppStdStorage
  name: 'default'
  properties:{}
}

resource LogicAppStdStorageFileServicesFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: toLower(logicAppStdName)
  parent: fileService
}

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: LogicAppStdStorage
  name: 'default'
  properties:{}
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: LogicAppStdStorage
  name: 'default'
  properties:{}
}

module nestedTemplateAppConfigLogicAppStdStorageName './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappstdLogicAppStdStorage-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappstdLstorage_${toLower(variables_logicappstdid)}_name'
    variables_value:   LogicAppStdStorage.name
  }
}

module nestedTemplateAppConfigLogicAppStdStorageResourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappstdLogicAppStdStorage-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappstdstorage_${toLower(variables_logicappstdid)}_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Logic App Std Storage Account Diagnostics
//****************************************************************

resource LogicAppStdStorageDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: LogicAppStdStorage
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource LogicAppStdStorageBlobDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: blobService
  name: 'BlobDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource LogicAppStdStorageFileDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: fileService
  name: 'FileDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource LogicAppStdStorageTableDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: tableService
  name: 'TableDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource LogicAppStdStorageQueueDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: queueService
  name: 'QueueDiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs:[
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

//****************************************************************
// Azure Logic App Std 
//****************************************************************

resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicAppStdName
  location: variables_applocation
  tags: {
    AppDomain: variables_applicationtag
    Environment: variables_environmenttag
    Location: variables_locationtag
    Organisation: variables_organisationtag
    Owner: variables_ownertag
  }
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    
    //keyVaultReferenceIdentity: managedIdentity.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v4.0'
      functionsRuntimeScaleMonitoringEnabled: false
      ftpsState: 'Disabled'
      use32BitWorkerProcess: false
      appSettings: []
    }
  }
}

resource keyvaultRoleAssignmentLogicAppStdApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, LogicAppStdApp.name, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: LogicAppStdApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppLogicAppStdApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, LogicAppStdApp.name, appconfigdatareader)
  properties: {
    roleDefinitionId: appconfigdatareader
    principalId: LogicAppStdApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource LogicAppStdStorageRoleAssignmentLogicAppStdApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: LogicAppStdStorage
  name: guid(LogicAppStdStorage.id, LogicAppStdApp.name, LogicAppStdStorageaccountcontributor)
  properties: {
    roleDefinitionId: LogicAppStdStorageaccountcontributor
    principalId: LogicAppStdApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module nestedTemplateAppConfigLogicAppStdName './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappstd-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappstd_${toLower(variables_logicappstdid)}_name'
    variables_value:   LogicAppStdApp.name
  }
}

module nestedTemplateAppConfigLogicAppStdResourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappstd-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappstd_${toLower(variables_logicappstdid)}_resourcegroup'
    variables_value: resourceGroup().name
  }
}

// az rest --method post --uri https://management.azure.com/subscriptions/3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4/resourceGroups/AzureAppConfigurationTalk/providers/Microsoft.Web/sites/logic-std-demo1-appconfigtalk-demo/hostruntime/runtime/webhooks/workflow/api/management/workflows/demo1a/triggers/When_a_HTTP_request_is_received/listCallbackUrl?api-version=2018-11-01

resource diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2017-05-01-preview' = {
  name: 'Logging'
  scope: LogicAppStdApp
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        category: 'WorkflowRuntime'
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

resource LogicAppStdAppConfigSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: LogicAppStdApp
  properties: {
    APP_KIND: 'workflowApp'
    APPINSIGHTS_INSTRUMENTATIONKEY: appinsights.properties.InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appinsights.properties.ConnectionString
    ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${LogicAppStdStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${LogicAppStdStorage.listKeys().keys[0].value}'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${LogicAppStdStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${LogicAppStdStorage.listKeys().keys[0].value}'
    WEBSITE_CONTENTSHARE: LogicAppStdStorageFileServicesFileShare.name
    AppConfigurationEndpoint: appconfig.properties.endpoint
    AppConfigurationEnvironment: variables_environmentname
    testvalue1: '@Microsoft.AppConfiguration(Endpoint=${appconfig.properties.endpoint}; Key=testvalue1; Label=${variables_environmentname})'
    testvalue2: '@Microsoft.AppConfiguration(Endpoint=${appconfig.properties.endpoint}; Key=testvalue2; Label=${variables_environmentname})'
  }
}
