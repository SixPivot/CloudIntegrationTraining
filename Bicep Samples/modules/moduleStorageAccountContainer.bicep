param container_name string
param storage_name string
param storage_resourcegroup string 

resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storage_name
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-04-01' existing = {
  parent: storage
  name: 'default'
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-04-01' = {
  name: container_name
  parent: blobService
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'None'
  }
}

output storagecontainer_name string = storageContainer.name
