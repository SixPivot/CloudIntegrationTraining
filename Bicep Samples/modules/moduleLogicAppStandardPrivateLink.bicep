param AppLocation string 
param EnvironmentName string
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param virtualNetworkSubscriptionId string 
param privatelinkSubnetName string 
param logicappstd_name string 
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string  

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicappstd_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(LogicAppStdApp.name)}'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
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
          privateLinkServiceId: LogicAppStdApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.azurewebsites.net'
  scope: resourceGroup(privateDNSZoneSubscriptionId,privateDNSZoneResourceGroup)
}

module moduleDNSZoneVirtualNetworkLinkLA './moduleDNSZoneVirtualNetworkLink.bicep' =  {
  name: 'moduleDNSZoneVirtualNetworkLinkLA'
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
        name: privateDnsZones.name
        properties: {
          privateDnsZoneId: privateDnsZones.id
        }
      }
    ]
  }
}

output DNSZone string = privateDnsZones.name
