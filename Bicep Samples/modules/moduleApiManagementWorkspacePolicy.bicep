// existing resources
param apimanagement_name string 
param apimanagement_workspace_name string 
param policyString string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

resource apimanagementWorkspace 'Microsoft.ApiManagement/service/workspaces@2023-03-01-preview' existing = {
  name: apimanagement_workspace_name
  parent: apimanagement
}

//****************************************************************
// Azure API Policy
//****************************************************************

resource policy 'Microsoft.ApiManagement/service/workspaces/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: apimanagementWorkspace
  properties: {
    format: 'rawxml'
    value: policyString
  }
}
