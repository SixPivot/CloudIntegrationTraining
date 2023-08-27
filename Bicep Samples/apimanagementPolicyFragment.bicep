param PolicyFragmentName string
param PolicyFragmentDescription string
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

var Policy_Fragment = loadTextContent('./PolicyFragments/PolicyFragment1.xml')

resource policyfragment 'Microsoft.ApiManagement/service/policyFragments@2023-03-01-preview' = {
  name: PolicyFragmentName
  parent: apimanagement
  properties: {
    description: PolicyFragmentDescription
    format: 'xml'
    value: Policy_Fragment
  }
}

