param logicapp_name string 
param currentAppSettings object 
param newAppSettings object

//****************************************************************
// Variables
//****************************************************************

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource LogicAppStdApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: logicapp_name
}

//****************************************************************
// Azure Logic App Std App Config
//****************************************************************

resource LogicAppStdAppConfigSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: LogicAppStdApp
  properties: union(currentAppSettings, newAppSettings)
}

