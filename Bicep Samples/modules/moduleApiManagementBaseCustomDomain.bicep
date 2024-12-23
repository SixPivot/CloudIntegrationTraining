// environment parameters
param BaseName string
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string
param AppLocation string 
param AzureRegion string 
param Instance int 

// tags
param tags object = {}

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 
param keyvault_name string 
param appInsights_name string 
param enableVNETIntegration bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param virtualNetworkSubscriptionId string 
param networksecuritygroupName string 
param routetableName string 
param publicNetworkAccess string

param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string 

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

// API Management settings
param ApiManagementSKUName string 
param ApiManagementCapacity int 
param ApiManagementPublisherName string 
param ApiManagementPublisherEmail string 
param ApiManagement_subnet1 string
param ApiManagement_subnet2 string
param apimanagement_customdomain string 
//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var apimanagement_name = 'apim-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'
var apimanagementIP_name = 'pip-apim-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'
// for creating 2nd subnet
var InstanceString2 = padLeft(Instance+1,3,'0')
var apimanagement_name2 = 'apim-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString2}'

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

var virtualNetworkConfiguration = enableVNETIntegration ? { subnetResourceId: moduleApiManagementVNETIntegration.outputs.apim_subnet_id } : null

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsights_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// Add VNET Integration for API Management
//****************************************************************

module moduleApiManagementVNETIntegration './moduleApiManagementVNETIntegration.bicep' = if (enableVNETIntegration) {
  name: 'moduleApiManagementVNETIntegration'
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    vnetintegrationSubnetName: apimanagement_name
    ApiManagement_subnet: ApiManagement_subnet1
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
  }
}

resource apimanagementPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: apimanagementIP_name
  location: AppLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: toLower('${apimanagementIP_name}-${uniqueString(resourceGroup().id)}')
    }
  }
}

// second deployment to add custom domain

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
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
    virtualNetworkType: enableVNETIntegration ? 'Internal' : 'None'
    virtualNetworkConfiguration: virtualNetworkConfiguration
    publicIpAddressId: apimanagementPublicIp.id
    publicNetworkAccess: publicNetworkAccess
    apiVersionConstraint: {}
    hostnameConfigurations:[
      {
        type: 'Proxy'
        hostName: '${apimanagement_name}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: false
        certificateSource: 'BuiltIn'
      }
      { 
        type: 'Proxy'
        hostName: 'api.${toLower(EnvironmentName)}.${apimanagement_customdomain}'
        keyVaultId: '${keyvault.properties.vaultUri}secrets/${toLower(EnvironmentName)}${replace(apimanagement_customdomain,'.','')}'
        negotiateClientCertificate: false
        certificateSource: 'KeyVault'
        defaultSslBinding: true
      }
    ]
  }
}

module moduleAppConfigKeyValueapimanagementcustomdomainname './moduleAppConfigKeyValue.bicep' = {
  name: 'apimanagement_customdomain_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_customdomain_name'
    variables_value: apimanagement.properties.hostnameConfigurations[1].hostName
  }
}

module moduleAppConfigKeyValueapimanagementcustomdomainthumbprint'./moduleAppConfigKeyValue.bicep' = {
  name: 'apimanagement_customdomain_thumbprint'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'apimanagement_customdomain_thumbprint'
    variables_value: apimanagement.properties.hostnameConfigurations[1].certificate.thumbprint
  }
}

module moduleApiManagementPrivateDNSZones './moduleApiManagementPrivateDNSZones.bicep' = if (enableVNETIntegration) {
  name: 'moduleApiManagementPrivateDNSZones'
  scope: resourceGroup(privateDNSZoneSubscriptionId,privateDNSZoneResourceGroup)
  params: {
    apimanagement_name: apimanagement.name
    apimanagement_privateIpAddress: apimanagement.properties.privateIPAddresses[0]
    apimanagement_customdomain: apimanagement_customdomain
    EnvironmentName: EnvironmentName
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}
