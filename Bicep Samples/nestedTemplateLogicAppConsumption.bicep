param variables_basename string
param variables_BaseShortName string
param variables_environmentname string
param variables_applocation string
param variables_applicationtag string
param variables_environmenttag string
param variables_locationtag string
param variables_organisationtag string
param variables_ownertag string
param variables_appconfigname string
param variables_appconfigresourcegroup string
param variables_apimname string
param variables_integrationaccountname string
param variables_keyvaultname string
param variables_loganalyticsworkspacename string
param variables_storagename string
param variables_logicappconsumptionid string
param variables_logicappdefinition object
param variables_logicappparameters object

var logicAppConsumptionName = 'logic-con-${toLower(variables_logicappconsumptionid)}-${toLower(variables_basename)}-${toLower(variables_environmentname)}'

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv
var keyvaultadministrator = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
var keyvaultsecretuser = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
var appconfigdataowner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b')
var appconfigdatareader = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')

var storageblobdatacontributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')


resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: variables_appconfigname
}

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: variables_apimname
}

resource integrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' existing = {
  name: variables_integrationaccountname
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: variables_keyvaultname
}

resource loganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: variables_loganalyticsworkspacename
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: variables_storagename
}

//****************************************************************
// Azure Logic App Consumption
//****************************************************************

resource logicAppConsumption 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppConsumptionName
  location: variables_applocation
  tags: {
    AppDomain: variables_applicationtag
    Environment: variables_environmenttag
    Location: variables_locationtag
    Organisation: variables_organisationtag
    Owner: variables_ownertag
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // accessControl: {
    //   triggers: {
    //     openAuthenticationPolicies: {
    //       policies: {
    //         'APIM-only':{
    //           type: 'AAD'
    //           claims:[
    //             {
    //               name: 'iss'
    //               value: 'https://sts.windows.net/${subscription().tenantId}/'
    //             }
    //             {
    //               name: 'oid'
    //               value: apim.identity.principalId
    //             }
    //           ]
    //         }
    //       }
    //    }
    //   }
    // }
    definition: variables_logicappdefinition
    integrationAccount: {
      id: integrationAccount.id
    }
    parameters: variables_logicappparameters
    state: 'Enabled'
  }
}

resource logicAppConsumptionTrigger 'Microsoft.Logic/workflows/triggers@2019-05-01'  existing = {
  name: 'manual'
  parent: logicAppConsumption
}

resource logicappconsumptionDiagnosticSettings  'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: logicAppConsumption
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_DiagnosticSettings'
  properties: {
    workspaceId: loganalyticsworkspace.id
    logs: [
      {
        category: 'WorkflowRuntime'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource appconfigRoleAssignmentLogicApp 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, logicAppConsumption.name, appconfigdatareader)
  properties: {
    roleDefinitionId: appconfigdatareader
    principalId: logicAppConsumption.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logicappconsumptionRoleAssignmentKeyvault 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, logicAppConsumption.name, keyvaultsecretuser)
  properties: {
    roleDefinitionId: keyvaultsecretuser
    principalId: logicAppConsumption.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logicappconsumptionRoleAssignmentStorage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.id, logicAppConsumption.name, storageblobdatacontributor)
  properties: {
    roleDefinitionId: storageblobdatacontributor
    principalId: logicAppConsumption.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module logicappconsumptionNameNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_NameNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_name'
    variables_value: logicAppConsumption.name
  }
}

module logicappconsumptionBasePathNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_BasePathNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_basepath'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().basePath
  }
}

module logicappconsumptionMethodNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_MethodNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_method'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().method
  }
}

module logicappconsumptionQueriesAPIVersionNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_QueriesNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_queries_apiversion'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().queries['api-version']
  }
}

module logicappconsumptionQueriesSIGNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_Queries_SIGNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_queries_sig'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().queries.sig
  }
}

module logicappconsumptionQueriesSPNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_Queries_SPNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_queries_sp'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().queries.sp
  }
}

module logicappconsumptionQueriesSVNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_Queries_SVNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_queries_sv'
    variables_value: logicAppConsumptionTrigger.listCallbackUrl().queries.sv
  }
}

module logicappconsumptionURLTeamplateNestedTemplateAppConfig './nestedTemplateAppConfigKeyValue.bicep' = {
  name: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_URLTeamplateNestedTemplateAppConfig'
  scope: resourceGroup(variables_appconfigresourcegroup)
  params: {
    variables_appconfig_name: appconfig.name
    variables_environment: variables_environmentname
    variables_key: 'logicappconsumption_${toLower(variables_logicappconsumptionid)}_urltemplate'
    variables_value: '/manual/paths/invoke/?api-version=2019-05-01&amp;sp=${logicAppConsumptionTrigger.listCallbackUrl().queries.sp}&amp;sv=${logicAppConsumptionTrigger.listCallbackUrl().queries.sv}'
  }
}
