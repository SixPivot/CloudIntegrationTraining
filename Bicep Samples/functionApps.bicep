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
param keyvault_name string = '$(keyvault_name)'
param appInsights_name string = '$(appInsights_name)'
param functionhostingplan_name string = '$(functionhostingplan_name)'


//****************************************************************
// Existing Resources
//****************************************************************

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appconfig_name
}

resource loganalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: loganalyticsWorkspace_name
}

resource appinsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsights_name
}

resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyvault_name
}

resource functionHostingPlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: functionhostingplan_name
}

//****************************************************************
// Azure Function App module
//****************************************************************

module nestedTemplateFunctionAppInProcess 'nestedTemplateFunctionApp.bicep' = {
  name: 'nestedTemplateFunctionAppInProcess'
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
    variables_keyvaultname:keyvault.name
    variables_hostingplanname: functionHostingPlan.name
    variables_loganalyticsworkspacename: loganalyticsWorkspace.name
    variables_appinsightname: appinsights.name
    variables_functionappid: 'inprocess'
    variables_functionworkerruntime: 'dotnet'
  }
}

module nestedTemplateFunctionAppIsolated 'nestedTemplateFunctionApp.bicep' = {
  name: 'nestedTemplateFunctionAppIsolated'
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
    variables_keyvaultname:keyvault.name
    variables_hostingplanname: functionHostingPlan.name
    variables_loganalyticsworkspacename: loganalyticsWorkspace.name
    variables_appinsightname: appinsights.name
    variables_functionappid: 'isolated'
    variables_functionworkerruntime: 'dotnet-isolated'
  }
}

