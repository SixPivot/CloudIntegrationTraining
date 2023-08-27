param NamedValueName string
param NamedValueDisplayName string
param NamedValueTag string
param NamedValueSecret bool
param NamedValueValue string
param apimanagement_name string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// APIM API Version Set 
//****************************************************************\

resource apiversionset 'Microsoft.ApiManagement/service/apiVersionSets@2023-03-01-preview' = {
  name: 'string'
  parent: apimanagement
  properties: {
    description: 'string'
    displayName: 'string'
    versionHeaderName: 'string'
    versioningScheme: 'string'
    versionQueryName: 'string'
  }
}
