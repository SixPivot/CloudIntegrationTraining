param virtualNetworkName string 
param vnetintegrationSubnetName string 
param defaultProperties object
param optionalProperties object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: 'snet-${vnetintegrationSubnetName}'
  parent: virtualNetwork
  properties: union(defaultProperties, optionalProperties)
}

output subnet_name string = subnet.name 
output subnet_id string = subnet.id 
