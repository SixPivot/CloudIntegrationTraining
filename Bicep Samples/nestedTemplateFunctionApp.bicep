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
param variables_functionappid string
param variables_functionworkerruntime string


var functionStorageName = 'stfunc${toLower(variables_functionappid)}${toLower(variables_BaseShortName)}${toLower(variables_environmentname)}'
var functionAppName = 'func-${toLower(variables_functionappid)}-${toLower(variables_basename)}-${toLower(variables_environmentname)}'

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
//var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
//var appconfigdataowner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var appconfigdatareader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

var storageaccountcontributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')

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
// Azure Function App Storage Account
//****************************************************************

resource functionStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: functionStorageName
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
  parent: functionStorage
  name: 'default'
  properties:{}
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: functionStorage
}

resource functionStorageFileServicesFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: toLower(functionAppName)
  parent: fileService
}

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: functionStorage
  name: 'default'
  properties:{}
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: functionStorage
  name: 'default'
  properties:{}
}

module nestedTemplateAppConfigfunctionStorageName './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'functionstorage-${toLower(variables_functionappid)}-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'functionstorage_${toLower(variables_functionappid)}_name'
    variables_value: functionStorage.name
  }
}

module nestedTemplateAppConfigfunctionstorageResourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'functionstorage-${toLower(variables_functionappid)}-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'functionstorage_${toLower(variables_functionappid)}_resourcegroup'
    variables_value: resourceGroup().name
  }
}

//****************************************************************
// Azure Function App Storage Account Diagnostics
//****************************************************************

resource LogicAppStdStorageDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: functionStorage
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
// Azure Function App 
//****************************************************************

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: variables_applocation
  tags: {
    AppDomain: variables_applicationtag
    Environment: variables_environmenttag
    Location: variables_locationtag
    Organisation: variables_organisationtag
    Owner: variables_ownertag
  }
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      use32BitWorkerProcess: false
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${functionStorage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${functionStorage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionStorageFileServicesFileShare.name
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appinsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: variables_functionworkerruntime
        }
        {
          name: 'AppConfigurationEndpoint'
          value: appconfig.properties.endpoint
        }
        {
          name: 'AppConfigurationEnvironment'
          value: variables_environmentname
        }
      ]
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource keyvaultRoleAssignmentfunctionApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, functionApp.name, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppfunctionApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, functionApp.name, appconfigdatareader)
  properties: {
    roleDefinitionId: appconfigdatareader
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageRoleAssignmentfunctionApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: functionStorage
  name: guid(functionStorage.id, functionApp.name, storageaccountcontributor)
  properties: {
    roleDefinitionId: storageaccountcontributor
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module nestedTemplateAppConfigfunctionAppName './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'functionapp-${toLower(variables_functionappid)}-name'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'functionapp_${toLower(variables_functionappid)}_name'
    variables_value: functionApp.name
  }
}

module nestedTemplateAppConfigfunctionAppResourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'functionapp-${toLower(variables_functionappid)}-resourcegroup'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'functionapp_${toLower(variables_functionappid)}_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module nestedTemplateAppConfigfunctionAppURL './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'functionapp-${toLower(variables_functionappid)}-url'
  scope: resourceGroup(resourceGroup().name)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'functionapp_${toLower(variables_functionappid)}_url'
    variables_value: functionApp.properties.defaultHostName
  }
}
