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

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

@allowed([
  'A'
])
param KeyVaultSKUFamily string = 'A'

@allowed([
  'standard'
  'premium'
])
param KeyVaultSKUName string = 'standard'

//****************************************************************
// Variables
//****************************************************************

var keyvault_name = 'kv-${toLower(BaseName)}-${toLower(EnvironmentName)}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

//****************************************************************
// Azure Key Vault
//****************************************************************

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyvault_name
  location: AppLocation
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties: {
    sku: {
      family: KeyVaultSKUFamily
      name: KeyVaultSKUName
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
  }
}

resource keyvaultRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, AzureDevOpsServiceConnectionId, keyvaultadministrator)
  properties: {
    roleDefinitionId: keyvaultadministrator
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource keyvaultRoleAssignmentKeyVaultAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultAdministratorsGroupId, keyvaultadministrator)
  properties: {
    roleDefinitionId: keyvaultadministrator
    principalId: KeyVaultAdministratorsGroupId
    principalType: 'Group'
  }
}

resource keyvaultRoleAssignmentKeyVaultReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultReaderGroupId, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: KeyVaultReaderGroupId
    principalType: 'Group'
  }
}

//****************************************************************
// Add Key Vault name and resource group to App Configuration
//****************************************************************

module nestedTemplateAppConfigkeyvaultname './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'keyvault-name'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'keyvault-name'
    variables_value: keyvault.name
  }
}

module nestedTemplateAppConfigkeyvaultresourcegroup './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'keyvault-resourcegroup'
  scope: resourceGroup(appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'keyvault-resourcegroup'
    variables_value: resourceGroup().name
  }
}
