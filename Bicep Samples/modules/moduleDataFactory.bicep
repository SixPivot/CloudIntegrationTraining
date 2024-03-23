// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = 'ause'
param Instance int = 1
param enableAppConfig bool 
param enableDiagnostic bool 
param enablePrivateLink bool 
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''

// tags
param tags object = {}

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param loganalyticsWorkspace_name string = ''

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
// Add Service Bus Namespace details to App Configuration
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
