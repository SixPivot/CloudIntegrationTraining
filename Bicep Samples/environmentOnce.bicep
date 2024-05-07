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

param virtualNetworkName string = '$(virtualNetworkName)'
param virtualNetworkResourceGroup string = '$(virtualNetworkResourceGroup)'

param appconfig_resourcegroup string = '$(appconfig_resourcegroup)'
param appconfig_subscriptionId string = '$(appconfig_subscriptionId)'
param appconfig_DNSZone string = '$(appconfig_DNSZone)'
param resourcemanagerPL_resourcegroup string = '$(resourcemanagerPL_resourcegroup)'
param resourcemanagerPL_subscriptionId string = '$(resourcemanagerPL_subscriptionId)'
param resourcemanagerPL_DNSZone string = '$(resourcemanagerPL_DNSZone)'

//****************************************************************
// Create DNS Zone Links for RM & App Config
//****************************************************************

var SharedVNETLinks = [
  {
    link: 'RM'
    linkResourceGroup: resourcemanagerPL_subscriptionId
    linkSubscription: resourcemanagerPL_resourcegroup
    DNSZone: resourcemanagerPL_DNSZone
  }
  {
    link: 'AppConfig'
    linkResourceGroup: resourcemanagerPL_subscriptionId
    linkSubscription: resourcemanagerPL_resourcegroup
    DNSZone: resourcemanagerPL_DNSZone
  }
]

module moduleDNSZoneVirtualNetworkLink './modules/moduleDNSZoneVirtualNetworkLink.bicep' = [for (link, index) in SharedVNETLinks: {
  name: 'moduleDNSZoneVirtualNetworkLink-${link.link}'
  scope: resourceGroup(link.linkResourceGroup, link.linkSubscription)
  params: {
    linkId: EnvironmentName
    DNSZone_name: link.DNSZone
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceGroup: virtualNetworkResourceGroup
    virtualNetworkSubscriptionId: subscription().subscriptionId
  }
}]
