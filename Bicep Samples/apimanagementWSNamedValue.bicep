param NamedValueName string
param NamedValueDisplayName string
param NamedValueTag string
param NamedValueSecret bool
param NamedValueValue string
param apimanagement_name string 
param apimanagementworkspace_name string = ''


//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

resource apimanagementWorkspace 'Microsoft.ApiManagement/service/workspaces@2023-03-01-preview' existing = if (apimanagementworkspace_name != '') {
  name: apimanagementworkspace_name
  parent: apimanagement
}

//****************************************************************
// APIM Named Value for Workspace
//****************************************************************

resource namedvalue2 'Microsoft.ApiManagement/service/workspaces/namedValues@2023-03-01-preview' = {
  name: NamedValueName
  parent: apimanagementWorkspace
  properties: {
    displayName: NamedValueDisplayName
    secret: NamedValueSecret
    tags: [
      NamedValueTag
    ]
    value: NamedValueValue
  }
}
