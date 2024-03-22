param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
param functionapp_name string 
param createSubnet bool 

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource FunctionApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionapp_name
}

module moduleCreateSubnet './moduleCreateSubnet.bicep' = {
  name: 'moduleCreateSubnet'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: vnetintegrationSubnetName
    vnetintegrationSubnetAddressPrefix: vnetintegrationSubnetAddressPrefix
    vnetIntegrationServiceName: 'Microsoft.Web/serverFarms'
    createSubnet: createSubnet
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

// resource virtualnetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-01-01' = {
//   name: subnet.name
//   parent: LogicAppStdApp
//   properties: {
//     vnetResourceId: virtualNetwork.id
//     isSwift: true
//   }
// } 

// module moduleLogicAppStandardCustomProperties './moduleLogicAppStandardCustomProperties.bicep' = {
//   name: 'moduleLogicAppStandardCustomProperties'
//   params:{
//     logicapp_name: logicappstd_name
//     currentProperties: LogicAppStdApp.properties
//     newProperties: {
//       virtualNetworkSubnetId: subnet.id
//     }
//   }
//   dependsOn: [
//     virtualnetworkConnection
//   ] 
// }
