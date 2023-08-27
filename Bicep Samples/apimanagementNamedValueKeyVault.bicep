param NamedValueName string
param IdentityClientId string = ''
param SecretIdentifier string
param NamedValueDisplayName string
param NamedValueTag string
param apimanagement_name string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// APIM Named Value referencing Key Vault
//****************************************************************

resource namedvalue1 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  name: NamedValueName
  parent: apimanagement
  properties: {
    displayName: NamedValueDisplayName
    keyVault: {
      identityClientId: IdentityClientId == '' ? null : IdentityClientId
      secretIdentifier: SecretIdentifier
    }
    tags: [
      NamedValueTag
    ]
  }
}
