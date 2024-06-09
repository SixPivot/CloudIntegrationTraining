param environmentName string
param logicAppResourceGroup string
param logicAppName string
param logicAppSigSecretName string
param keyVaultName string
param apiName string
param apiManagementName string
param workflowName string
param operationName string
param operationMethod string
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'

resource apiManagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource logicApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicAppName
  scope: resourceGroup(logicAppResourceGroup)
}

var logicAppResourceId = resourceId(logicAppResourceGroup,'Microsoft.Web/sites/hostruntime/webhooks/api/workflows/triggers',logicAppName,'runtime','workflow','management',workflowName,'When_a_HTTP_request_is_received')
var logicAppCallBackObject = listCallbackURL(logicAppResourceId,'2021-03-01')

var apiVersion = logicAppCallBackObject.queries['api-version']
var sp = logicAppCallBackObject.queries.sp 
var sv = logicAppCallBackObject.queries.sv 
var sig = logicAppCallBackObject.queries.sig 

resource keyVaultSecretSig 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: logicAppSigSecretName
  parent: keyVault
  properties:{
    value: sig
  }
}

resource apimNamedValueSig 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  name: keyVaultSecretSig.name
  parent: apiManagement
  properties: {
    displayName: keyVaultSecretSig.name
    secret: true
    keyVault: {
      identityClientId: null
      secretIdentifier: '${keyVault.properties.vaultUri}secrets/${keyVaultSecretSig.name}'
    }
  }
}

var loweredOperationName = toLower(operationName)

resource API 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  name: apiName
  parent: apiManagement
}

module pathParametersModule './modulePathParameters.bicep' = {
  name: 'PathParams${operationName}'
  params: {
    logicAppCallBackObject: logicAppCallBackObject
  }
}

module moduleApimOperation 'moduleApiManagementOperation.bicep' = {
  name: operationName
  params: {
    apiManagementName: apiManagement.name
    apiName: apiName
    lgCallBackObject: logicAppCallBackObject
    operationDisplayname: operationName
    operationMethod: operationMethod
    operationName: operationName
    operationPath: operationName
  }
}

module moduleApiManagementOperationPolicy 'moduleApiManagementOperationPolicy.bicep' = {
  name: '${operationName}Policy'
  params: {
    apimanagement_name: apiManagement.name
    apiName: apiName
    operationName: loweredOperationName
    urlTemplate: moduleApimOperation.outputs.apim_operationUrl
    apiVersion: apiVersion
    sp: sp
    sv: sv
    sigNamedValue: apimNamedValueSig.name
  }
}

module moduleAppConfigKeyValueapimanagementoperationurl 'moduleAppConfigKeyValue.bicep' = {
  name: 'apimanagement_operationurl${operationName}'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: environmentName
    variables_key: '${API.name}:${operationName}URL'
    variables_value: '${apiManagement.properties.gatewayUrl}/${API.properties.path}${moduleApimOperation.outputs.operationURL}'
  }
}

module moduleAppConfigKeyValueapimanagementoperationapiversion 'moduleAppConfigKeyValue.bicep' = {
  name: 'apimanagement_operationapiversion${operationName}'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: environmentName
    variables_key: '${API.name}:${operationName}ApiVersion'
    variables_value: API.properties.apiVersion
  }
}

var AllOperationPolicy = loadTextContent('../Policies/AllOperations.xml')
var policyBackend = replace(AllOperationPolicy, '__backendurl__', 'https://${logicApp.properties.defaultHostName}/api')

resource apimAllOperationsPolicy 'Microsoft.ApiManagement/service/apis/policies@2023-03-01-preview' = {
  name: 'policy'
  parent: API
  properties: {
    value: policyBackend
    format: 'rawxml'
  }
}

