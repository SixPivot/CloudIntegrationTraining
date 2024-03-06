param AppLocation string = ''
param virtualNetworkName string = ''
param subnetName string = ''
param storage_name string = ''
param storageType string = ''
param dnsExists bool = false

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storage_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: subnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(storage.name)}-${(storageType)}'

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
          privateLinkServiceId: storage.id
          groupIds: [
            storageType
          ]
        }
      }
    ]
  }
}

var privateDnsZones_name = 'privatelink.${storageType}.${environment().suffixes.storage}'

resource privateDnsZonesExists 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZones_name
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = if (!dnsExists) {
  name: privateDnsZones_name
  location: 'global'
  tags: {
    isResourceDeployed: 'true'
  }
}


resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (!dnsExists) {
  parent: privateDnsZones
  name: '${privateDnsZones_name}-link'
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
        name: privateDnsZones_name
        properties: {
          privateDnsZoneId: !dnsExists ? privateDnsZonesExists.id : privateDnsZones.id
        }
      }
    ]
  }
  dependsOn: [
    privateDnsZoneLink
  ]
}
