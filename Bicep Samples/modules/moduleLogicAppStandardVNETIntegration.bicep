param virtualNetworkName string
param virtualNetworkResourceGroup string
param vnetintegrationSubnetName string
param vnetintegrationSubnetAddressPrefix string
param logicappstd_name string
param createSubnet bool
param networksecuritygroupName string
param routetableName string

resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicappstd_name
}

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
        serviceName: 'Microsoft.Web/serverFarms'
      }
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
    createSubnet: createSubnet
  }
}

resource virtualnetworkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: LogicAppStdApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: moduleCreateSubnet.outputs.subnet_id
    swiftSupported: true
  }
}
