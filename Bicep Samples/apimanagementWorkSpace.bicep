// environment parameters
param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'CIT'
param EnvironmentName string = 'Global'
param EnvironmentShortName string = 'Gbl'
param AppLocation string = resourceGroup().location

// tags
param LocationTag string = resourceGroup().location
param OwnerTag string = 'CloudIntegrationTraining'
param OrganisationTag string = 'CloudIntegrationTraining'
param EnvironmentTag string = 'CloudIntegrationTraining'
param ApplicationTag string = 'CloudIntegrationTraining'

// existing resources
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param loganalyticsWorkspace_name string = '$(loganalyticsWorkspace_name)'
param appInsights_name string = '$(appInsights_name)'
param keyvault_name string = '$(keyvault_name)'
param apimanagement_name string = '$(apimanagement_name)'
param apimanagementworkspace_prefix string = '$(apimanagementworkspace_prefix)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Isolated'
  'Premium'
  'Standard'
])
param ApiManagementSKUName string = 'Developer'
param ApiManagementCapacity int = 0
param ApiManagementPublisherEmail string = 'bill@biztalkbill.com'

//****************************************************************
// Variables
//****************************************************************

var apimanagementworkspace_name = '${toLower(apimanagementworkspace_prefix)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
// ef1c2c96-4a77-49e8-b9a4-6179fe1d2fd2    BuiltInRole     API Management Workspace Reader
// 73c2c328-d004-4c5e-938c-35c6f5679a1f    BuiltInRole     API Management Workspace API Product Manager
// 56328988-075d-4c6a-8766-d93edd6725b6    BuiltInRole     API Management Workspace API Developer
// d59a3e9c-6d52-4a5a-aeed-6bf3cf0e31da    BuiltInRole     API Management Service Workspace API Product Manager
// 9565a273-41b9-4368-97d2-aeb0c976a9b3    BuiltInRole     API Management Service Workspace API Developer
// 0c34c906-8d99-4cb7-8bb7-33f5b0a1a799    BuiltInRole     API Management Workspace Contributor
var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

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

module nestedTemplateAppConfigapimanagementprincipalid './nestedTemplateAppConfigKeyValue.bicep' = {
  name: apimanagementworkspace_name
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: apimanagementworkspace_name
    variables_value: apimanagementWorkspace.name
  }
}

output apimanagement_workspace_name string = apimanagementWorkspace.name
output apimanagement_workspace_id string = apimanagementWorkspace.id
