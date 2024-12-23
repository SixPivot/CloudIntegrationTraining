param virtualNetworkName string
param virtualNetworkResourceGroup string
param logicappstd_subnet string
//param logicappstd_name string
param logicappstd_subnet_name string
param networksecuritygroupName string
param routetableName string

param EnvironmentName string 

param enableAppConfig bool 
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 

// resource LogicAppStdApp 'Microsoft.Web/sites@2023-12-01' existing = {
//   name: logicappstd_name
// }

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-11-01' existing = if (networksecuritygroupName != 'none') {
  name: networksecuritygroupName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource routetable 'Microsoft.Network/routeTables@2023-11-01' existing = if (routetableName != 'none') {
  name: routetableName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

var newProperties1 = networksecuritygroupName != 'none' ? { networkSecurityGroup: { id: networksecuritygroup.id } } : {}
var newProperties2 = routetableName != 'none' ? { routeTable: { id: routetable.id } } : {}

var defaultProperties = {
  addressPrefix: logicappstd_subnet
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

module moduleCreateSubnetLogic './moduleCreateSubnetLogic.bicep' = {
  name: 'moduleCreateSubnetLogic'
  scope: resourceGroup(virtualNetworkResourceGroup)
  params: {
    virtualNetworkName: virtualNetworkName
    vnetintegrationSubnetName: logicappstd_subnet_name
    defaultProperties: defaultProperties
    optionalProperties: union(newProperties1, newProperties2)
  }
}

//****************************************************************
// Add Logic App subnet details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuelogicappstsubnetname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'logicapp_subnet_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'logicapp_subnet_name'
    variables_value: moduleCreateSubnetLogic.outputs.subnet_name
  }
}

module moduleAppConfigKeyValuelogicappstsubnetid './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'logicapp_subnet_id'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'logicapp_subnet_id'
    variables_value: moduleCreateSubnetLogic.outputs.subnet_id
  }
}
