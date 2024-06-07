param AppLocation string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 
param loganalyticsWorkspace_name string 
param loganalyticsPrivateLinkScopeId string 
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string  


//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

var privateEndPointName = 'pep-${(loganalyticsWorkspace_name)}'

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
          privateLinkServiceId: loganalyticsPrivateLinkScopeId
          groupIds: [
            'azuremonitor'
          ]
        }
      }
    ]
  }
}

resource privateDnsZonesMonitor 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.monitor.azure.com'
  location: 'global'
}

resource privateDnsZonesOms 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.oms.opinsights.azure.com'
  location: 'global'
}

resource privateDnsZonesOds 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.ods.opinsights.azure.com'
  location: 'global'
}

resource privateDnsZonesAgentsvc 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.agentsvc.azure-automation.net'
  location: 'global'
}

resource privateDnsZoneLinkMonitor 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonesMonitor
  name: '${privateDnsZonesMonitor.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneLinkOms 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonesOms
  name: '${privateDnsZonesOms.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneLinkOds 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonesOds
  name: '${privateDnsZonesOds.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource privateDnsZoneLinkAgentsvc 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZonesAgentsvc
  name: '${privateDnsZonesAgentsvc.name}-link'
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
        name: privateDnsZonesMonitor.name
        properties: {
          privateDnsZoneId: privateDnsZonesMonitor.id
        }
      }
      {
        name: privateDnsZonesOms.name
        properties: {
          privateDnsZoneId: privateDnsZonesOms.id
        }
      }
      {
        name: privateDnsZonesOds.name
        properties: {
          privateDnsZoneId: privateDnsZonesOds.id
        }
      }
      {
        name: privateDnsZonesAgentsvc.name
        properties: {
          privateDnsZoneId: privateDnsZonesAgentsvc.id
        }
      }
    ]
  }
}

output DNSZoneMonitor string = privateDnsZonesMonitor.name
output DNSZoneOms string = privateDnsZonesOms.name
output DNSZoneOds string = privateDnsZonesOds.name
output DNSZoneAgentsvc string = privateDnsZonesAgentsvc.name
