// environment parameters
param BaseName string 
param BaseShortName string 
param AppName string 
param AppShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string 
param Instance int = 1
param enableAppConfig bool
param enableDiagnostic bool


// tags
param tags object = {}

param enablePrivateLink bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param virtualNetworkSubscriptionId string 
param privatelinkSubnetName string 
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string 
param publicNetworkAccess string

// storage account settings
param StorageSKUName string 
param enableHNS bool = false

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 
param loganalyticsWorkspace_resourcegroup string

 

//****************************************************************
// Variables
//****************************************************************

var storage_app_name = !empty(AppName) ? '${AppName}' : ''
var storage_appkey_name = !empty(AppName) ? '${AppName}_' : ''
var storage_app_short_name = !empty(AppShortName) ? '${AppShortName}' : ''
var InstanceString = padLeft(Instance,3,'0')
var storage_name = 'st${toLower(BaseShortName)}${toLower(storage_app_name)}${toLower(EnvironmentName)}${toLower(AzureRegion)}${InstanceString}'
var storage_short_name = 'st${toLower(BaseShortName)}${toLower(storage_app_short_name)}${toLower(EnvironmentName)}${toLower(AzureRegion)}${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if(enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

//****************************************************************
// Azure Storage Account
//****************************************************************

resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: length(storage_name) > 24 ? storage_short_name : storage_name
  location: AppLocation
  tags: tags
  sku: {
    name: StorageSKUName
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    isHnsEnabled: enableHNS
    publicNetworkAccess: publicNetworkAccess
  }
}

resource storageDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: storage
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

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageBlobDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
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

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageFileDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
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

resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageTableDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
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

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2022-09-01' = {
  parent: storage
  name: 'default'
  properties:{}
}

resource storageQueueDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
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
// Add Private Link for Storage Account 
//****************************************************************

var storagePrivateLinks = [
  {
    storageType: 'blob'
    dnsExists: false
  }
  {
    storageType: 'table'
    dnsExists: false
  }
  {
    storageType: 'queue'
    dnsExists: false
  }
  {
    storageType: 'file'
    dnsExists: false
  }
  // {
  //   storageType: 'web'
  //   dnsExists: false
  // }
  // {
  //   storageType: 'dfs'
  //   dnsExists: false
  // }
]

module moduleStorageAccountPrivateLink './moduleStorageAccountPrivateLink.bicep' = [for (link, index) in storagePrivateLinks: if (enablePrivateLink) {
  name: 'moduleStorageAccountPrivateLink-${link.storageType}'
  params: {
    AppLocation: AppLocation
    EnvironmentName: EnvironmentName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    privatelinkSubnetName: privatelinkSubnetName
    storage_name: storage.name
    storageType: link.storageType
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}]

//****************************************************************
// Add Storage Account details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuestoragename './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_name'
    variables_value: storage.name
  }
}

module moduleAppConfigKeyValuestorageresourcegroup './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValuestoragebloburl './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_bloburl'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_bloburl'
    variables_value: storage.properties.primaryEndpoints.blob
  }
}

module moduleAppConfigKeyValuestoragequeueurl './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_queueurl'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_queueurl'
    variables_value: storage.properties.primaryEndpoints.queue
  }
}

module moduleAppConfigKeyValuestoragetableurl './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_tableurl'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_tableurl'
    variables_value: storage.properties.primaryEndpoints.table
  }
}

module moduleAppConfigKeyValuestoragefileurl './moduleAppConfigKeyValue.bicep' = {
  name: '${storage_appkey_name}storage_fileurl'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_fileurl'
    variables_value: storage.properties.primaryEndpoints.file
  }
}

output storage_name string = storage.name
output storage_resourcegroup string = resourceGroup().name
output storage_subscriptionId string = subscription().subscriptionId
output storage_bloburl string = storage.properties.primaryEndpoints.blob
output storage_queueurl string = storage.properties.primaryEndpoints.queue
output storage_tableurl string = storage.properties.primaryEndpoints.table
output storage_fileurl string = storage.properties.primaryEndpoints.file
