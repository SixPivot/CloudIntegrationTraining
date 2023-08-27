param BackendName string
param BackendDescription string
param BackendProtocol string
param BackendURL string
param BackendResourceId string
param apimanagement_name string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// APIM Backend for Function App or Logic App
//****************************************************************

resource backend 'Microsoft.ApiManagement/service/backends@2023-03-01-preview' = {
  name: BackendName
  parent: apimanagement
  properties: {
    description: BackendDescription
    protocol: BackendProtocol
    resourceId: BackendResourceId
    url: BackendURL
  }
}
