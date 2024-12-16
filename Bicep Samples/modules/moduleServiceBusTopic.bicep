// parameters
param servicebusnamespace_name string 
param topic_name string 
param principalid string 
param principaltype string 
param CreateRoleAssignment bool 


//****************************************************************
// Variables
//****************************************************************

//****************************************************************
// Role Definitions
//****************************************************************

// az role definition list --query "[].{name:name, roleType:roleType, roleName:roleName}" --output tsv

// 090c5cfd-751d-490a-894a-3ce6f1109419    BuiltInRole     Azure Service Bus Data Owner
// 4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0    BuiltInRole     Azure Service Bus Data Receiver
// 69a216fc-b8fb-44d8-bc22-1f3c2cd27a39    BuiltInRole     Azure Service Bus Data Sender

var ServiceBusDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
var ServiceBusDataReceiver = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
var ServiceBusDataSender = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource servicebusnamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: servicebusnamespace_name
}

//****************************************************************
// Service Bus Topic
//****************************************************************

resource servicebustopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: servicebusnamespace
  name: topic_name
  properties: {
    enablePartitioning: false
    defaultMessageTimeToLive: 'P14D'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    status: 'Active'
    supportOrdering: true
  }
}

//****************************************************************
// Service Bus Topic Role Assignment
//****************************************************************

resource servicebusRoleAssignmentServiceBusDataOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (CreateRoleAssignment) {
  scope: servicebustopic
  name: guid(servicebustopic.id, principalid, ServiceBusDataOwner)
  properties: {
    roleDefinitionId: ServiceBusDataOwner
    principalId: principalid
    principalType: principaltype
  }
}

output topic_name string = servicebustopic.name
