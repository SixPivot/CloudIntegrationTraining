param linkId string
param name string
param resourceGroup string
param subscriptionId string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: name
  scope: resourceGroup(subscriptionId, resourceGroup)
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZone.name}-${linkId}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}
