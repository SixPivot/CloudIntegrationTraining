// environment parameters
param BaseName string 
param BaseShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string = 'ause'
param Instance int = 1

// tags
param tags object = {}

param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool 
param publicNetworkAccess string
param virtualNetworkName string 
param virtualNetworkResourceGroup string
param virtualNetworkSubscriptionId string 
param privatelinkSubnetName string
param privateDNSZoneResourceGroup string 
param privateDNSZoneSubscriptionId string  

// existing resources
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string 
param loganalyticsWorkspace_name string 
param loganalyticsWorkspace_resourcegroup string 

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var dataFactory_name = 'adf-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

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
// Data Factory
//****************************************************************

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactory_name
  location: AppLocation
tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
  }
}

resource datafactoryDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableDiagnostic) {
  scope: dataFactory
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
// Add Private Link for Data Factory 
//****************************************************************

module moduleDataFactoryPrivateLinkDataFactory './moduleDataFactoryPrivateLink.bicep' = if (enablePrivateLink) {
  name: 'moduleDataFactoryPrivateLinkDataFactory'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    privatelinkSubnetName: privatelinkSubnetName
    datafactory_name: dataFactory.name
    type: 'dataFactory'
    zone: 'privatelink.datafactory.azure.net'
    EnvironmentName: EnvironmentName
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}

module moduleDataFactoryPrivateLinkPortal './moduleDataFactoryPrivateLinkLocal.bicep' = if (enablePrivateLink) {
  name: 'moduleDataFactoryPrivateLinkPortal'
  params: {
    AppLocation: AppLocation
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionId
    privatelinkSubnetName: privatelinkSubnetName
    datafactory_name: dataFactory.name
    type: 'portal'
    zone: 'privatelink.adf.azure.com'
  }
}

//****************************************************************
// Add Data Factory details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuedatafactoryname './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'datafactory_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'datafactory_name'
    variables_value: dataFactory.name
  }
}

module moduleAppConfigKeyValuedatafactoryresourcegroup './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'datafactory_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'datafactory_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output datafactory_name string = dataFactory.name
output datafactory_resourcegroup string = resourceGroup().name
