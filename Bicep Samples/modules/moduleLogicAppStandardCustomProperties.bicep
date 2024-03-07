param logicapp_name string = ''
param currentProperties object 
param newProperties object

//****************************************************************
// Variables
//****************************************************************

//****************************************************************
// Azure Logic App Std 
//****************************************************************

resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicapp_name
  properties: union(currentProperties, newProperties)
}
