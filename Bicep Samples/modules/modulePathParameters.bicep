param logicAppCallBackObject object

var hasRelativePath = logicAppCallBackObject.?relativePath != null ? true : false
var pathParametersList = hasRelativePath ? logicAppCallBackObject.relativePathParameters : []
var pathParameters = [for pathParameter in pathParametersList: {    
  name: pathParameter    
  type: 'string'
}]

output pathParameters object[] = pathParameters
