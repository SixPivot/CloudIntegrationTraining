param storage_name string
param storage_resourcegroup string 

param principalid string 
param principaltype string 
param roledefinitionid string 

resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storage_name
}

resource storagecontainerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.id, principalid, roledefinitionid)
  properties: {
    roleDefinitionId: roledefinitionid
    principalId: principalid
    principalType: principaltype
  }
}
