param networksecuritygroupName string 

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = if (networksecuritygroupName != 'none') {
  name: networksecuritygroupName
}

resource APIMManagementEndpoint 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMManagementEndpoint'
  parent: networksecuritygroup
  properties: {
    direction: 'Inbound'
    description: 'APIMManagementEndpoint'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3443'
    sourceAddressPrefix: 'ApiManagement'
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 100
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource AzureInfrastructureLoadBalancer 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'AzureInfrastructureLoadBalancer'
  parent: networksecuritygroup
  properties: {
    direction: 'Inbound'
    description: 'AzureInfrastructureLoadBalancer'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '6390'
    sourceAddressPrefix: 'AzureLoadBalancer'
    destinationAddressPrefix: 'VirtualNetwork'
    access: 'Allow'
    priority: 110
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

// resource allowouttodns 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
//   name: 'allow-out-to-dns'
//   parent: networksecuritygroup
//   properties: {
//     direction: 'Outbound'
//     description: 'allow-out-to-dns'
//     protocol: 'Tcp'
//     sourcePortRange: '*'
//     destinationPortRange: '53'
//     sourceAddressPrefix: '*'
//     destinationAddressPrefix: '168.63.129.16'
//     access: 'Allow'
//     priority: 100
//     sourcePortRanges: []
//     destinationPortRanges: []
//     sourceAddressPrefixes: []
//     destinationAddressPrefixes: []
//   }
// }

resource APIMStorage 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMStorage'
  parent: networksecuritygroup
  properties: {
    direction: 'Outbound'
    description: 'APIMStorage'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'Storage'
    access: 'Allow'
    priority: 120
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource APIMSQL 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMSQL'
  parent: networksecuritygroup
  properties: {
    direction: 'Outbound'
    description: 'APIMSQL'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1433'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'Sql'
    access: 'Allow'
    priority: 130
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}
    
resource APIMKeyVault 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMKeyVault'
  parent: networksecuritygroup
  properties: {
    direction: 'Outbound'
    description: 'APIMKeyVault'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'AzureKeyVault'
    access: 'Allow'
    priority: 140
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource APIMAzureMonitor 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMAzureMonitor'
  parent: networksecuritygroup
  properties: {
    direction: 'Outbound'
    description: 'APIMAzureMonitor'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '1886'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'AzureMonitor'
    access: 'Allow'
    priority: 150
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource APIMAzureMonitor443 'Microsoft.Network/networkSecurityGroups/securityRules@2023-11-01' = {
  name: 'APIMAzureMonitor443'
  parent: networksecuritygroup
  properties: {
    direction: 'Outbound'
    description: 'APIMAzureMonitor443'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '443'
    sourceAddressPrefix: 'VirtualNetwork'
    destinationAddressPrefix: 'AzureMonitor'
    access: 'Allow'
    priority: 160
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}
