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

// 14b46e9e-c2b7-41b4-b07b-48a6ebf60603    BuiltInRole     Key Vault Crypto Officer
// f25e0fa2-a7c8-4377-a976-54943a77a395    BuiltInRole     Key Vault Contributor
// 00482a5a-887f-4fb3-b363-3b7fe8e74483    BuiltInRole     Key Vault Administrator
// 12338af0-0e69-4776-bea7-57ae8d297424    BuiltInRole     Key Vault Crypto User
// b86a8fe4-44ce-4948-aee5-eccb2c155cd7    BuiltInRole     Key Vault Secrets Officer
// 4633458b-17de-408a-b874-0445c86b69e6    BuiltInRole     Key Vault Secrets User
// a4417e6f-fecd-4de8-b567-7b0420556985    BuiltInRole     Key Vault Certificates Officer
// 21090545-7ca7-4776-b22c-e363652d74d2    BuiltInRole     Key Vault Reader
// e147488a-f6f5-4113-8e2d-b22465e65bf6    BuiltInRole     Key Vault Crypto Service Encryption User

var KeyVaultCryptoOfficer = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
var KeyVaultContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
var KeyVaultAdministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var KeyVaultCryptoUser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
var KeyVaultSecretsOfficer = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
var KeyVaultSecretsUser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var KeyVaultCertificatesOfficer = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
var KeyVaultReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
var KeyVaultCryptoServiceEncryptionUser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

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

resource keyvaultAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyvault
  name: 'AuditSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'Audit'
        enabled: true
      }
    ]
  }
}

resource keyvaultDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyvault
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource keyvaultRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, AzureDevOpsServiceConnectionId, KeyVaultAdministrator)
  properties: {
    roleDefinitionId: KeyVaultAdministrator
    principalId: AzureDevOpsServiceConnectionId
    principalType: 'ServicePrincipal'
  }
}

resource keyvaultRoleAssignmentKeyVaultAdministratorsGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultAdministratorsGroupId, KeyVaultAdministrator)
  properties: {
    roleDefinitionId: KeyVaultAdministrator
    principalId: KeyVaultAdministratorsGroupId
    principalType: 'Group'
  }
}

resource keyvaultRoleAssignmentKeyVaultReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, KeyVaultReaderGroupId, KeyVaultSecretsUser)
  properties: {
    roleDefinitionId: KeyVaultSecretsUser
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

output keyvault_name string = keyvault.name
output keyvault_id string = keyvault.id
output keyvault_location string = keyvault.location
output keyvault_resourcegroup string = resourceGroup().name
