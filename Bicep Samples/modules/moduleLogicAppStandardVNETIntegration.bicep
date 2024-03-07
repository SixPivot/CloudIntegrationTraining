param AppLocation string = ''
param virtualNetworkName string = ''
param vnetintegrationSubnetName string = ''
param logicappstd_name string = ''

//****************************************************************
// Add Private Link for Storage Account 
//****************************************************************
resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicappstd_name
}

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
}

resource virtualnetworkConnection 'Microsoft.Web/sites/virtualNetworkConnections@2023-01-01' = {
  name: subnet.name
  parent: LogicAppStdApp
  properties: {
    vnetResourceId: virtualNetwork.id
    isSwift: true
  }
} 

module moduleLogicAppStandardCustomProperties './moduleLogicAppStandardCustomProperties.bicep' = {
  name: 'moduleLogicAppStandardCustomConfigAppConfig'
  params:{
    logicapp_name: logicappstd_name
    currentProperties: list(resourceId('Microsoft.Web/sites', logicappstd_name, 'properties'), '2022-03-01').properties
    newProperties: {
      virtualNetworkSubnetId: subnet.id
    }
  }
  dependsOn: [
    virtualnetworkConnection
  ] 
}