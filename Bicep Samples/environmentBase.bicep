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
param WorkflowHostingPlanSKUName string = 'WS1'
param FunctionAppHostingPlanSKUName string = 'EP1'
param FunctionAppHostingPlanTierName string = 'Dynamic'

param SQLDatabaseSKUName string = 'Standard'
param SQLDatabaseCapacity int = toLower(EnvironmentName) == 'prod' ? 50 : 20
param SQLDatabaseTierName string = 'Standard'


// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param KeyVaultAdministratorsGroupId string = '$(KeyVaultAdministratorsGroupId)'
param KeyVaultReaderGroupId string = '$(KeyVaultReaderGroupId)'

// existing resources
param enableAppConfig bool = true
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param appconfig_vnetName string = '$(appconfig_vnetName)'
// param appconfig_DNSZone string = '$(appconfig_DNSZone)'
// param resourcemanagerPL_resourcegroup string = '$(resourcemanagerPL_resourcegroup)'
// param resourcemanagerPL_subscriptionId string = '$(resourcemanagerPL_subscriptionId)'
// param resourcemanagerPL_DNSZone string = '$(resourcemanagerPL_DNSZone)'
param virtualNetworkNameDevOps string = 'CloudIntegrationTraining'
param virtualNetworkResourceGroupDevOps string = 'CloudIntegrationTraining'
param virtualNetworkSubscriptionIdDevOps string = '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'
param virtualNetworkNameVMInside string = 'CloudIntegrationTraining'
param virtualNetworkResourceGroupVMInside string = 'CloudIntegrationTraining'
param virtualNetworkSubscriptionIdVMInside string = '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'
param enableDiagnostic bool = false
param enablePrivateLink bool = true
param enableVNETIntegration bool = true
param virtualNetworkName string = '$(virtualNetworkName)'
param virtualNetworkResourceGroup string = '$(virtualNetworkResourceGroup)'
param virtualNetworkSubscriptionId string = '$(virtualNetworkSubscriptionId)' 
param privatelinkSubnetName string = '$(privatelinkSubnetName)'
param networksecuritygroupName string = '$(networksecuritygroupName)'
param routetableName string = '$(routetableName)'
param publicNetworkAccess string = 'Disabled'
param ApiManagement_subnet1 string = '172.22.4.0/27'
param ApiManagement_subnet2 string = '172.22.4.32/27'
param logicappstd_subnet string = '172.22.4.64/27'
param functionapp_subnet string = '172.22.4.96/27'

param privateDNSZoneResourceGroup string = '$(privateDNSZoneResourceGroup)'
param privateDNSZoneSubscriptionId string  = '$(privateDNSZoneSubscriptionId)'

// param VNETLinks array = [
//   {
//     linkId: 'DevOps'
//     virtualNetworkName: virtualNetworkNameDevOps
//     virtualNetworkResourceGroup: virtualNetworkResourceGroupDevOps
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdDevOps
//   }
//   // {
//   //   linkId: 'VMInside'
//   //   virtualNetworkName: virtualNetworkNameVMInside
//   //   virtualNetworkResourceGroup: virtualNetworkResourceGroupVMInside
//   //   virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdVMInside
//   // }
// ]

//****************************************************************
// Variables
//****************************************************************

var StorageSKUName = toLower(EnvironmentName) == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
var padInstance = '0'
var InstanceString = Instance > 0 ? '-${padLeft(Instance,3,padInstance)}' : ''
var logicapp_subnet_name = 'logic-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}${InstanceString}'
var functionapp_subnet_name = 'func-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}${InstanceString}'

//****************************************************************
// Create DNS Zone Links for RM & App Config
//****************************************************************

// var SharedVNETLinks = [
//   {
//     link: 'RM'
//     linkResourceGroup: resourcemanagerPL_subscriptionId
//     linkSubscription: resourcemanagerPL_resourcegroup
//     DNSZone: resourcemanagerPL_DNSZone
//   }
//   {
//     link: 'AppConfig'
//     linkResourceGroup: resourcemanagerPL_subscriptionId
//     linkSubscription: resourcemanagerPL_resourcegroup
//     DNSZone: resourcemanagerPL_DNSZone
//   }
// ]

// module moduleDNSZoneVirtualNetworkLink './modules/moduleDNSZoneVirtualNetworkLink.bicep' = [for (link, index) in SharedVNETLinks: {
//   name: 'moduleDNSZoneVirtualNetworkLink-${link.link}'
//   scope: resourceGroup(link.linkResourceGroup, link.linkSubscription)
//   params: {
//     linkId: EnvironmentName
//     DNSZone_name: link.DNSZone
//     virtualNetworkName: virtualNetworkName
//     virtualNetworkResourceGroup: virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: subscription().subscriptionId
//   }
// }]

//****************************************************************
// Create Resources
//****************************************************************

module moduleLogAnalytics './modules/moduleLogAnalyticsWorkspace.bicep' = if (enableDiagnostic) {
  name: 'moduleLogAnalyticsWorkspace'
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
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    publicNetworkAccessForIngestion: publicNetworkAccess
    publicNetworkAccessForQuery: publicNetworkAccess
    // VNETLinks: VNETLinks
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
  // dependsOn:[
  //   moduleDNSZoneVirtualNetworkLink
  // ]
}

module moduleKeyVault './modules/moduleKeyVault.bicep' = {
  name: 'moduleKeyVault'
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
    AzureDevOpsServiceConnectionId: AzureDevOpsServiceConnectionId
    KeyVaultAdministratorsGroupId: KeyVaultAdministratorsGroupId
    KeyVaultReaderGroupId: KeyVaultReaderGroupId
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    appconfig_vnetName: appconfig_vnetName
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    publicNetworkAccess: publicNetworkAccess
    // VNETLinks: VNETLinks
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
    // virtualNetworkNameDevOps: virtualNetworkNameDevOps
    // virtualNetworkResourceGroupDevOps: virtualNetworkResourceGroupDevOps
    // virtualNetworkSubscriptionIdDevOps: virtualNetworkSubscriptionIdDevOps
    // virtualNetworkNameVMInside: virtualNetworkNameVMInside
    // virtualNetworkResourceGroupVMInside: virtualNetworkResourceGroupVMInside
    // virtualNetworkSubscriptionIdVMInside: virtualNetworkSubscriptionIdVMInside
  }
}

module moduleApplicationInsights './modules/moduleApplicationInsights.bicep' = if (enableDiagnostic) {
  name: 'moduleApplicationInsights'
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    keyvault_resourcegroup: moduleKeyVault.outputs.keyvault_resourcegroup
    enablePrivateLink: enablePrivateLink
    publicNetworkAccess: publicNetworkAccess
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    loganalyticsWorkspace_privatelinkscope_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_privatelinkscope_name
  }
}

module moduleApiManagementBase 'modules/moduleApiManagementBase.bicep' = {
  name: 'moduleApiManagementBase'
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    keyvault_resourcegroup: moduleKeyVault.outputs.keyvault_resourcegroup
    appInsights_name: enableDiagnostic ? moduleApplicationInsights.outputs.appinsights_name : ''
    enablePrivateLink: false
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    virtualNetworkSubscriptionId: enablePrivateLink ? virtualNetworkSubscriptionId  : ''
    AzureDevOpsServiceConnectionId: AzureDevOpsServiceConnectionId
    KeyVaultAdministratorsGroupId: KeyVaultAdministratorsGroupId
    KeyVaultReaderGroupId: KeyVaultReaderGroupId
    ApiManagementSKUName: 'developer'
    ApiManagementCapacity: 1
    ApiManagementPublisherName: 'Cloud Integration Training'
    ApiManagementPublisherEmail: 'bill.chesnut@sixpivot.com.au'
    ApiManagementVirtualNetowrkType: 'Internal'
    enableVNETIntegration: enableVNETIntegration
    ApiManagement_subnet1: ApiManagement_subnet1
    ApiManagement_subnet2: ApiManagement_subnet2
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
    publicNetworkAccess: publicNetworkAccess
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}

var policyString = loadTextContent('./policies/Correlation.xml')

module moduleApiManagementPolicy './modules/moduleApiManagementPolicy.bicep' = {
  name: 'moduleApiManagementPolicy'
  params: {
    apimanagement_name: moduleApiManagementBase.outputs.apimanagement_name
    policyString: policyString
  }
}

// module moduleServiceBusNamespace './modules/moduleServiceBusNamespace.bicep' = {
//   name: 'moduleServiceBusNamespace'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     ServiceBusSKUName: 'Premium'
//     ServiceBusCapacity: 1
//     ServiceBusTierName: 'Premium'
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     publicNetworkAccess: publicNetworkAccess
//   }
// }

module moduleStorageAccount './modules/moduleStorageAccount.bicep' = {
  name: 'moduleStorageAccount'
  params: {
    BaseName: BaseName
    BaseShortName: BaseShortName
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    AppName: ''
    AppShortName: ''
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    publicNetworkAccess: publicNetworkAccess
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}

module moduleFunctionAppHostingPlan './modules/moduleFunctionAppHostingPlan.bicep' = {
  name: 'moduleFunctionAppHostingPlan'
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    FunctionAppHostingPlanSKUName: FunctionAppHostingPlanSKUName
    FunctionAppHostingPlanTierName: FunctionAppHostingPlanTierName
  }
}

//****************************************************************
// Add VNET Integration for Function App
//****************************************************************

module moduleFunctionAppVNETIntegration './modules/moduleFunctionAppVNETIntegration.bicep' = if (enableVNETIntegration) {
  name: 'moduleFunctionAppVNETIntegration'
  params: {
    EnvironmentName: EnvironmentName
    enableAppConfig: enableAppConfig
    appconfig_name: appconfig_name
    appconfig_resourcegroup: appconfig_resourcegroup
    appconfig_subscriptionId: appconfig_subscriptionId
    functionapp_subnet_name: functionapp_subnet_name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    functionapp_subnet: functionapp_subnet
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName
  }
  dependsOn: [
    moduleFunctionAppHostingPlan
  ]
}

// module moduleStorageAccountForFunctionApp './modules/moduleStorageAccountForFunctionApp.bicep' = {
//   name: 'moduleStorageAccountForFunctionApp'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     StorageSKUName: StorageSKUName
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     AppName: 'functionapp'
//     AppShortName: 'fn'
//     publicNetworkAccess: publicNetworkAccess
//   }
//   dependsOn: [
//     moduleStorageAccount
//   ]
// }

// module moduleFunctionApp './modules/moduleFunctionApp.bicep' = {
//   name: 'moduleFunctionApp'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     AppName: ''
//     AppShortName: ''
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
//     applicationinsights_name: enableDiagnostic ? moduleApplicationInsights.outputs.appinsights_name : ''
//     applicationinsights_resourcegroup: enableDiagnostic ? moduleApplicationInsights.outputs.applicationinsights_resourcegroup : ''
//     keyvault_name: moduleKeyVault.outputs.keyvault_name
//     keyvault_resourcegroup: moduleKeyVault.outputs.keyvault_resourcegroup
//     storage_name: moduleStorageAccountForFunctionApp.outputs.storage_name
//     storage_resourcegroup: moduleStorageAccountForFunctionApp.outputs.storage_resourcegroup
//     storage_subscriptionId: moduleStorageAccountForFunctionApp.outputs.storage_subscriptionId
//     functionapphostingplan_name: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_name
//     functionapphostingplan_resourcegroup: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_resourcegroup
//     functionapphostingplan_subscriptionId: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_subscriptionId
//     //apimanagement_publicIPAddress: 
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     enableVNETIntegration: enableVNETIntegration
//     //vnetintegrationSubnetName: functionAppSubnetName
//     functionapp_subnet: '172.22.1.16/28'
//     //createSubnet: createFunctionAppSubnet
//     networksecuritygroupName: networksecuritygroupName
//     routetableName: routetableName
//     publicNetworkAccess: publicNetworkAccess
//   }
//   dependsOn:[
//     moduleApiManagementBase
//   ]
// } 

module moduleWorkflowHostingPlan './modules/moduleWorkflowHostingPlan.bicep' = {
  name: 'moduleWorkflowHostingPlan'
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
    WorkflowHostingPlanSKUName: WorkflowHostingPlanSKUName
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
  }
}

//****************************************************************
// Add VNET Integration for Logic App Std 
//****************************************************************

module moduleLogicAppStandardVNETIntegration './modules/moduleLogicAppStandardVNETIntegration.bicep' = if (enableVNETIntegration) {
  name: 'moduleLogicAppStandardVNETIntegration'
  params: {
    EnvironmentName: EnvironmentName
    enableAppConfig: enableAppConfig
    appconfig_name: appconfig_name
    appconfig_resourcegroup: appconfig_resourcegroup
    appconfig_subscriptionId: appconfig_subscriptionId
    logicappstd_subnet_name: logicapp_subnet_name
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    functionapp_subnet: logicappstd_subnet
    networksecuritygroupName: networksecuritygroupName
    routetableName: routetableName

  }
  dependsOn: [
    moduleWorkflowHostingPlan
  ]
}

// module moduleStorageAccountForLogicAppStd './modules/moduleStorageAccountForLogicAppStd.bicep' = {
//   name: 'moduleStorageAccountForLogicAppStd'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     StorageSKUName: StorageSKUName
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     AppName: 'logicappstd'
//     AppShortName: 'las'
//     publicNetworkAccess: publicNetworkAccess
//   }
//   dependsOn: [
//     moduleStorageAccount
//     moduleStorageAccountForFunctionApp
//   ]
// }

// module moduleLogicAppStandard './modules/moduleLogicAppStandard.bicep' = {
//   name: 'moduleLogicAppStandard'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     AppName: ''
//     AppShortName: ''
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
//     applicationinsights_name: enableDiagnostic ? moduleApplicationInsights.outputs.appinsights_name : ''
//     applicationinsights_resourcegroup: enableDiagnostic ? moduleApplicationInsights.outputs.applicationinsights_resourcegroup : ''
//     keyvault_name: moduleKeyVault.outputs.keyvault_name
//     keyvault_resourcegroup: moduleKeyVault.outputs.keyvault_resourcegroup
//     storage_name: moduleStorageAccountForLogicAppStd.outputs.storage_name
//     storage_resourcegroup: moduleStorageAccountForLogicAppStd.outputs.storage_resourcegroup
//     storage_subscriptionId: moduleStorageAccountForLogicAppStd.outputs.storage_subscriptionId
//     workflowhostingplan_name: moduleWorkflowHostingPlan.outputs.workflowhostingplan_name
//     workflowhostingplan_resourcegroup: moduleWorkflowHostingPlan.outputs.workflowhostingplan_resourcegroup
//     workflowhostingplan_subscriptionId: moduleWorkflowHostingPlan.outputs.workflow_hostingplan_subscriptionId
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     enableVNETIntegration: enableVNETIntegration
//     //vnetintegrationSubnetName: logicAppStdSubnetName
//     functionapp_subnet: '172.22.1.0/28'
//     //createSubnet: createLogicAppStdSubnet
//     networksecuritygroupName: networksecuritygroupName
//     routetableName: routetableName
//     publicNetworkAccess: publicNetworkAccess
//   }
//   dependsOn: [
//     moduleFunctionApp
//   ]
// } 

module moduleSQLServer './modules/moduleSQLServer.bicep' = {
  name: 'moduleSQLServer'
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
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    publicNetworkAccess: publicNetworkAccess
    privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
    privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
  }
}

// module moduleSQLDatabase './modules/moduleSQLDatabase.bicep' = {
//   name: 'moduleSQLDatabase'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     BusinessImpact: BusinessImpact
//     BusinessOwner: BusinessOwner
//     CostCentre: CostCentre
//     CostOwner: CostOwner
//     InformationClassification: InformationClassification
//     Owner: Owner
//     ServiceClass: ServiceClass
//     Workload: Workload
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     SQLDatabaseSKUName: SQLDatabaseSKUName
//     SQLDatabaseCapacity: int(SQLDatabaseCapacity)
//     SQLDatabaseTierName: SQLDatabaseTierName
//     sqlserver_name: moduleSQLServer.outputs.sqlserver_name
//   }
// }

module moduleDataFactory './modules/moduleDataFactory.bicep' = {
  name: 'moduleDataFactory'
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
    enablePrivateLink: enablePrivateLink
    publicNetworkAccess: publicNetworkAccess
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
  }
}

// not required with Logic App Standard except for AS2, EDIFACT & X12
// module moduleIntegrationAccount './modules/moduleIntegrationAccount.bicep' = {
//   name: 'moduleIntegrationAccount'
//   params: {
//     BaseName: BaseName
//     BaseShortName: BaseShortName
//     EnvironmentName: EnvironmentName
//     EnvironmentShortName: EnvironmentShortName
//     AppLocation: AppLocation
//     AzureRegion: AzureRegion
//     Instance: Instance
//     tags: {
//       BusinessOwner: BusinessOwner
//       CostCentre: CostCentre
//       Workload: Workload
//     }
//     IntegrationAccountSKUName: 'Basic'
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//     loganalyticsWorkspace_resourcegroup: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_resourcegroup : ''
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//   }
// }
