param appconfig_name string = ''
param principalid string = ''
param principaltype string = ''
param roledefinitionid string = ''

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: appconfig_name
}

resource appconfigRoleAssignmentAzureDevOpsServiceConnectionId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: appconfig
  name: guid(appconfig.id, principalid, roledefinitionid)
  properties: {
    roleDefinitionId: roledefinitionid
    principalId: principalid
    principalType: principaltype
  }
}
