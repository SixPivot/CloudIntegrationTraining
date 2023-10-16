param NamedValueName string
param NamedValueDisplayName string
param NamedValueTag string
param NamedValueSecret bool
param NamedValueValue string
param apimanagement_name string 
param apimanagementLogging_name string 

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

//****************************************************************
// APIM API Version Set 
//****************************************************************\

resource apiversionset 'Microsoft.ApiManagement/service/apiVersionSets@2023-03-01-preview' = {
  name: 'ap1v1'
  parent: apimanagement
  properties: {
    description: 'api v1'
    displayName: 'api v1'
    // versionHeaderName: 'string'
    versioningScheme: 'Segment'
    // versionQueryName: 'string'
  }
}

resource api1 'Microsoft.ApiManagement/service/apis@2022-09-01-preview' = {
  name: 'api1'
  parent: apimanagement
  properties:{
    displayName:'api1'
    path:'api1' 
    subscriptionRequired: true
    protocols: [
      'https'
    ]
    apiVersionSet: apiversionset
    apiVersion: 'V1'
  }
}

resource inboundAPIDiagnostics 'Microsoft.ApiManagement/service/apis/diagnostics@2022-09-01-preview'= {
  name: 'applicationinsights'
  parent: api1
  properties:{
    alwaysLog: 'allErrors'
    loggerId: resourceId('Microsoft.ApiManagement/service/loggers', apimanagement.name, apimanagementLogging_name)
    sampling: {
      percentage:100
      samplingType: 'fixed'
    }
    logClientIp:true
    verbosity:'information'
    httpCorrelationProtocol:'Legacy'
  }
}

var Policy_Api1 = loadTextContent('./Policies/api1.xml')

resource apimPolicyInbound 'Microsoft.ApiManagement/service/apis/policies@2022-09-01-preview' = {
  name: 'policy'
  parent: api1
  properties:{
    format: 'xml'
    value: Policy_Api1
  }
}
