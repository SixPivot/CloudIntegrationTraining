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

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'
param AppConfigReaderGroupId string = '$(AppConfigReaderGroupId)'

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
  }
}
