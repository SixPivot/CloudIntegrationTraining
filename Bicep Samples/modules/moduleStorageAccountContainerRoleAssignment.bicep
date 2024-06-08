param container_name string
param storage_name string
param storage_resourcegroup string 

param principalid string 
param principaltype string 
param roledefinitionid string 

resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storage_name
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' existing = {
  parent: storage
  name: 'default'
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' existing = {
  name: container_name
  parent: blobService
}

resource storagecontainerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageContainer
  name: guid(storageContainer.id, principalid, roledefinitionid)
  properties: {
    roleDefinitionId: roledefinitionid
    principalId: principalid
    principalType: principaltype
  }
}
