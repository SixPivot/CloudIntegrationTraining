param keyvault_name string
param secretName string
param secretValue string
param tags object = {}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

resource keyvaultSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: secretName
  parent: keyvault
  tags: tags
  properties:{
    value: secretValue
  }
}

output secretUri string = keyvaultSecret.properties.secretUri
