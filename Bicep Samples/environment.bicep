// environment parameters
param BaseName string = 'enterpriseapps'
param BaseShortName string = 'ea'
param EnvironmentName string = 'dev'
param EnvironmentShortName string = 'dev'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1
var WorkflowHostingPlanSKUName = 'WS1'
var FunctionAppHostingPlanSKUName = 'EP1'
var FunctionAppHostingPlanTierName = 'Dynamic'

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = ''
param KeyVaultAdministratorsGroupId string = ''
param KeyVaultReaderGroupId string = ''

// existing resources
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param virtualNetworkName string = ''
param privatelinkSubnetName string = ''
param logicAppStdSubnetName string = ''
param logicAppStdSubnetAddressPrefix string = '' 
param functionAppStdSubnetName string = ''
param functionAppStdSubnetAddressPrefix string = '' 

//****************************************************************
// Variables
//****************************************************************

// var ApiManagementSKUName =  toLower(EnvironmentName) == 'prod' ? 'Standardv2' : 'Developer'
// var ApiManagementCapacity = 1
// var ApiManagementPublisherName = 'wilsongroupau'
// var ApiManagementPublisherEmail = 'trevor.booth@wilsongroupau.com'

// var FunctionAppHostingPlanSKUName = toLower(EnvironmentName) == 'prod' ? 'EP1' : 'Y1'
// var FunctionAppHostingPlanTierName = 'Dynamic'

// var WorkflowHostingPlanSKUName = 'WS1'

var StorageSKUName = toLower(EnvironmentName) == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

// var SQLDatabaseSKUName = 'Standard'
// var SQLDatabaseCapacity = toLower(EnvironmentName) == 'prod' ? 50 : 20
// var SQLDatabaseTierName = 'Standard'

//****************************************************************
// Create Resources
//****************************************************************

// module moduleLogAnalytics './modules/moduleLogAnalyticsWorkspace.bicep' = {
//   name: 'moduleLogAnalyticsWorkspace'
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
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//   }
// }

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
    // appconfig_name: appconfig_name
    // appconfig_resourcegroup: appconfig_resourcegroup
    // appconfig_subscriptionId: appconfig_subscriptionId
    // loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
  }
}

// module moduleApplicationInsights './modules/moduleApplicationInsights.bicep' = {
//   name: 'moduleApplicationInsights'
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
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//     loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
//     keyvault_name: moduleKeyVault.outputs.keyvault_name
//   }
// }

// var policyString = loadTextContent('./base/APIMpolicies/Correlation.xml')

// module moduleApiManagementPolicy './modules/moduleApiManagementPolicy.bicep' = {
//   name: 'moduleApiManagementPolicy'
//   params: {
//     apimanagement_name: moduleApiManagmentBase.outputs.apimanagement_name
//     policyString: policyString
//   }
// }

// module moduleApiManagementWorkspacePolicy './modules/moduleApiManagementWorkspacePolicy.bicep' = {
//   name: 'moduleApiManagementWorkspacePolicy'
//   params: {
//     apimanagement_name: moduleApiManagmentBase.outputs.apimanagement_name
//     apimanagement_workspace_name: moduleApiManagmentWorkspace.outputs.apimanagement_workspace_name 
//     policyString: policyString
//   }
// }

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
//     BusinessImpact: BusinessImpact
//     BusinessOwner: BusinessOwner
//     CostCentre: CostCentre
//     CostOwner: CostOwner
//     InformationClassification: InformationClassification
//     Owner: Owner
//     ServiceClass: ServiceClass
//     Workload: Workload
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//     loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
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
    tags: {
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      Workload: Workload
    }
    //appconfig_name: appconfig_name
    //appconfig_resourcegroup: appconfig_resourcegroup
    //appconfig_subscriptionId: appconfig_subscriptionId
    //loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    StorageSKUName: StorageSKUName
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
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
    // appconfig_name: appconfig_name
    // appconfig_resourcegroup: appconfig_resourcegroup
    // appconfig_subscriptionId: appconfig_subscriptionId
    FunctionAppHostingPlanSKUName: FunctionAppHostingPlanSKUName
    FunctionAppHostingPlanTierName: FunctionAppHostingPlanTierName
    enableAppConfig: false
    enableDiagnostic: false
  }
}

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
    //appconfig_name: appconfig_name
    //appconfig_resourcegroup: appconfig_resourcegroup
    //appconfig_subscriptionId: appconfig_subscriptionId
    //loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    StorageSKUName: StorageSKUName
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
    AppName: 'functionapp'
    AppShortName: 'fn'
  }
  dependsOn: [
    moduleStorageAccount
  ]
}

module moduleFunctionApp './modules/moduleFunctionApp.bicep' = {
  name: 'moduleFunctionApp'
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
    // appconfig_name: appconfig_name
    // appconfig_resourcegroup: appconfig_resourcegroup
    // appconfig_subscriptionId: appconfig_subscriptionId
    //loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    //applicationinsights_name: moduleApplicationInsights.outputs.applicationinsights_name
    storage_name: moduleStorageAccountForFunctionApp.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForFunctionApp.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForFunctionApp.outputs.storage_subscriptionId
    functionapphostingplan_name: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_name
    functionapphostingplan_resourcegroup: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_resourcegroup
    functionapphostingplan_subscriptionId: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_subscriptionId
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    enableVNETIntegration: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
    vnetintegrationSubnetName: functionAppStdSubnetName
    vnetintegrationSubnetAddressPrefix: functionAppStdSubnetAddressPrefix
  }
} 
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
    // appconfig_name: appconfig_name
    // appconfig_resourcegroup: appconfig_resourcegroup
    // appconfig_subscriptionId: appconfig_subscriptionId
    WorkflowHostingPlanSKUName: WorkflowHostingPlanSKUName
    enableAppConfig: false
    enableDiagnostic: false
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
    //appconfig_name: appconfig_name
    //appconfig_resourcegroup: appconfig_resourcegroup
    //appconfig_subscriptionId: appconfig_subscriptionId
    //loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    StorageSKUName: StorageSKUName
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
    AppName: 'logicappstd'
    AppShortName: 'las'
  }
  dependsOn: [
    moduleStorageAccount
  ]
}

module moduleLogicAppStandard './modules/moduleLogicAppStandard.bicep' = {
  name: 'moduleLogicAppStandard'
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
    // appconfig_name: appconfig_name
    // appconfig_resourcegroup: appconfig_resourcegroup
    // appconfig_subscriptionId: appconfig_subscriptionId
    //loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    //applicationinsights_name: moduleApplicationInsights.outputs.applicationinsights_name
    storage_name: moduleStorageAccountForLogicAppStd.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForLogicAppStd.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForLogicAppStd.outputs.storage_subscriptionId
    workflowhostingplan_name: moduleWorkflowHostingPlan.outputs.workflowhostingplan_name
    workflowhostingplan_resourcegroup: moduleWorkflowHostingPlan.outputs.workflowhostingplan_resourcegroup
    workflowhostingplan_subscriptionId: moduleWorkflowHostingPlan.outputs.workflow_hostingplan_subscriptionId
    enableAppConfig: false
    enableDiagnostic: false
    enablePrivateLink: true
    enableVNETIntegration: true
    virtualNetworkName: virtualNetworkName
    privatelinkSubnetName: privatelinkSubnetName
    vnetintegrationSubnetName: logicAppStdSubnetName
    vnetintegrationSubnetAddressPrefix: logicAppStdSubnetAddressPrefix
    //vnetintegrationSubnetAddressPrefix: '172.20.1.0/24'
  }
} 


// module moduleSQLServer './modules/moduleSQLServer.bicep' = {
//   name: 'moduleSQLServer'
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
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//   }
// }

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
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//     SQLDatabaseSKUName: SQLDatabaseSKUName
//     SQLDatabaseCapacity: int(SQLDatabaseCapacity)
//     SQLDatabaseTierName: SQLDatabaseTierName
//     sqlserver_name: moduleSQLServer.outputs.sqlserver_name
//   }
// }

// module moduleDataFactory './modules/moduleDataFactory.bicep' = {
//   name: 'moduleDataFactory'
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
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//     loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
//   }
// }

// not required with Logic App Standard
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
//     BusinessImpact: BusinessImpact
//     BusinessOwner: BusinessOwner
//     CostCentre: CostCentre
//     CostOwner: CostOwner
//     InformationClassification: InformationClassification
//     Owner: Owner
//     ServiceClass: ServiceClass
//     Workload: Workload
//     appconfig_name: appconfig_name
//     appconfig_resourcegroup: appconfig_resourcegroup
//     appconfig_subscriptionId: appconfig_subscriptionId
//     loganalyticsWorkspace_name: moduleLogAnalytics.outputs.loganalyticsWorkspace_name
//   }
// }
