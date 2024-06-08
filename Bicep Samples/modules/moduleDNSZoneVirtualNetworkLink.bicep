param linkId string
param DNSZone_name string
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param virtualNetworkSubscriptionId string 

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: DNSZone_name
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkSubscriptionId, virtualNetworkResourceGroup)
}

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: '${privateDnsZone.name}-${linkId}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: virtualNetwork.id
//     }
//   }
// }
