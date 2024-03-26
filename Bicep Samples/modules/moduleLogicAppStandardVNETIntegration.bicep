param virtualNetworkName string
param virtualNetworkResourceGroup string
param vnetintegrationSubnetName string
param vnetintegrationSubnetAddressPrefix string
param logicappstd_name string
param createSubnet bool
param networksecuritygroupName string
param routetableName string

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicappstd_name
}

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (!empty(networksecuritygroupName)) {
  name: networksecuritygroupName
}

// resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing =
//   if (!empty(networksecuritygroupName)) {
//     name: networksecuritygroupName
//   }

// resource routetable 'Microsoft.Network/routeTables@2023-09-01' existing =
//   if (!empty(routetableName)) {
//     name: routetableName
//   }

// var networksecuritygroupObject1 = {
//   id: !empty(networksecuritygroupName) ? networksecuritygroup.id : ''
// }

// var networksecuritygroupObject2 = {}

// var routetableObject1 = {
//   id: !empty(routetableName) ? routetable.id : ''
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
    // networkSecurityGroup: !empty(networksecuritygroupName) ? networksecuritygroupObject1 : networksecuritygroupObject2
    routetableName: routetableName
    //routetable: !empty(routetableName) ? routetableObject1 : routetableObject2
  }
}

module moduleUpdateSubnet './moduleUpdateSubnet.bicep' = if(createSubnet) {
  name: 'moduleUpdateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params:{
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
    vnetIntegrationServiceName: 'Microsoft.Web/serverFarms'
    currentProperties: moduleCreateSubnet.outputs.subnet_properties
    newProperties:{
      networkSecurityGroup:{
        id: networksecuritygroup.id
      }
    }
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
