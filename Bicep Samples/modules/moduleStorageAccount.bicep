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
param enablePrivateLink bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 

// tags
param tags object = {}

// storage account settings
param StorageSKUName string 
param enableHNS bool = false
param publicNetworkAccess string

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 

//****************************************************************
// Variables
//****************************************************************

var storage_app_name = !empty(AppName) ? '${AppName}' : ''
var storage_appkey_name = !empty(AppName) ? '${AppName}_' : ''
var InstanceString = padLeft(Instance,3,'0')
var storage_name = 'st${toLower(BaseShortName)}${toLower(storage_app_name)}${toLower(EnvironmentName)}${toLower(AzureRegion)}${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 86e8f5dc-a6e9-4c67-9d15-de283e8eac25    BuiltInRole     Classic Storage Account Contributor
// 985d6b00-f706-48f5-a6fe-d0ca12fb668d    BuiltInRole     Classic Storage Account Key Operator Service Role
// 17d1049b-9a84-46fb-8f53-869881c3d3ab    BuiltInRole     Storage Account Contributor
// 81a9662b-bebf-436f-a333-f67b29880f12    BuiltInRole     Storage Account Key Operator Service Role
// ba92f5b4-2d11-453d-a403-e96b0029c9fe    BuiltInRole     Storage Blob Data Contributor
// b7e6dc6d-f1e8-4753-8033-0f276bb0955b    BuiltInRole     Storage Blob Data Owner
// 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1    BuiltInRole     Storage Blob Data Reader
// 974c5e8b-45b9-4653-ba55-5f855dd0fb88    BuiltInRole     Storage Queue Data Contributor
// 8a0f0c08-91a1-4084-bc3d-661d67233fed    BuiltInRole     Storage Queue Data Message Processor
// c6a89b2d-59bc-44d0-9896-0f6e12d7b80a    BuiltInRole     Storage Queue Data Message Sender
// 19e7f393-937e-4f77-808e-94535e297925    BuiltInRole     Storage Queue Data Reader
// aba4ae5f-2193-4029-9191-0cb91df5e314    BuiltInRole     Storage File Data SMB Share Reader
// 0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb    BuiltInRole     Storage File Data SMB Share Contributor
// db58b8e5-c6ad-4a2a-8342-4190687cbf4a    BuiltInRole     Storage Blob Delegator
// a7264617-510b-434b-a828-9731dc254ea7    BuiltInRole     Storage File Data SMB Share Elevated Contributor
// e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1    BuiltInRole     Storage Account Backup Contributor
// 76199698-9eea-4c19-bc75-cec21354c6b6    BuiltInRole     Storage Table Data Reader
// 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3    BuiltInRole     Storage Table Data Contributor
// b8eda974-7b85-4f76-af95-65846b26df6d    BuiltInRole     Storage File Data Privileged Reader
// 69566ab7-960f-475b-8e7c-b3118f30c6bd    BuiltInRole     Storage File Data Privileged Contributor
// a316ed6d-1efe-48ac-ac08-f7995a9c26fb    BuiltInRole     Storage Account Encryption Scope Contributor Role

//var StorageBlobDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if(enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

//****************************************************************
// Azure Storage Account
//****************************************************************

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storage_name
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

// resource privateDnsZonesblobExists 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'privatelink.blob.${environment().suffixes.storage}'
// }

// var blobDNSExists = contains(privateDnsZonesblobExists.tags, 'isResourceDeployed') && privateDnsZonesblobExists.tags['isResourceDeployed'] == 'true'

// resource privateDnsZonesfileExists 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'privatelink.blob.${environment().suffixes.storage}'
// }

// var fileDNSExists = contains(privateDnsZonesfileExists.tags, 'isResourceDeployed') && privateDnsZonesfileExists.tags['isResourceDeployed'] == 'true'


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
  {
    storageType: 'web'
    dnsExists: false
  }
  {
    storageType: 'dfs'
    dnsExists: false
  }
]

module moduleStorageAccountPrivateLink './moduleStorageAccountPrivateLink.bicep' = [for (link, index) in storagePrivateLinks: if (enablePrivateLink) {
  name: 'moduleStorageAccountPrivateLink-${link.storageType}'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    storage_name: storage.name
    storageType: link.storageType
    dnsExists: link.dnsExists
  }
}]

//****************************************************************
// Add Storage Account details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuestoragename './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: '${storage_appkey_name}storage_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_name'
    variables_value: storage.name
  }
}

module moduleAppConfigKeyValuestorageresourcegroup './moduleAppConfigKeyValue.bicep' =  if(enableAppConfig) {
  name: '${storage_appkey_name}storage_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${storage_appkey_name}storage_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output storage_name string = storage.name
output storage_resourcegroup string = resourceGroup().name
output storage_subscriptionId string = subscription().subscriptionId
