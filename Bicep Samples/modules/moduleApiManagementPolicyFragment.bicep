// parameters
param apimanagement_name string
param policyFragmentName string
param policyFragmentDescription string  
param policyFragmentString string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// Azure API Policy
//****************************************************************

resource policy 'Microsoft.ApiManagement/service/policyFragments@2023-09-01-preview' = {
  name: policyFragmentName
  parent: apimanagement
  properties: {
    description: policyFragmentDescription
    format: 'rawxml'
    value: policyFragmentString
  }
}
