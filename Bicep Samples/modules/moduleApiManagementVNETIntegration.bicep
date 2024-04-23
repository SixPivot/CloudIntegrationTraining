param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
param createSubnet bool 
param networksecuritygroupName string 
param routetableName string 

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (networksecuritygroupName != 'none') {
  name: networksecuritygroupName
}

resource routetable 'Microsoft.Network/routeTables@2023-09-01' existing = if (routetableName != 'none') {
  name: routetableName
}

var newProperties1 = networksecuritygroupName != 'none' ? { networkSecurityGroup: { id: networksecuritygroup.id } } : {}
var newProperties2 = routetableName != 'none' ? { routeTable: { id: routetable.id } } : {}

var defaultProperties = {
  addressPrefix: vnetintegrationSubnetAddressPrefix
  delegations: [
    {
      name: 'delegation'
      properties: {
        serviceName: 'Microsoft.ApiManagment/service'
      }
    }
  ]
  privateEndpointNetworkPolicies: 'Disabled'
  privateLinkServiceNetworkPolicies: 'Enabled'
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnetExist 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
}

module moduleCreateSubnet './moduleCreateSubnet.bicep' = {
  name: 'moduleCreateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    defaultProperties: defaultProperties
    optionalProperties: union(newProperties1, newProperties2)
    createSubnet: createSubnet
    subnetExist: subnetExist
  }
}

output apim_subnet_id string = subnetExist != null ? subnetExist.id : moduleCreateSubnet.outputs.subnet_id