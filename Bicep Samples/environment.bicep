// environment parameters
param BaseName string = 'integration'
param BaseShortName string = 'int'
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
param AzureDevOpsServiceConnectionId string = ''
param KeyVaultAdministratorsGroupId string = ''
param KeyVaultReaderGroupId string = ''

// existing resources
param enableAppConfig bool = false
param appconfig_name string = '$(appconfig_name)'
param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param enableDiagnostic bool = false
param enablePrivateLink bool = true
param enableVNETIntegration bool = true
param virtualNetworkName string = ''
param virtualNetworkResourceGroup string = ''
param privatelinkSubnetName string = ''
param createLogicAppStdSubnet bool
param logicAppStdSubnetName string = ''
param logicAppStdSubnetAddressPrefix string = '' 
param createFunctionAppSubnet bool
param functionAppSubnetName string = ''
param functionAppSubnetAddressPrefix string = '' 

//****************************************************************
// Variables
//****************************************************************

// var ApiManagementSKUName =  toLower(EnvironmentName) == 'prod' ? 'Standardv2' : 'Developer'
// var ApiManagementCapacity = 1
// var ApiManagementPublisherName = 'wilsongroupau'
// var ApiManagementPublisherEmail = 'trevor.booth@wilsongroupau.com'

var StorageSKUName = toLower(EnvironmentName) == 'prod' ? 'Standard_GRS' : 'Standard_LRS'

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
    enableDiagnostic: enableDiagnostic
  }
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
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    enablePrivateLink: enablePrivateLink
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
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
    keyvault_name: moduleKeyVault.outputs.keyvault_name
  }
}

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
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
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
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
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
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    //loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    FunctionAppHostingPlanSKUName: FunctionAppHostingPlanSKUName
    FunctionAppHostingPlanTierName: FunctionAppHostingPlanTierName
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
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
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
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    applicationinsights_name: enableDiagnostic ? moduleApplicationInsights.outputs.appinsights_name : ''
    applicationinsights_resourcegroup: enableDiagnostic ? moduleApplicationInsights.outputs.applicationinsights_resourcegroup : ''
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    storage_name: moduleStorageAccountForFunctionApp.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForFunctionApp.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForFunctionApp.outputs.storage_subscriptionId
    functionapphostingplan_name: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_name
    functionapphostingplan_resourcegroup: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_resourcegroup
    functionapphostingplan_subscriptionId: moduleFunctionAppHostingPlan.outputs.functionapphostingplan_subscriptionId
    //apimanagement_publicIPAddress: 
    enablePrivateLink: enablePrivateLink
    enableVNETIntegration: enableVNETIntegration
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    vnetintegrationSubnetName: functionAppSubnetName
    vnetintegrationSubnetAddressPrefix: functionAppSubnetAddressPrefix
    createSubnet: createFunctionAppSubnet
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
    WorkflowHostingPlanSKUName: WorkflowHostingPlanSKUName
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    //loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
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
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    StorageSKUName: StorageSKUName
    enablePrivateLink: enablePrivateLink
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    AppName: 'logicappstd'
    AppShortName: 'las'
  }
  dependsOn: [
    moduleStorageAccount
    moduleStorageAccountForFunctionApp
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
    enableAppConfig: enableAppConfig
    appconfig_name: enableAppConfig ? appconfig_name : ''
    appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
    appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : ''
    enableDiagnostic: enableDiagnostic
    loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
    applicationinsights_name: enableDiagnostic ? moduleApplicationInsights.outputs.appinsights_name : ''
    applicationinsights_resourcegroup: enableDiagnostic ? moduleApplicationInsights.outputs.applicationinsights_resourcegroup : ''
    keyvault_name: moduleKeyVault.outputs.keyvault_name
    storage_name: moduleStorageAccountForLogicAppStd.outputs.storage_name
    storage_resourcegroup: moduleStorageAccountForLogicAppStd.outputs.storage_resourcegroup
    storage_subscriptionId: moduleStorageAccountForLogicAppStd.outputs.storage_subscriptionId
    workflowhostingplan_name: moduleWorkflowHostingPlan.outputs.workflowhostingplan_name
    workflowhostingplan_resourcegroup: moduleWorkflowHostingPlan.outputs.workflowhostingplan_resourcegroup
    workflowhostingplan_subscriptionId: moduleWorkflowHostingPlan.outputs.workflow_hostingplan_subscriptionId
    enablePrivateLink: enablePrivateLink
    enableVNETIntegration: enableVNETIntegration
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
    vnetintegrationSubnetName: logicAppStdSubnetName
    vnetintegrationSubnetAddressPrefix: logicAppStdSubnetAddressPrefix
    createSubnet: createLogicAppStdSubnet
  }
  dependsOn: [
    moduleFunctionApp
  ]
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
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
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
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
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
//     enableAppConfig: enableAppConfig
//     appconfig_name: enableAppConfig ? appconfig_name : ''
//     appconfig_resourcegroup: enableAppConfig ? appconfig_resourcegroup : ''
//     appconfig_subscriptionId: enableAppConfig ? appconfig_subscriptionId : '' 
//     enableDiagnostic: enableDiagnostic
//     loganalyticsWorkspace_name: enableDiagnostic ? moduleLogAnalytics.outputs.loganalyticsWorkspace_name : ''
//   }
// }
