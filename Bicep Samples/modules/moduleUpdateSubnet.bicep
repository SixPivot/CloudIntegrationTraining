param virtualNetworkName string 
param vnetintegrationSubnetName string 
param vnetintegrationSubnetAddressPrefix string 
param vnetIntegrationServiceName string
param currentProperties object
param newProperties object

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
  properties: union(currentProperties, newProperties)
}

output subnet_name string = subnet.name
output subnet_id string = subnet.id 
output subnet_properties object = list(resourceId('Microsoft.Network/virtualNetworks/subnets', vnetintegrationSubnetName), '2023-04-01').properties
