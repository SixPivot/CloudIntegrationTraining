// environment parameters
param BaseName string = 'enterpriseapps'
param BaseShortName string = 'ea'
param EnvironmentName string = 'shared'
param EnvironmentShortName string = 'shr'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1

// tags
param BusinessImpact string = '$(BusinessImpact)'
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param CostOwner string = '$(CostOwner)'
param InformationClassification string = '$(InformationClassification)'
param Owner string = '$(Owner)'
param ServiceClass string = '$(ServiceClass)'
param Workload string = '$(Workload)'

// service principals and groups
param AzureDevOpsServiceConnectionId string = '$(AzureDevOpsServiceConnectionId)'
param AppConfigAdministratorsGroupId string = '$(AppConfigAdministratorsGroupId)'

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
      BusinessImpact: BusinessImpact
      BusinessOwner: BusinessOwner
      CostCentre: CostCentre
      CostOwner: CostOwner
      InformationClassification: InformationClassification
      Owner: Owner
      ServiceClass: ServiceClass
      Workload: Workload
    }
    AzureDevOpsServiceConnectionId: AzureDevOpsServiceConnectionId
    AppConfigAdministratorsGroupId:AppConfigAdministratorsGroupId
  }
}
