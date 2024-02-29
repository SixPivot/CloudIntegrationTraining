// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param AppName string = ''
param AppShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = ''
param Instance int = 1
param enableAppConfig bool = false
param enableDiagnostic bool = false
param enablePrivateLink bool = false
param virtualNetworkName string = ''
param subnetName string = ''

// tags
param tags object = {}

// storage account settings
param StorageSKUName string = ''
param enableHNS bool = false
param enablePublicNetworkAccess string = 'Enabled'

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param loganalyticsWorkspace_name string = ''

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
    publicNetworkAccess: enablePublicNetworkAccess
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

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = if(enablePrivateLink) {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = if(enablePrivateLink) {
  name: subnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(storage.name)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if(enablePrivateLink) {
  name: privateEndPointName
  location: AppLocation
  properties: {
    subnet: {
      id: subnet.id
    }
    customNetworkInterfaceName: '${privateEndPointName}-nic'
    privateLinkServiceConnections: [
      {
        name: privateEndPointName
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZones.name
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}

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
