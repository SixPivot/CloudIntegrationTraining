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

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'

module moduleResourceManagerPrivateLink './modules/moduleResourceManagerPrivateLink.bicep' = {
  name: 'moduleResourceManagerPrivateLink'
  params:{
    BaseName: BaseName
    BaseShortName: BaseShortName
    EnvironmentName: EnvironmentName
    EnvironmentShortName: EnvironmentShortName
    AppLocation: AppLocation
    AzureRegion: AzureRegion
    Instance: Instance
    privatelinkSubnetName: privatelinkSubnetName
    resourcemanagerPL_name: resourcemanagerPL_name
    resourcemanagerPL_resourceGroup: resourcemanagerPL_resourcegroup
    resourcemanagerPL_subscriptionId: resourcemanagerPL_subscriptionId
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
  }
}

module moduleDNSZoneVirtualNetworkLinkRMDevOps './modules/moduleDNSZoneVirtualNetworkLink.bicep' = {
  name: 'moduleDNSZoneVirtualNetworkLinkRMDevOps'
  scope: resourceGroup(resourcemanagerPL_subscriptionId, resourcemanagerPL_resourcegroup)
  params: {
    linkId: 'DevOps'
    DNSZone_name: moduleResourceManagerPrivateLink.outputs.DNSZone
    virtualNetworkName: virtualNetworkNameDevOps
    virtualNetworkResourceGroup: virtualNetworkResourceGroupDevOps
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdDevOps
  }
}

module moduleDNSZoneVirtualNetworkLinkRMVMInside './modules/moduleDNSZoneVirtualNetworkLink.bicep' = if (virtualNetworkNameDevOps != virtualNetworkNameVMInside) {
  name: 'moduleDNSZoneVirtualNetworkLinkRMVMInside'
  scope: resourceGroup(resourcemanagerPL_subscriptionId, resourcemanagerPL_resourcegroup)
  params: {
    linkId: 'VMInside'
    DNSZone_name: moduleResourceManagerPrivateLink.outputs.DNSZone
    virtualNetworkName: virtualNetworkNameVMInside
    virtualNetworkResourceGroup: virtualNetworkResourceGroupVMInside
    virtualNetworkSubscriptionId: virtualNetworkSubscriptionIdVMInside
  }
}

module moduleLogAnalytics './modules/moduleLogAnalyticsWorkspace.bicep' = {
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
    enableAppConfig: false
    appconfig_name: ''
    appconfig_resourcegroup: ''
    appconfig_subscriptionId: ''
    enablePrivateLink: enablePrivateLink
    privatelinkSubnetName: enablePrivateLink ? privatelinkSubnetName : ''
    virtualNetworkName: enablePrivateLink ? virtualNetworkName : ''
    virtualNetworkResourceGroup: enablePrivateLink ? virtualNetworkResourceGroup  : ''
    publicNetworkAccessForIngestion: publicNetworkAccess
    publicNetworkAccessForQuery: publicNetworkAccess
  }
}

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
    moduleDNSZoneVirtualNetworkLinkRMDevOps
    moduleAppConfiguration
  ]
}
