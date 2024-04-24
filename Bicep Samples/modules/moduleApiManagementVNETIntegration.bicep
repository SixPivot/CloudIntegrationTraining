param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
//param createSubnet bool 
param networksecuritygroupName string 
param routetableName string 

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (networksecuritygroupName != 'none') {
  name: networksecuritygroupName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource routetable 'Microsoft.Network/routeTables@2023-09-01' existing = if (routetableName != 'none') {
  name: routetableName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

var newProperties1 = networksecuritygroupName != 'none' ? { networkSecurityGroup: { id: networksecuritygroup.id } } : {}
var newProperties2 = routetableName != 'none' ? { routeTable: { id: routetable.id } } : {}

var defaultProperties = {
  addressPrefix: vnetintegrationSubnetAddressPrefix
  delegations: [
    // {
    //   name: 'delegation'
    //   properties: {
    //     serviceName: 'Microsoft.ApiManagement/service'
    //   }
    // }
  ]
  serviceEndpoints: [
    {
      service: 'Microsoft.KeyVault'
      locations: [
        '*'
      ]
    }
    {
      service: 'Microsoft.EventHub'
      locations: [
        '*'
      ]
    }
    {
      service: 'Microsoft.Sql'
      locations: [
        '*'
      ]
    }
    {
      service: 'Microsoft.Storage'
      locations: [
        '*'
      ]
    }
    {
      service: 'Microsoft.ServiceBus'
      locations: [
        '*'
      ]
    }
  ]
  privateEndpointNetworkPolicies: 'Disabled'
  privateLinkServiceNetworkPolicies: 'Enabled'
}

module moduleCreateSubnet './moduleCreateSubnet.bicep' = {
  name: 'moduleCreateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    defaultProperties: defaultProperties
    optionalProperties: union(newProperties1, newProperties2)
  }
}

output apim_subnet_id string = moduleCreateSubnet.outputs.subnet_id
