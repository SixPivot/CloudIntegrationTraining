param AppLocation string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 
param loganalyticsWorkspace_name string 
param loganalyticsPrivateLinkScopeId string


//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
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

var privateDnsZonesMonitor_name = 'privatelink.monitor.azure.com'

resource privateDnsZonesMonitor 'Microsoft.Network/privateDnsZones@2020-06-01' =  {
  name: privateDnsZonesMonitor_name
  location: 'global'
}

var privateDnsZonesOms_name = 'privatelink.oms.opinsights.azure.com'

resource privateDnsZonesOms 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZonesOms_name
  location: 'global'
}

var privateDnsZonesOds_name = 'privatelink.ods.opinsights.azure.com'

resource privateDnsZonesOds 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZonesOds_name
  location: 'global'
}

var privateDnsZonesAgentsvc_name = 'privatelink.agentsvc.azure-automation.net'

resource privateDnsZonesAgentsvc 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZonesAgentsvc_name
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
        name: privateDnsZonesMonitor_name
        properties: {
          privateDnsZoneId: privateDnsZoneLinkMonitor.id
        }
      }
      {
        name: privateDnsZonesOms_name
        properties: {
          privateDnsZoneId: privateDnsZoneLinkOms.id
        }
      }
      {
        name: privateDnsZonesOds_name
        properties: {
          privateDnsZoneId: privateDnsZoneLinkOds.id
        }
      }
      {
        name: privateDnsZonesAgentsvc_name
        properties: {
          privateDnsZoneId: privateDnsZoneLinkAgentsvc.id
        }
      }
    ]
  }
}
