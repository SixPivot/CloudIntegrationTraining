// environment parameters
param BaseName string 
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool 
param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param privatelinkSubnetName string
param publicNetworkAccess string 

// tags
param tags object = {}

// Service Bus Namespace settings
param ServiceBusSKUName string 
param ServiceBusCapacity int 
param ServiceBusTierName string 

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var servicBusNamespace_name = 'sbns-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
}

//****************************************************************
// Service Bus Namespace
//****************************************************************

resource servicebusnamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: servicBusNamespace_name
  location: AppLocation
  tags: tags
  sku: {
    name: ServiceBusSKUName
    capacity: ServiceBusCapacity
    tier: ServiceBusTierName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: '1.2'
    disableLocalAuth: toLower(EnvironmentName) == 'dev' ? false : true
    publicNetworkAccess: publicNetworkAccess
  }  
}

resource servicebusnamespaceAuditSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: servicebusnamespace
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

resource servicebusnamespaceDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: servicebusnamespace
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

//****************************************************************
// Add Private Link for Service Bus
//****************************************************************

module moduleServiceBusNamespacePrivateLink './moduleServiceBusNamespacePrivateLink.bicep' = if (enablePrivateLink) {
  name: 'moduleServiceBusNamespacePrivateLink'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    servicBusNamespace_name: servicebusnamespace.name
  }
}

//****************************************************************
// Add Service Bus Namespace details to App Configuration
//****************************************************************

module moduleAppConfigKeyValueservicebusnamespacename './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'servicebusnamespace_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'servicebusnamespace_name'
    variables_value: servicebusnamespace.name
  }
}

module moduleAppConfigKeyValueservicebusnamespaceresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'servicebusnamespace_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'servicebusnamespace_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValueservicebusnamespacefullname './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'servicebusnamespace_fullname'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'servicebusnamespace_fullname'
    variables_value: '${servicebusnamespace.name}.servicebus.windows.net'
  }
}

module moduleAppConfigKeyValueservicebusnamespaceendpoint './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'servicebusnamespace_endpoint'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'servicebusnamespace_endpoint'
    variables_value: servicebusnamespace.properties.serviceBusEndpoint
  }
}

output servicebusnamespace_name string = servicebusnamespace.name
output servicebusnamespace_resourcegroup string = resourceGroup().name
output servicebusnamespace_endpoint string = servicebusnamespace.properties.serviceBusEndpoint
