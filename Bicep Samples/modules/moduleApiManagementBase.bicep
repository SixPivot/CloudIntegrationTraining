// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool = false
param enableDiagnostic bool = false
param enablePrivateLink bool = false
param virtualNetworkName string = ''
param subnetName string = ''

// tags
param tags object = {}

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param loganalyticsWorkspace_name string = ''
param keyvault_name string = ''
param appInsights_name string = ''

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

// API Management settings
param ApiManagementSKUName string = ''
param ApiManagementCapacity int = 1
param ApiManagementPublisherName string = ''
param ApiManagementPublisherEmail string = ''

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var apimanagement_name = 'apim-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

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

// 312a565d-c81f-4fd8-895a-4e21e48d571c    BuiltInRole     API Management Service Contributor
// e022efe7-f5ba-4159-bbe4-b44f577e9b61    BuiltInRole     API Management Service Operator Role
// 71522526-b88f-4d52-b57f-d31fc3546d0d    BuiltInRole     API Management Service Reader Role
// c031e6a8-4391-4de0-8d69-4706a7ed3729    BuiltInRole     API Management Developer Portal Content Editor
// 9565a273-41b9-4368-97d2-aeb0c976a9b3    BuiltInRole     API Management Service Workspace API Developer
// d59a3e9c-6d52-4a5a-aeed-6bf3cf0e31da    BuiltInRole     API Management Service Workspace API Product Manager

var APIManagementServiceContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '312a565d-c81f-4fd8-895a-4e21e48d571c')
var APIManagementServiceOperatorRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e022efe7-f5ba-4159-bbe4-b44f577e9b61')
var APIManagementServiceReaderRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '71522526-b88f-4d52-b57f-d31fc3546d0d')
var APIManagementDeveloperPortalContentEditor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c031e6a8-4391-4de0-8d69-4706a7ed3729')
var APIManagementServiceWorkspaceAPIDeveloper = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '9565a273-41b9-4368-97d2-aeb0c976a9b3')
var APIManagementServiceWorkspaceAPIProductManager = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'd59a3e9c-6d52-4a5a-aeed-6bf3cf0e31da')


//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = if (enableDiagnostic) {
  name: appInsights_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// Azure API Management
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apimanagement_name
  location: AppLocation
  tags: tags
  sku: {
    name: ApiManagementSKUName
    capacity: ApiManagementCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: ApiManagementPublisherEmail
    publisherName: ApiManagementPublisherName
    virtualNetworkType: 'None'
    apiVersionConstraint: {}
  }
}

resource apiManagementAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: apimanagement
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

resource apiManagementLogging 'Microsoft.ApiManagement/service/loggers@2021-08-01'= if (enableDiagnostic) {
  name:'${appinsights.name}-logger'
  parent: apimanagement
  properties:{
    loggerType:'applicationInsights'
    description:'Logger resources for APIM'
    credentials:{
      instrumentationKey:appinsights.properties.InstrumentationKey 
    }
  }
}

resource apimAppInsights 'Microsoft.ApiManagement/service/diagnostics@2022-09-01-preview' = if (enableDiagnostic) {
  name: 'applicationinsights'
  parent: apimanagement
  properties:{
    loggerId: apiManagementLogging.id
    alwaysLog: 'allErrors'
  }
}

// resource apiManagementDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: apimanagement
//   name: 'DiagnosticSettings'
//   properties: {
//     workspaceId: loganalyticsWorkspace.id
//     // logs: [
//     //   {
//     //     categoryGroup: 'allLogs'
//     //     enabled: true
//     //   }
//     // ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
// }

//****************************************************************
// Give API Management Permission to Read Key Vault Secrets
//****************************************************************

// resource keyvaultRoleAssignmentAPIMAdmin 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   scope: keyvault
//   name: guid(keyvault.id, apimanagement.name, KeyVaultAdministrator)
//   properties: {
//     roleDefinitionId: KeyVaultAdministrator
//     principalId: apimanagement.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

resource keyvaultRoleAssignmentAPIMSecretUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, apimanagement.name, KeyVaultSecretsUser)
  properties: {
    roleDefinitionId: KeyVaultSecretsUser
    principalId: apimanagement.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

//****************************************************************
// Add API Management details to App Configuration
//****************************************************************

module moduleAppConfigKeyValueapimanagementname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'apimanagement_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_name'
    variables_value: apimanagement.name
  }
}

module moduleAppConfigKeyValueapimanagementeresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'apimanagement_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValueapimanagementprincipalid './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'apimanagement_principalid'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_principalid'
    variables_value: apimanagement.identity.principalId
  }
}

module moduleAppConfigKeyValueapimanagementIPAddress './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'apimanagement_publicIpAddress'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_publicIpAddress'
    variables_value: apimanagement.properties.publicIPAddresses[0]
  }
}

output apimanagement_name string = apimanagement.name
output apimanagement_id string = apimanagement.id
output apimanagement_location string = apimanagement.location
output apimanagement_principalId string = apimanagement.identity.principalId
output apimanagement_IPAddressd string = apimanagement.properties.publicIPAddresses[0]
output apimanagementLogging_name string = apiManagementLogging.name
