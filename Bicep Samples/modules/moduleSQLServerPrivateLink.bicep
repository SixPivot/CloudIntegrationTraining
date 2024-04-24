param AppLocation string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 
param sqlserver_name string 

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************

resource sqlserver 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlserver_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(sqlserver.name)}'

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
          privateLinkServiceId: sqlserver.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
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
