param apiManagementName string 
param apiName string
param operationName string
param operationPath string
param operationDisplayname string
param operationMethod string
param lgCallBackObject object

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

resource API 'Microsoft.ApiManagement/service/apis@2023-05-01-preview' existing = {
  name: apiName
  parent: apimanagement
}

var operationUrlBase = split(split(lgCallBackObject.value, '?')[0], '/api')[1]
var hasRelativePath = lgCallBackObject.?relativePath != null ? true : false
var pathParametersList = hasRelativePath ? lgCallBackObject.relativePathParameters : []
var pathParameters = [for pathParameter in pathParametersList: {    
  name: pathParameter    
  type: 'string'
}]
var relativePathHasBeginningSlash = hasRelativePath ? first(lgCallBackObject.relativePath) == '/' : false
var slashedRelativePath = hasRelativePath ? relativePathHasBeginningSlash ? lgCallBackObject.relativePath : '/${lgCallBackObject.relativePath}' : ''
var operationUrl = hasRelativePath ? '${operationUrlBase}${slashedRelativePath}' : operationUrlBase
var operationUrlSimple = hasRelativePath ? '/${operationPath}${slashedRelativePath}' : '/${operationPath}'

resource apimOperation 'Microsoft.ApiManagement/service/apis/operations@2023-05-01-preview' = {  
  name: operationName 
  parent: API 
  properties: {    
    displayName: operationDisplayname    
    method: operationMethod   
    urlTemplate: operationUrlSimple 
    templateParameters: hasRelativePath ? pathParameters : null  
  }
}

output apim_operation object = apimOperation
output apim_operationUrl string = operationUrl
output operationURL string = apimOperation.properties.urlTemplate
output operationName string = apimOperation.name
