// environment parameters
param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'cit'
param EnvironmentName string = 'dev'
param EnvironmentShortName string = 'dev'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// existing resources
param enableAppConfig bool = true
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param enableDiagnostic bool = true
param enablePrivateLink bool = true
param enableVNETIntegration bool = true
param virtualNetworkName string = '$(virtualNetworkName)'
param virtualNetworkResourceGroup string = '$(virtualNetworkResourceGroup)'
param privatelinkSubnetName string = '$(privatelinkSubnetName)'
param networksecuritygroupName string = '$(networksecuritygroupName)'
param routetableName string = '$(routetableName)'
param publicNetworkAccess string = 'Disabled'
param keyvault_name string = '$(keyvault_name)'
param keyvault_resourcegroup string = '$(keyvault_resourcegroup)'
param loganalyticsWorkspace_name string = '$(loganalyticsWorkspace_name)'
param loganalyticsWorkspace_resourcegroup string = '$(loganalyticsWorkspace_resourcegroup)'
param applicationinsights_name string = '$(applicationinsights_name)'
param applicationinsights_resourcegroup string = '$(applicationinsights_resourcegroup)'
param functionapphostingplan_name string = '$(functionapphostingplan_name)'
param functionapphostingplan_resourcegroup string = '$(functionapphostingplan_resourcegroup)'
param functionapphostingplan_subscriptionId string = '$(functionapphostingplan_subscriptionId)'
param workflowhostingplan_name string = '$(workflowhostingplan_name)'
param workflowhostingplan_resourcegroup string = '$(workflowhostingplan_resourcegroup)'
param workflowhostingplan_subscriptionId string = '$(workflowhostingplan_subscriptionId)'

param VNETLinks array = [
  {
    linkId: 'DevOps'
    virtualNetworkName: 'CloudIntegrationTraining'
    virtualNetworkResourceGroup: 'CloudIntegrationTraining'
    virtualNetworkSubscriptionId: '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'
  }
  // {
  //   linkId: 'VMInside'
  //   virtualNetworkName: virtualNetworkNameVMInside
  //   virtualNetworkResourceGroup: virtualNetworkResourceGroupVMInside
  //   virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdVMInside
  // }
]

//****************************************************************
// Variables
//****************************************************************

// var ApiManagementSKUName =  toLower(EnvironmentName) == 'prod' ? 'Standardv2' : 'Developer'
// var ApiManagementCapacity = 1
// var ApiManagementPublisherName = 'wilsongroupau'
// var ApiManagementPublisherEmail = 'trevor.booth@wilsongroupau.com'

var StorageSKUName = toLower(EnvironmentName) == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

//****************************************************************
// Add Private Link for App Config 
//****************************************************************
// resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
//   name: appconfig_name
//   scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
// }

// module moduleAppConfigurationPrivateLink './modules/moduleAppConfigurationPrivateLink.bicep' = if (enablePrivateLink) {
//   name: 'moduleAppConfigurationPrivateLink'
//   params: {
//     AppLocation: AppLocation
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     privatelinkSubnetName: privatelinkSubnetName
//     appconfig: appconfig
//   }
// }

//****************************************************************
// Create Resources
//****************************************************************

module moduleStorageAccountForFunctionApp './modules/moduleStorageAccountForFunctionApp.bicep' = {
  name: 'moduleStorageAccountForFunctionApp'
  params: {
    BaseName: BaseName
    BaseShortName: BaseShortName
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    tags: {
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      Workload: Workload
    }
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? loganalyticsWorkspace_resourcegroup : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    AppName: 'fnapp1'
    AppShortName: 'fnapp1'
    publicNetworkAccess: publicNetworkAccess
  }
}

module moduleFunctionApp './modules/moduleFunctionApp.bicep' = {
  name: 'moduleFunctionApp'
  params: {
    BaseName: BaseName
    BaseShortName: BaseShortName
    AppName: 'App1'
    AppShortName: 'App1'
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    tags: {
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      Workload: Workload
    }
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? loganalyticsWorkspace_resourcegroup : ''
    applicationinsights_name: enableDiagnostic ? applicationinsights_name : ''
    applicationinsights_resourcegroup: enableDiagnostic ? applicationinsights_resourcegroup : ''
    keyvault_name: keyvault_name
    keyvault_resourcegroup: keyvault_resourcegroup
    storage_name: moduleStorageAccountForFunctionApp.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForFunctionApp.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForFunctionApp.outputs.storage_subscriptionId
    functionapphostingplan_name: functionapphostingplan_name
    functionapphostingplan_resourcegroup: functionapphostingplan_resourcegroup
    functionapphostingplan_subscriptionId: functionapphostingplan_subscriptionId
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    enableVNETIntegration: enableVNETIntegration
    functionapp_subnet: '172.22.1.16/28'
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
    publicNetworkAccess: publicNetworkAccess
  }
} 

module moduleStorageAccountForLogicAppStd './modules/moduleStorageAccountForLogicAppStd.bicep' = {
  name: 'moduleStorageAccountForLogicAppStd'
  params: {
    BaseName: BaseName
    BaseShortName: BaseShortName
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    tags: {
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      Workload: Workload
    }
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? loganalyticsWorkspace_resourcegroup : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    AppName: 'laapp1'
    AppShortName: 'laapp1'
    publicNetworkAccess: publicNetworkAccess
  }
  dependsOn: [
    moduleStorageAccountForFunctionApp
  ]
}

module moduleLogicAppStandard './modules/moduleLogicAppStandard.bicep' = {
  name: 'moduleLogicAppStandard'
  params: {
    BaseName: BaseName
    BaseShortName: BaseShortName
    AppName: 'App1'
    AppShortName: 'App1'
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    tags: {
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      Workload: Workload
    }
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? loganalyticsWorkspace_resourcegroup : ''
    applicationinsights_name: enableDiagnostic ? applicationinsights_name : ''
    applicationinsights_resourcegroup: enableDiagnostic ? applicationinsights_resourcegroup : ''
    keyvault_name: keyvault_name
    keyvault_resourcegroup: keyvault_resourcegroup
    storage_name: moduleStorageAccountForLogicAppStd.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForLogicAppStd.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForLogicAppStd.outputs.storage_subscriptionId
    workflowhostingplan_name: workflowhostingplan_name
    workflowhostingplan_resourcegroup: workflowhostingplan_resourcegroup
    workflowhostingplan_subscriptionId: workflowhostingplan_subscriptionId
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    enableVNETIntegration: enableVNETIntegration
    functionapp_subnet: '172.22.1.0/28'
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
    publicNetworkAccess: publicNetworkAccess
  }
  dependsOn: [
    moduleFunctionApp
  ]
} 
