// existing resources
param apimanagement_name string 
param apiName string 
param apiPath string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// API apiVersionSet
//****************************************************************

resource apiVersionSet 'Microsoft.ApiManagement/service/apiVersionSets@2023-05-01-preview' = {
  name: apiName
  parent: apimanagement
  properties: {
    displayName: apiName
    versioningScheme: 'Segment'
  }
}

//****************************************************************
// API
//****************************************************************

resource API 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' = {
  name: apiName
  parent: apimanagement
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
