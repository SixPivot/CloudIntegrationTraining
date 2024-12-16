param AppLocation string 
param EnvironmentName string
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param virtualNetworkSubscriptionId string  
param privatelinkSubnetName string 
param datafactory_name string 
param type string
param zone string 
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string  

// tags
param tags object = {}

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: datafactory_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(dataFactory.name)}-${(type)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndPointName
  location: AppLocation
  properties: {
    subnet: {
      id: subnet.id
    }
    customNetworkInterfaceName: 'nic-${privateEndPointName}'
    privateLinkServiceConnections: [
      {
        name: privateEndPointName
        properties: {
          privateLinkServiceId: dataFactory.id
          groupIds: [
            type
          ]
        }
      }
    ]
  }
}

var privateDnsZones_name = zone

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZones_name
  scope: resourceGroup(privateDNSZoneSubscriptionId,privateDNSZoneResourceGroup)
}

module moduleDNSZoneVirtualNetworkLinkDF './moduleDNSZoneVirtualNetworkLink.bicep' =  {
  name: 'moduleDNSZoneVirtualNetworkLinkDF'
  scope: resourceGroup(privateDNSZoneSubscriptionId,privateDNSZoneResourceGroup)
  params: {
    linkId: EnvironmentName
    DNSZone_name: privateDnsZones.name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    tags: {}
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZones_name
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}
