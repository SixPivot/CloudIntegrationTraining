param functionapp_name string 
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

resource functionApp 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionapp_name
}

//****************************************************************
// Azure Logic App Std App Config
//****************************************************************

resource FunctionAppConfigSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: functionApp
  properties: union(currentAppSettings, newAppSettings)
}
