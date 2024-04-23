// parameters
param apimanagement_name string 
param policyString string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// Azure API Policy
//****************************************************************

resource policy 'Microsoft.ApiManagement/service/policies@2023-05-01-preview' = {
  name: 'policy'
  parent: apimanagement
  properties: {
    format: 'rawxml'
    value: policyString
  }
}
