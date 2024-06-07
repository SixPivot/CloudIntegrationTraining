// environment parameters
param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'cit'
param EnvironmentName string = 'shared'
param EnvironmentShortName string = 'shr'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1

// tags
param tags object = {}

param virtualNetworkName string = '$(virtualNetworkName)'
param virtualNetworkResourceGroup string = '$(virtualNetworkResourceGroup)'
param virtualNetworkSubscriptionId string = '$(virtualNetworkSubscriptionId)'
param privatelinkSubnetName string = '$(privatelinkSubnetName)'

param DNSZoneList array = [
  {
    name: 'privatelink.azurewebsites.net'
  }
  {
    name: 'privatelink.vaultcore.azure.net'
  }
  {
    name: 'privatelink.servicebus.windows.net'
  }
  {
    name: 'privatelink.database.windows.net'
  }
  {
    name: 'privatelink.adf.azure.com'
  }
  {
    name: 'privatelink.blob.core.windows.net'
  }
  {
    name: 'privatelink.datafactory.azure.net'
  }
  {
    name: 'privatelink.dfs.core.windows.net'
  }
  {
    name: 'privatelink.file.core.windows.net'
  }
  {
    name: 'privatelink.queue.core.windows.net'
  }
  {
    name: 'privatelink.table.core.windows.net'
  }
  {
    name: 'privatelink.web.core.windows.net'
  }
  // {
  //   name: 'privatelink.azure-api.net'
  // }
  {
    name: 'azure-api.net'
  }
  {
    name: 'portal.azure-api.net'
  }
  {
    name: 'developer.azure-api.net'
  }
  {
    name: 'management.azure-api.net'
  }
  {
    name: 'scm.azure-api.net'
  }
]

module modulePrivateDNSZone './modules/modulePrivateDNSZone.bicep' = [for (zone, index) in DNSZoneList: {
  name: 'Zones-${replace(zone.name,'.','-')}'
  params: {
    DNSZoneName: zone.name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
  }
}]
