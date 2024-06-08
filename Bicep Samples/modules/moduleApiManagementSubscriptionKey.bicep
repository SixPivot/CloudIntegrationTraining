param apimanagement_name string 
param apimanagement_resourcegroup string 
param appName string
param apiName string

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource apimanagement 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimanagement_name
}

resource API 'Microsoft.ApiManagement/service/apis@2023-03-01-preview' existing = {
  name: apiName
  parent: apimanagement
}

resource apimAPISubscriptionKey 'Microsoft.ApiManagement/service/subscriptions@2023-03-01-preview' = {  
  name: '${appName}-${apiName}'  
  parent: apimanagement  
  properties: {    
    allowTracing: true    
    displayName: '${appName}-${apiName}'    
    scope: API.id    
  }
}

output subscriptionKeyPrimary string = apimAPISubscriptionKey.listSecrets(apimAPISubscriptionKey.apiVersion).primaryKey
output subscriptionKeySecondary string = apimAPISubscriptionKey.listSecrets(apimAPISubscriptionKey.apiVersion).secondaryKey
