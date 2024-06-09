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
param enableDiagnostic bool = false
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
param logicapp_subnet_id string = '$(logicapp_subnet_id)'
param logicapp_subnet_name string = '$(logicapp_subnet_name)'
param functionapp_subnet_id string = '$(functionapp_subnet_id)'
param functionapp_subnet_name string = '$(functionapp_subnet_name)'
param servicebusnamespace_name string = '$(servicebusnamespace_name)'
param servicebusnamespace_resourcegroup string = '$(servicebusnamespace_resourcegroup)'
param apimanagement_name string = '$(apimanagement_name)'
param apimanagement_resourcegroup string = '$(apimanagement_resourcegroup)'
param storage_name string = '$(storage_name)'
param storage_resourcegroup string = '$(storage_resourcegroup)'

param privateDNSZoneResourceGroup string = '$(privateDNSZoneResourceGroup)'
param privateDNSZoneSubscriptionId string  = '$(privateDNSZoneSubscriptionId)'

// param VNETLinks array = [
//   {
//     linkId: 'DevOps'
//     virtualNetworkName: 'CloudIntegrationTraining'
//     virtualNetworkResourceGroup: 'CloudIntegrationTraining'
//     virtualNetworkSubscriptionId: '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'
//   }
//   // {
//   //   linkId: 'VMInside'
//   //   virtualNetworkName: virtualNetworkNameVMInside
//   //   virtualNetworkResourceGroup: virtualNetworkResourceGroupVMInside
//   //   virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdVMInside
//   // }
// ]

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 86e8f5dc-a6e9-4c67-9d15-de283e8eac25    BuiltInRole     Classic Storage Account Contributor
// 985d6b00-f706-48f5-a6fe-d0ca12fb668d    BuiltInRole     Classic Storage Account Key Operator Service Role
// 17d1049b-9a84-46fb-8f53-869881c3d3ab    BuiltInRole     Storage Account Contributor
// 81a9662b-bebf-436f-a333-f67b29880f12    BuiltInRole     Storage Account Key Operator Service Role
// ba92f5b4-2d11-453d-a403-e96b0029c9fe    BuiltInRole     Storage Blob Data Contributor
// b7e6dc6d-f1e8-4753-8033-0f276bb0955b    BuiltInRole     Storage Blob Data Owner
// 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1    BuiltInRole     Storage Blob Data Reader
// 974c5e8b-45b9-4653-ba55-5f855dd0fb88    BuiltInRole     Storage Queue Data Contributor
// 8a0f0c08-91a1-4084-bc3d-661d67233fed    BuiltInRole     Storage Queue Data Message Processor
// c6a89b2d-59bc-44d0-9896-0f6e12d7b80a    BuiltInRole     Storage Queue Data Message Sender
// 19e7f393-937e-4f77-808e-94535e297925    BuiltInRole     Storage Queue Data Reader
// aba4ae5f-2193-4029-9191-0cb91df5e314    BuiltInRole     Storage File Data SMB Share Reader
// 0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb    BuiltInRole     Storage File Data SMB Share Contributor
// db58b8e5-c6ad-4a2a-8342-4190687cbf4a    BuiltInRole     Storage Blob Delegator
// a7264617-510b-434b-a828-9731dc254ea7    BuiltInRole     Storage File Data SMB Share Elevated Contributor
// e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1    BuiltInRole     Storage Account Backup Contributor
// 76199698-9eea-4c19-bc75-cec21354c6b6    BuiltInRole     Storage Table Data Reader
// 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3    BuiltInRole     Storage Table Data Contributor
// b8eda974-7b85-4f76-af95-65846b26df6d    BuiltInRole     Storage File Data Privileged Reader
// 69566ab7-960f-475b-8e7c-b3118f30c6bd    BuiltInRole     Storage File Data Privileged Contributor
// a316ed6d-1efe-48ac-ac08-f7995a9c26fb    BuiltInRole     Storage Account Encryption Scope Contributor Role

var StorageBlobDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

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

module moduleStorageAccountForFunctionApp './modules/moduleStorageAccount.bicep' = {
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
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
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
    publicNetworkAccess: publicNetworkAccess
    functionapp_subnet_id: functionapp_subnet_id
    functionapp_subnet_name: functionapp_subnet_name
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
} 

module moduleStorageAccountForLogicAppStd './modules/moduleStorageAccount.bicep' = {
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
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
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
    publicNetworkAccess: publicNetworkAccess
    logicapp_subnet_id: logicapp_subnet_id
    logicapp_subnet_name: logicapp_subnet_name
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
  dependsOn: [
    moduleFunctionApp
  ]
} 

module moduleServiceBustopic './modules/moduleServiceBusTopic.bicep' = {
  name: 'moduleServiceBustopic'
  scope: resourceGroup(servicebusnamespace_resourcegroup)
  params: {
    servicebusnamespace_name: servicebusnamespace_name
    topic_name: 'App1'
    principalid: moduleLogicAppStandard.outputs.logicappstd_principalid
    principaltype: 'ServicePrincipal'
    CreateRoleAssignment: true
  }
}

module moduleApiManagementAPI './modules/moduleApiManagementAPI.bicep' = {
  name: 'moduleApiManagementAPI'
  scope: resourceGroup(apimanagement_resourcegroup)
  params: {
    apimanagement_name: apimanagement_name
    apiName: 'app1'
    apiPath: 'app1'
    versioningScheme: 'Query'
  }
}

module moduleStorageAccountContainer './modules/moduleStorageAccountContainer.bicep' = {
  name: 'financialsContainer'
  scope: resourceGroup(storage_resourcegroup)
  params: {
    container_name: 'app1'
    storage_name: storage_name
    storage_resourcegroup: storage_resourcegroup
  }
}

module moduleStorageAccountContainerRoleAssignment './modules/moduleStorageAccountContainerRoleAssignment.bicep' = {
  name: 'moduleStorageAccountContainerRoleAssignment'
  scope: resourceGroup(storage_resourcegroup)
  params:{ 
    storage_name: storage_name
    storage_resourcegroup: storage_resourcegroup
    container_name: moduleStorageAccountContainer.outputs.storagecontainer_name
    principalid: moduleLogicAppStandard.outputs.logicappstd_principalid
    principaltype: 'ServicePrincipal'
    roledefinitionid: StorageBlobDataOwner
  }
}

//****************************************************************
// Add Storage Account Container details to App Configuration
//****************************************************************

module moduleAppConfigKeyValuestoragename './modules/moduleAppConfigKeyValue.bicep' = {
  name: 'app1_storagecontainer_name'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'app1_storagecontainer_name'
    variables_value: moduleStorageAccountContainer.outputs.storagecontainer_name
  }
}
