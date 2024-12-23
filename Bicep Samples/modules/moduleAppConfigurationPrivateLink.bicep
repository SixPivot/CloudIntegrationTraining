param AppLocation string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param virtualNetworkSubscriptionId string 
param privatelinkSubnetName string 
//param appconfig object
param appconfig_name string
// tags
param tags object = {}

//****************************************************************
// Add Private Link for App Config
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-08-01-preview' existing = {
  name: appconfig_name
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkSubscriptionId,virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(appconfig.name)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndPointName
  location: AppLocation
  tags: tags
  properties: {
    subnet: {
      id: subnet.id
    }
    customNetworkInterfaceName: 'nic-${privateEndPointName}'
    privateLinkServiceConnections: [
      {
        name: privateEndPointName
        properties: {
          privateLinkServiceId: appconfig.id
          groupIds: [
            'configurationStores'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azconfig.io'
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZones
  name: '${privateDnsZones.name}-link'
  location: 'global'
  tags: tags
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

output DNSZone string = privateDnsZones.name
