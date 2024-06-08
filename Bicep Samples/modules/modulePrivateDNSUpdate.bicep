param DNSZoneName string 
param privateEndPointName string
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param virtualNetworkSubscriptionId string 

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkSubscriptionId,virtualNetworkResourceGroup)
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' existing = {
  name: privateEndPointName
  scope: resourceGroup(virtualNetworkSubscriptionId,virtualNetworkResourceGroup)
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: DNSZoneName
  location: 'global'
}

// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
//   parent: privateEndpoint
//   name: 'default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: privateDnsZones.name
//         properties: {
//           privateDnsZoneId: privateDnsZones.id
//         }
//       }
//     ]
//   }
// }

