param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
param functionapp_name string 
param createSubnet bool 
param networksecuritygroupName string 
param routetableName string 

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource FunctionApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionapp_name
}

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (networksecuritygroupName != 'empty') {
  name: networksecuritygroupName
}

resource routetable 'Microsoft.Network/routeTables@2023-09-01' existing = if (routetableName != 'empty') {
  name: routetableName
}

// var networksecuritygroupObject1 ={
//   networkSecurityGroup : {
//   id: !empty(networksecuritygroupName) ? networksecuritygroup.id : ''
// }
// }

// var networksecuritygroupObject2 = {}

// var routetableObject1 = {
//   routetable : {
//   id: !empty(routetableName) ? routetable.id : ''
// }
// }

// var routetableObject2 = {}

var newProperties1 = networksecuritygroupName != 'empty' ? { networkSecurityGroup: { id: networksecuritygroup.id } } : ''
var newProperties2 = routetableName != 'empty' ? { routeTable: { id: routetable.id } } : ''

// module moduleCreateSubnet './moduleCreateSubnet.bicep' = {
//   name: 'moduleCreateSubnet'
//   scope: resourceGroup(virtualNetworkResourceGroup)
//   params: {
//     virtualNetworkName: virtualNetworkName
//     vnetintegrationSubnetName: vnetintegrationSubnetName
//     vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
//     vnetIntegrationServiceName: 'Microsoft.Web/serverFarms'
//     createSubnet: createSubnet
//   }
// }

var currentProperties = {
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

module moduleUpdateSubnet './moduleUpdateSubnet.bicep' = if (createSubnet) {
  name: 'moduleUpdateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params:{
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
    vnetIntegrationServiceName: 'Microsoft.Web/serverFarms'
    currentProperties: currentProperties
    newProperties:{
      networkSecurityGroup:{
        id: networksecuritygroup.id
      }
    }
  }
}

resource virtualnetworkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: FunctionApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: moduleUpdateSubnet.outputs.subnet_id
    swiftSupported: true
  }
}
