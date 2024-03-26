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

// resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (!empty(networksecuritygroupName)) {
//   name: networksecuritygroupName
// }

// resource routetable 'Microsoft.Network/routeTables@2023-09-01' existing = if (!empty(routetableName)) {
//   name: routetableName
// }

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

module moduleCreateSubnet './moduleCreateSubnet.bicep' = {
  name: 'moduleCreateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
    vnetIntegrationServiceName: 'Microsoft.Web/serverFarms'
    createSubnet: createSubnet
    networksecuritygroupName: networksecuritygroupName
    // networkSecurityGroup: {
    //   id: !empty(networksecuritygroupName) ? networksecuritygroup.id : null
    // }
    routetableName: routetableName
    // routetable: {
    //   id: !empty(routetableName) ? routetable.id : null
    // }
  }
}

resource virtualnetworkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: FunctionApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: moduleCreateSubnet.outputs.subnet_id
    swiftSupported: true
  }
}
