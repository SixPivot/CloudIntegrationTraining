param apimanagement_name string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// APIM Policy For All APIs
//****************************************************************

var Policy_Global = loadTextContent('./Policies/Global.xml')

resource policy 'Microsoft.ApiManagement/service/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: apimanagement
  properties: {
    format: 'xml'
    value: Policy_Global
  }
}
