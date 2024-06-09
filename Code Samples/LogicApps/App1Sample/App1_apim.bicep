param EnvironmentName string = '$(EnvironmentName)'
param appName string = 'App1'
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param apimanagement_name string = '$(apimanagement_name)'
param apimanagement_resourcegroup string = '$(apimanagement_resourcegroup)'
param apiName string = 'app1'
param keyvault_name string = '$(keyvault_name)'
param keyvault_resourcegroup string = '$(keyvault_resourcegroup)'
param App1_logicappstd_name string = '$(App1_logicappstd_name)'
param App1_logicappstd_resourcegroup string = '$(App1_logicappstd_resourcegroup)'

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

//****************************************************************
// create resources
//****************************************************************
// var operations = [
//   ['GetCustomer', 'GET']
// ]

var operations = [
  {
    operation: 'GetCustomer'
    method: 'GET'
    workflowName: 'GetCustomer'
  }
  {
    operation: 'GetCustomers'
    method: 'GET'
    workflowName: 'GetCustomers'
  }
]

module moduleApiManagementOperation '../../../Bicep Samples/modules/moduleApiManagementOperationAndPolicy.bicep' = [for (ops, index) in operations: {
  name: '${apiName}${ops.operation}'
  params: {
    apiManagementName: apimanagement_name
    apiName: apiName
    keyVaultName: keyvault_name
    logicAppResourceGroup: App1_logicappstd_resourcegroup
    logicAppName: App1_logicappstd_name
    logicAppSigSecretName: '${toLower(apiName)}-${toLower(ops.operation)}-sig'
    operationMethod: ops.method
    operationName: ops.operation
    workflowName: ops.workflowName
    environmentName: EnvironmentName
    appconfig_name: appconfig_name
    appconfig_resourcegroup: appconfig_resourcegroup
    appconfig_subscriptionId: appconfig_subscriptionId
  }
}]

module moduleApiManagementSubscriptionKey '../../../Bicep Samples/modules/moduleApiManagementSubscriptionKey.bicep' = {
  name: '${appName}-${apiName}-subscriptionkey'
  params: {
    apimanagement_name: apimanagement_name
    apimanagement_resourcegroup: apimanagement_resourcegroup
    appName: appName
    apiName: apiName
  }
}

resource keyvaultSecretSubscriptionKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: '${appName}-${apiName}-subscriptionkey'
  parent: keyvault
  properties:{
    value: moduleApiManagementSubscriptionKey.outputs.subscriptionKeyPrimary
  }
}

module moduleAppConfigKeyValueapimanagementname '../../../Bicep Samples/modules/moduleAppConfigKeyValue.bicep' = {
  name: 'apimanagement_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: '${appName}:${apiName}-subscriptionkey'    
    variables_value: '{"uri":"${keyvaultSecretSubscriptionKey.properties.secretUri}"}'    
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}
