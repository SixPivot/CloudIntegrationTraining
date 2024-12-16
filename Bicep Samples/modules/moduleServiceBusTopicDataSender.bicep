// parameters
param servicebusnamespace_name string 
param topic_name string 
param principalid string 

//****************************************************************
// Role Definitions
//****************************************************************
var ServiceBusDataSender = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')

//****************************************************************
// Existing Azure Resources
//****************************************************************
resource servicebusnamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: servicebusnamespace_name
}

resource ServiceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  parent: servicebusnamespace
  name: topic_name
}

//****************************************************************
// Service Bus Topic Role Assignment
//****************************************************************

resource servicebusRoleAssignmentServiceBusDataSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(ServiceBusTopic.id, principalid, ServiceBusDataSender)
  scope: ServiceBusTopic
  properties: {
    roleDefinitionId: ServiceBusDataSender
    principalId: principalid
    principalType: 'ServicePrincipal'
  }
}
