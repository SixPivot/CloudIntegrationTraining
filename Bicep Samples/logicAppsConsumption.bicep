param BaseName string = '$(base_name)'
param BaseShortName string = '$(baseshort_name)'
param EnvironmentName string = '$(environment_name)'
param EnvironmentShortName string = '$(environmentshort_name)'
param AppLocation string = '$(applocation)'
//tags
param LocationTag string = '$(environmentshort_name)'
param OwnerTag string = '$(environmentshort_name)'
param OrganisationTag string = '$(environmentshort_name)'
param EnvironmentTag string = '$(environmentshort_name)'
param ApplicationTag string = '$(environmentshort_name)'
// existing resource names
param appconfig_name string = '$(appconfig_name)'
param loganalyticsWorkspace_name string = '$(loganalyticsWorkspace_name)'
param apim_name string = '$(apim_name)'
param keyvault_name string = '$(keyvault_name)'
param integrationAccount_name string = '$(integrationAccount_name)'
param storage_name string = '$(storage_name)'

//****************************************************************
// Existing Resources
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appconfig_name
}

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storage_name
}

resource integrationAccount 'Microsoft.Logic/integrationAccounts@2019-05-01' existing = {
  name: integrationAccount_name
}

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apim_name
}

resource connectionLogAnalytics 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: 'loganalytics'
  location: AppLocation
  kind: 'V1'
  tags: {
    AppDomain: ApplicationTag
    Environment: EnvironmentTag
    Location: LocationTag
    Organisation: OrganisationTag
    Owner: OwnerTag
  }
  properties:{
    alternativeParameterValues: {}
    displayName: 'Log Analytics Data Collector'
    api:{
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis',AppLocation,'azureloganalyticsdatacollector')
    }
    customParameterValues: {}
    parameterValues: {
      username: loganalyticsWorkspace.properties.customerId
      password: loganalyticsWorkspace.listKeys().primarySharedKey
    }
    // nonSecretParameterValues:{
    //   workpaceId: subscriptionResourceId('Microsoft.OperationalInsights/workspaces',loganalyticsWorkspace.name)
    //   workspaceKey: loganalyticsWorkspace.listKeys().primarySharedKey
    // }
  }
}

var logicApp_definition = loadJsonContent('./LogicAppsConsumption/Demo1/definition.json')
var logicApp_parameters = loadJsonContent('./LogicAppsConsumption/Demo1/parameters.json')

module nestedTemplateLogicAppconsumptionDemo1 'nestedTemplateLogicAppConsumption.bicep' = {
  name: 'nestedTemplateLogicAppconsumptionDemo1'
  params: {
    variables_basename: BaseName 
    variables_BaseShortName: BaseShortName
    variables_environmentname: EnvironmentName 
    variables_applocation: AppLocation
    variables_applicationtag: ApplicationTag
    variables_environmenttag: EnvironmentTag
    variables_locationtag: LocationTag
    variables_organisationtag: OrganisationTag
    variables_ownertag: OwnerTag
    variables_appconfigname: appconfig.name
    variables_appconfigresourcegroup: resourceGroup().name
    variables_keyvaultname:keyvault.name
    variables_loganalyticsworkspacename: loganalyticsWorkspace.name
    variables_apimname: apim.name
    variables_integrationaccountname: integrationAccount.name
    variables_logicappconsumptionid: 'demo1'
    variables_logicappdefinition: logicApp_definition
    variables_logicappparameters: logicApp_parameters
    variables_storagename: storage.name
  }
}

var logicApp_definition2 = loadJsonContent('./LogicAppsConsumption/Demo2/definition.json')
var logicApp_parameters2 = loadJsonContent('./LogicAppsConsumption/Demo2/parameters.json')

module nestedTemplateLogicAppconsumptionDemo2 'nestedTemplateLogicAppConsumption.bicep' = {
  name: 'nestedTemplateLogicAppconsumptionDemo2'
  params: {
    variables_basename: BaseName 
    variables_BaseShortName: BaseShortName
    variables_environmentname: EnvironmentName 
    variables_applocation: AppLocation
    variables_applicationtag: ApplicationTag
    variables_environmenttag: EnvironmentTag
    variables_locationtag: LocationTag
    variables_organisationtag: OrganisationTag
    variables_ownertag: OwnerTag
    variables_appconfigname: appconfig.name
    variables_appconfigresourcegroup: resourceGroup().name
    variables_keyvaultname:keyvault.name
    variables_loganalyticsworkspacename: loganalyticsWorkspace.name
    variables_apimname: apim.name
    variables_integrationaccountname: integrationAccount.name
    variables_logicappconsumptionid: 'demo2'
    variables_logicappdefinition: logicApp_definition2
    variables_logicappparameters: logicApp_parameters2
    variables_storagename: storage.name
  }
}
