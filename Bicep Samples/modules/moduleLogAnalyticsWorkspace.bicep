// environment parameters
param BaseName string = ''
param BaseShortName string = ''
param EnvironmentName string = ''
param EnvironmentShortName string = ''
param AppLocation string = ''
param AzureRegion string = ''
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

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var loganalyticsWorkspace_name = 'log-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 73c42c96-874c-492b-b04d-ab87d138a893    BuiltInRole     Log Analytics Reader
// 92aaf0da-9dab-42b6-94a3-d43ce8d16293    BuiltInRole     Log Analytics Contributor

var LogAnalyticsReader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '73c42c96-874c-492b-b04d-ab87d138a893')
var LogAnalyticsContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')

//****************************************************************
// Azure Log Anaytics Workspace
//****************************************************************

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: loganalyticsWorkspace_name
  location: AppLocation
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

module moduleAppConfigKeyValueloganalyticsWorkspacename './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'loganalyticsworkspace_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace_name'
    variables_value: loganalyticsWorkspace.name
  }
}

module moduleAppConfigKeyValueloganalyticsWorkspaceresourcegroup './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'loganalyticsworkspace_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'loganalyticsworkspace_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output loganalyticsWorkspace_name string = loganalyticsWorkspace.name
output loganalyticsWorkspace_id string = loganalyticsWorkspace.id
output loganalyticsWorkspace_location string = loganalyticsWorkspace.location
output loganalyticsWorkspace_customerId string = loganalyticsWorkspace.properties.customerId
output loganalyticsWorkspace_resourcegroup string = resourceGroup().name
