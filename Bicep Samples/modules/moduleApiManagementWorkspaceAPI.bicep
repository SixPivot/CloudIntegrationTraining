// existing resources
param apimanagement_name string = ''
param apimanagement_workspace_name string = ''
param apiName string = ''
param apiPath string = ''

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
// API apiVersionSet
//****************************************************************

resource apiVersionSet 'Microsoft.ApiManagement/service/workspaces/apiVersionSets@2023-03-01-preview' = {
  name: apiName
  parent: apimanagementWorkspace
  properties: {
    displayName: apiName
    versioningScheme: 'Segment'
  }
}

//****************************************************************
// API
//****************************************************************

resource API 'Microsoft.ApiManagement/service/workspaces/apis@2023-03-01-preview' = {
  name: apiName
  parent: apimanagementWorkspace
  properties:{
    displayName:'${apiName} APIs'
    path: apiPath 
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    apiVersion: 'V1'
    apiVersionSetId: apiVersionSet.id
  }
}
