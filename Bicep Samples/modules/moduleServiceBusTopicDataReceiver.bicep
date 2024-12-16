// parameters
param servicebusnamespace_name string 
param topic_name string 
param principalid string 

//****************************************************************
// Role Definitions
//****************************************************************
var ServiceBusDataReceiver = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')

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

resource servicebusRoleAssignmentServiceBusDataReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(ServiceBusTopic.id, principalid, ServiceBusDataReceiver)
  scope: ServiceBusTopic
  properties: {
    roleDefinitionId: ServiceBusDataReceiver
    principalId: principalid
    principalType: 'ServicePrincipal'
  }
}
