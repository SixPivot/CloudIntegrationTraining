param ruleName string
param container_name string
param deleteafterdays int
param storage_name string
param storage_resourcegroup string 

resource storage 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storage_name
}

resource managementPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  name: 'default'
  parent: storage
  properties: {
    policy: {
      rules: [
        {
          name: ruleName
          type: 'Lifecycle'
          definition: {
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: [
                container_name
              ]
            }
            actions: {
              baseBlob: {
                delete: {
                  daysAfterLastAccessTimeGreaterThan: deleteafterdays
                }
              }
            }
          }
        }
      ]
    }
  }
}

