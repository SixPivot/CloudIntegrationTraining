param DNSZoneName string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param virtualNetworkSubscriptionId string 

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkSubscriptionId,virtualNetworkResourceGroup)
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: DNSZoneName
  location: 'global'
}

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZones
//   name: '${DNSZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: virtualNetwork.id
//     }
//   }
// }
