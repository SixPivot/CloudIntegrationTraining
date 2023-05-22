
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

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'


@allowed([
  'Free'
  'Standard'
])
param appConfigSku string = 'Free'

//****************************************************************
// Variables
//****************************************************************

var appconfig_name = 'appcs-${toLower(BaseName)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
var appconfigdataowner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var appconfigdatareader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

//****************************************************************
// Azure App Config
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appconfig_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  sku: {
    name: appConfigSku
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appconfigRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AzureDevOpsServiceConnectionId, appconfigdataowner)
  properties: {
    roleDefinitionId: appconfigdataowner
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource appconfigRoleAssignmentAppConfigAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AppConfigAdministratorsGroupId, appconfigdataowner)
  properties: {
    roleDefinitionId: appconfigdataowner
    principalId: AppConfigAdministratorsGroupId
    principalType: 'Group'
  }
}

resource appconfigRoleAssignmentAppConfigReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, AppConfigReaderGroupId, appconfigdatareader)
  properties: {
    roleDefinitionId: appconfigdatareader
    principalId: AppConfigReaderGroupId
    principalType: 'Group'
  }
}

output appconfig_name string = appconfig.name
output appconfig_resourcegroup string = resourceGroup().name
