param virtualNetworkName string 
param vnetintegrationSubnetName string 
param subnetExist object
param defaultProperties object
param optionalProperties object

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = if (subnetExist == null)  {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
  properties: union(defaultProperties, optionalProperties)
}

output subnet_name string = subnetExist == null ? subnet.name : subnetExist.name
output subnet_id string = subnetExist == null ? subnet.id : subnetExist.id
