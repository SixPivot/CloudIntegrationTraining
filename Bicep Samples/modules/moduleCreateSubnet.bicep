param virtualNetworkName string 
param vnetintegrationSubnetName string 
param createSubnet bool
param defaultProperties object
param optionalProperties object

resource virtualNetwork 'Microsoft.Network/VirtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
}

resource subnetExist 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = if (!createSubnet) {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  name: vnetintegrationSubnetName
  parent: virtualNetwork
  properties: union(defaultProperties, optionalProperties)
}

output subnet_name string = createSubnet ? subnet.name : subnetExist.name
output subnet_id string = createSubnet ? subnet.id : subnetExist.id
