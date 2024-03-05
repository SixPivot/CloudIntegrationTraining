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

// Integration Account settings
param IntegrationAccountSKUName string = 'Basic'

// existing resources
param appconfig_name string = ''
param appconfig_resourcegroup string = ''
param appconfig_subscriptionId string = ''
param loganalyticsWorkspace_name string = ''

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var integrationAccount_name = 'ia-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

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
// Integration Accoun t
//****************************************************************

resource integrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' = {
  name: integrationAccount_name
  location: AppLocation
  tags: tags
  sku: {
    name: IntegrationAccountSKUName
  }
  properties: {}
}

resource integrationAccountDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostic) {
  scope: integrationAccount
  name: 'DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsWorkspace.id
    metrics: [
      {
        category: 'allLogs  '
        enabled: true
      }
    ]
  }
}

//****************************************************************
// Add Service Bus Namespace details to App Configuration
//****************************************************************

module moduleAppConfigKeyValueintegrationAccount './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'integrationaccount_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'integrationaccount_name'
    variables_value: integrationAccount.name
  }
}

module moduleAppConfigKeyValueintegrationAccountresourcegroup './moduleAppConfigKeyValue.bicep' = if (enableAppConfig) {
  name: 'integrationaccount_resourcegroup'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'integrationaccount_resourcegroup'
    variables_value: resourceGroup().name
  }
}

output integrationaccount_name string = integrationAccount.name
output integrationaccount_resourcegroup string = resourceGroup().name
