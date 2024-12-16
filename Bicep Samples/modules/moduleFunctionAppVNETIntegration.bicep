param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param functionapp_subnet string 
param functionapp_subnet_name string
param networksecuritygroupName string 
param routetableName string 

param EnvironmentName string 

param enableAppConfig bool 
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 

// resource FunctionApp 'Microsoft.Web/sites@2022-09-01' existing = {
//   name: functionapp_name
// }

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
  addressPrefix: functionapp_subnet
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

module moduleCreateSubnetFunc './moduleCreateSubnetFunc.bicep' = {
  name: 'moduleCreateSubnetFunc'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: functionapp_subnet_name
    defaultProperties: defaultProperties
    optionalProperties: union(newProperties1, newProperties2)
  }
}

// resource virtualnetworkConfig 'Microsoft.Web/sites/networkConfig@2023-01-01' = {
//   parent: FunctionApp
//   name: 'virtualNetwork'
//   properties: {
//     subnetResourceId: moduleCreateSubnet.outputs.subnet_id
//     swiftSupported: true
//   }
// }

//****************************************************************
// Add functionapp subnet details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuefunctionappsubnetname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'functionapp_subnet_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'functionapp_subnet_name'
    variables_value: moduleCreateSubnetFunc.outputs.subnet_name
  }
}

module moduleAppConfigKeyValuefunctionappsubnetid './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'functionapp_subnet_id'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'functionapp_subnet_id'
    variables_value: moduleCreateSubnetFunc.outputs.subnet_id
  }
}
