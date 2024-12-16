param EnvironmentName string
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param virtualNetworkSubscriptionId string  
param apimanagement_privateIpAddress string
param apimanagement_name string
param apimanagement_customdomain string
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string  

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: apimanagement_customdomain
}

resource dnsZoneApi 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: 'api.${toLower(EnvironmentName)}'
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}

// resource privateDnsZones1 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'azure-api.net'
// }

// resource privateDnsZones2 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'portal.azure-api.net'
// }

// resource privateDnsZones3 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'developer.azure-api.net'
// }

// resource privateDnsZones4 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'management.azure-api.net'
// }

// resource privateDnsZones5 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
//   name: 'scm.azure-api.net'
// }

// resource dnsZoneA1 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZones1
//   name: apimanagement_name
//   properties: {
//     ttl: 36000
//     aRecords: [
//       {
//         ipv4Address: apimanagement_privateIpAddress
//       }
//     ]
//   }
// }

// module moduleDNSZoneVirtualNetworkLink1 './moduleDNSZoneVirtualNetworkLink.bicep' =  {
//   name: 'moduleDNSZoneVirtualNetworkLink1'
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: privateDnsZones1.name
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
//     tags: {}
//   }
// }

// resource dnsZoneA2 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZones2
//   name: apimanagement_name
//   properties: {
//     ttl: 36000
//     aRecords: [
//       {
//         ipv4Address: apimanagement_privateIpAddress
//       }
//     ]
//   }
// }

// module moduleDNSZoneVirtualNetworkLink2 './moduleDNSZoneVirtualNetworkLink.bicep' =  {
//   name: 'moduleDNSZoneVirtualNetworkLink2'
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: privateDnsZones2.name
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
//     tags: {}
//   }
// }

// resource dnsZoneA3 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZones3
//   name: apimanagement_name
//   properties: {
//     ttl: 36000
//     aRecords: [
//       {
//         ipv4Address: apimanagement_privateIpAddress
//       }
//     ]
//   }
// }

// module moduleDNSZoneVirtualNetworkLink3 './moduleDNSZoneVirtualNetworkLink.bicep' =  {
//   name: 'moduleDNSZoneVirtualNetworkLink3'
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: privateDnsZones3.name
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
//     tags: {}
//   }
// }

// resource dnsZoneA4 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZones4
//   name: apimanagement_name
//   properties: {
//     ttl: 36000
//     aRecords: [
//       {
//         ipv4Address: apimanagement_privateIpAddress
//       }
//     ]
//   }
// }

// module moduleDNSZoneVirtualNetworkLink4 './moduleDNSZoneVirtualNetworkLink.bicep' =  {
//   name: 'moduleDNSZoneVirtualNetworkLink4'
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: privateDnsZones4.name
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
//     tags: {}
//   }
// }

// resource dnsZoneA5 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZones5
//   name: apimanagement_name
//   properties: {
//     ttl: 36000
//     aRecords: [
//       {
//         ipv4Address: apimanagement_privateIpAddress
//       }
//     ]
//   }
// }

// module moduleDNSZoneVirtualNetworkLink5 './moduleDNSZoneVirtualNetworkLink.bicep' =  {
//   name: 'moduleDNSZoneVirtualNetworkLink5'
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: privateDnsZones5.name
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
//     tags: {}
//   }
// }
