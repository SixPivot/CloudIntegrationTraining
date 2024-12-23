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

// tags
param tags object = {}

// Function App Hosting Plan settings
param FunctionAppHostingPlanSKUName string 
param FunctionAppHostingPlanTierName string 

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
var functionAppHostingPlan_name = 'aspfn-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = if (enableDiagnostic) {
  name: loganalyticsWorkspace_name
  scope: resourceGroup(loganalyticsWorkspace_resourcegroup)
}

//****************************************************************
// Azure Function App Hosting Plan
//****************************************************************

resource functionAppHostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: functionAppHostingPlan_name
  location: AppLocation
  tags: tags
  sku: {
    name: FunctionAppHostingPlanSKUName
    tier: FunctionAppHostingPlanTierName
  }
  properties: {}
}

resource AppServicePlanDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: functionAppHostingPlan
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
// Add Azure Function App Hosting details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuefunctionHostingPlanName './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'functionapphostingplan_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'functionapphostingplan_name'
    variables_value: functionAppHostingPlan.name
  }
}

module moduleAppConfigKeyValuefunctionHostingPlanResourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'functionapphostingplan_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'functionapphostingplan_resourcegroup'
    variables_value: resourceGroup().name
  }
}

module moduleAppConfigKeyValuefunctionHostingPlanSubscriptionId './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'functionapphostingplan_subscriptionid'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'functionapphostingplan_subscriptionId'
    variables_value: subscription().subscriptionId
  }
}


output functionapphostingplan_name string = functionAppHostingPlan.name
output functionapphostingplan_resourcegroup string = resourceGroup().name
output functionapphostingplan_subscriptionId string = subscription().subscriptionId
