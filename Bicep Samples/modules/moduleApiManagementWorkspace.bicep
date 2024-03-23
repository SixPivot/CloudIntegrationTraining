// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = 'ause'
param Instance int = 1
param apimanagementworkspace_name string = ''
param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool 
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param apimanagement_name string = ''


// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// Azure API Management Workspace
//****************************************************************

resource apimanagementWorkspace 'Microsoft.ApiManagement/service/workspaces@2023-03-01-preview' = {
  name: apimanagementworkspace_name
  parent: apimanagement
  properties: {
    description: '${apimanagementworkspace_name} Workspace'
    displayName: apimanagementworkspace_name
  }
}

//****************************************************************
// Add API Management details to App Configuration
//****************************************************************

module moduleAppConfigKeyValueapimanagementworkspacename './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'apimanagement_${apimanagementworkspace_name}_workspace_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_${apimanagementworkspace_name}_workspace_name'
    variables_value: apimanagementWorkspace.name
  }
}

output apimanagement_workspace_name string = apimanagementWorkspace.name
output apimanagement_workspace_id string = apimanagementWorkspace.id
