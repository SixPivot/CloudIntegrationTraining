// param EnvironmentName string
// param virtualNetworkName string 
// param virtualNetworkResourceGroup string
// param virtualNetworkSubscriptionId string  
param apimanagement_privateIpAddress string
param apimanagement_name string
//param privateDNSZoneResourceGroup string 
//param privateDNSZoneSubscriptionId string  

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'azure-api.net'
}

resource dnsZoneA1 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: apimanagement_name
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}

resource dnsZoneA2 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: '${apimanagement_name}.portal'
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}

resource dnsZoneA3 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: '${apimanagement_name}.developer'
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}

resource dnsZoneA4 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: '${apimanagement_name}.management'
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}

resource dnsZoneA5 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZones
  name: '${apimanagement_name}.scm'
  properties: {
    ttl: 36000
    aRecords: [
      {
        ipv4Address: apimanagement_privateIpAddress
      }
    ]
  }
}
