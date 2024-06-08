param apimanagement_name string = '$(apimanagement_name)'
param apiName string
param operationName string
param urlTemplate string
param apiVersion string
param sp string
param sv string
param sigNamedValue string

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apimanagement_name
}

resource API 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  name: apiName
  parent: apimanagement
}

resource apimOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' existing = {  
  name: operationName 
  parent: API
}

var operationPolicy = loadTextContent('../Policies/Operation.xml')

var policyUrlTemplate = replace(operationPolicy, '__urltemplate__', urlTemplate)
var policyApiVersion = replace(policyUrlTemplate, '__api-version__', apiVersion)
var policySP = replace(policyApiVersion, '__sp__', sp)
var policySV = replace(policySP, '__sv__', sv)
var policySIG = replace(policySV, '__sigNamedValue__', sigNamedValue)

resource apimOperationPolicy 'Microsoft.ApiManagement/service/apis/operations/policies@2023-05-01-preview' = {
  name: 'policy'
  parent: apimOperation
  properties: { 
    value: policySIG
    format: 'rawxml'
  }
}
