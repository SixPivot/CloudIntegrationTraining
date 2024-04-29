param AppLocation string 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string 
//param appconfig object
param resourcemanagerPL_name string
param resourcemanagerPL_resourceGroup string
param resourcemanagerPL_subscriptionId string

//****************************************************************
// Add Private Link for App Config
//****************************************************************
// prereq
//
// https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/create-private-link-access-commands?tabs=azure-cli
//
// az resourcemanagement private-link create \
//     --location AustraliaEast \
//     --resource-group CloudIntegrationTraining-Shared \
//     --name pl-rm-cloudintegrationtraining-shared-ause-001
//
// az private-link association create \
//     --management-group-id <root management groupid> \
//     --name <new-guid> \
//     --privatelink "/subscriptions/3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4/resourceGroups/CloudIntegrationTraining-Shared/providers/Microsoft.Authorization/resourceManagementPrivateLinks/pl-rm-cloudintegrationtraining-shared-ause-001" \
//     --public-network-access enabled

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

resource resourceManagementPrivateLinks 'Microsoft.Authorization/resourceManagementPrivateLinks@2020-05-01' existing = {
  name: resourcemanagerPL_name
  scope: resourceGroup(resourcemanagerPL_subscriptionId,resourcemanagerPL_resourceGroup)
}

var privateEndPointName = replace(resourcemanagerPL_name,'pl-','pep-')

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
          privateLinkServiceId: resourceManagementPrivateLinks.id
          groupIds: [
            'ResourceManagement'
          ]
        }
      }
    ]
  }
}

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azure.com'
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

output DNSZone string = privateDnsZones.name
