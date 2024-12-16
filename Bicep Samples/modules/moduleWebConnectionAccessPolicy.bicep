param AppLocation string
param webconnection_name string
param logicappstd_Name string
param logicappstd_principalid string

resource WebConnection 'Microsoft.Web/connections@2018-07-01-preview' existing = {
  name: webconnection_name
}

resource accessPolicy 'Microsoft.Web/connections/accessPolicies@2018-07-01-preview' = {
  name: logicappstd_Name
  parent: WebConnection
  location: AppLocation
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: logicappstd_principalid
      }
    }
  }
}
