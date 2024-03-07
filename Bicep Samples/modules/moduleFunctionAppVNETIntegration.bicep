param virtualNetworkName string = ''
param vnetintegrationSubnetName string = ''
param vnetintegrationSubnetAddressPrefix string = ''
param functionapp_name string = ''

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource FunctionApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionapp_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: vnetintegrationSubnetAddressPrefix
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource virtualnetworkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
  parent: FunctionApp
  name: 'virtualNetwork'
  properties: {
    //subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, vnetintegrationSubnetName)
    subnetResourceId: subnet.id
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
