// environment parameters
param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'cit'
param EnvironmentName string = 'shared'
param EnvironmentShortName string = 'shr'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1

param publicNetworkAccess string = 'Disabled'
param enablePrivateLink bool = true
param virtualNetworkName string = 'CloudIntegrationTraining-Shared'
param virtualNetworkResourceGroup string = 'CloudIntegrationTraining-Shared'
param privatelinkSubnetName string = 'default'
param resourcemanagerPL_resourcegroup string = '$(resourcemanagerPL_resourcegroup)'
param resourcemanagerPL_subscriptionId string = '$(resourcemanagerPL_subscriptionId)'
param resourcemanagerPL_name string = '$(resourcemanagerPL_name)'
param virtualNetworkNameDevOps string = 'CloudIntegrationTraining'
param virtualNetworkResourceGroupDevOps string = 'CloudIntegrationTraining'
param virtualNetworkSubscriptionIdDevOps string = '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'
param virtualNetworkNameVMInside string = 'CloudIntegrationTraining'
param virtualNetworkResourceGroupVMInside string = 'CloudIntegrationTraining'
param virtualNetworkSubscriptionIdVMInside string = '3e2bea16-63ed-4349-9b9c-fe2f91f8e3d4'

param privateDNSZoneResourceGroup string = '$(privateDNSZoneResourceGroup)'
param privateDNSZoneSubscriptionId string  = '$(privateDNSZoneSubscriptionId)'

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'

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
//     enableAppConfig: false
//     appconfig_name: ''
//     appconfig_resourcegroup: ''
//     appconfig_subscriptionId: ''
//     enablePrivateLink: enablePrivateLink
//     privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
//     virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
//     virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
//     publicNetworkAccessForIngestion: publicNetworkAccess
//     publicNetworkAccessForQuery: publicNetworkAccess
//     // VNETLinks: []
//     privateDNSZoneResourceGroup: privateDNSZoneResourceGroup
//     privateDNSZoneSubscriptionId: privateDNSZoneSubscriptionId
//   }
// }

module moduleAppConfiguration './modules/moduleAppConfiguration.bicep' = {
  name: 'moduleAppConfiguration'
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
    AppConfigAdministratorsGroupId: AppConfigAdministratorsGroupId
    AppConfigReaderGroupId: AppConfigReaderGroupId
    publicNetworkAccessForIngestion: publicNetworkAccess
    publicNetworkAccessForQuery: publicNetworkAccess
    publicNetworkAccess: publicNetworkAccess
    enablePrivateLink: enablePrivateLink
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    privatelinkSubnetName: privatelinkSubnetName
  }
}

// module moduleDNSZoneVirtualNetworkLinkAppConfig './modules/moduleDNSZoneVirtualNetworkLink.bicep' = [for (link, index) in VNETLinks: if (enablePrivateLink) {
//   name: 'moduleDNSZoneVirtualNetworkLinkAppConfig-${link.linkId}'
//   //scope: resourceGroup(resourcemanagerPL_subscriptionId, resourcemanagerPL_resourcegroup)
//   params: {
//     linkId: link.linkId
//     DNSZone_name: moduleAppConfiguration.outputs.DNSZone
//     virtualNetworkName: link.virtualNetworkName
//     virtualNetworkResourceGroup: link.virtualNetworkResourceGroup
//     virtualNetworkSubscriptionId: link.virtualNetworkSubscriptionId
//   }
//   dependsOn:[
//     moduleAppConfiguration
//   ]
// }]

// module moduleDNSZoneVirtualNetworkLinkAppConfigDevOps './modules/moduleDNSZoneVirtualNetworkLink.bicep' = {
//   name: 'moduleDNSZoneVirtualNetworkLinkAppConfigDevOps'
//   scope: resourceGroup(resourcemanagerPL_subscriptionId, resourcemanagerPL_resourcegroup)
//   params: {
//     linkId: 'DevOps'
//     DNSZone_name: moduleAppConfiguration.outputs.DNSZone
//     virtualNetworkName: virtualNetworkNameDevOps
//     virtualNetworkResourceGroup: virtualNetworkResourceGroupDevOps
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdDevOps
//   }
//   dependsOn:[
//     moduleAppConfiguration
//   ]
// }

// module moduleDNSZoneVirtualNetworkLinkAppConfigVMInside './modules/moduleDNSZoneVirtualNetworkLink.bicep' = if (virtualNetworkNameDevOps != virtualNetworkNameVMInside) {
//   name: 'moduleDNSZoneVirtualNetworkLinkAppConfigVMInside'
//   scope: resourceGroup(resourcemanagerPL_subscriptionId, resourcemanagerPL_resourcegroup)
//   params: {
//     linkId: 'VMInside'
//     DNSZone_name: moduleAppConfiguration.outputs.DNSZone
//     virtualNetworkName: virtualNetworkNameVMInside
//     virtualNetworkResourceGroup: virtualNetworkResourceGroupVMInside
//     virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdVMInside
//   }
//   dependsOn:[
//     moduleAppConfiguration
//   ]
// }

//****************************************************************
// Add Key Vault name and resource group to App Configuration
//****************************************************************

module moduleAppConfigKeyValuetesst1name './modules/moduleAppConfigKeyValue.bicep' = {
  name: 'test1_name'
  params: {
    variables_appconfig_name: moduleAppConfiguration.outputs.appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'test1_name'
    variables_value: 'test1'
  }
  dependsOn:[
    moduleAppConfiguration
  ]
}
