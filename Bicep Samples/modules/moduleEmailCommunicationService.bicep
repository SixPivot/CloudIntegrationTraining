// environment parameters
param BaseName string
param BaseShortName string 
param AppName string 
param AppShortName string 
param EnvironmentName string 
param EnvironmentShortName string 
param AppLocation string 
param AzureRegion string 
param Instance int = 1
param enableAppConfig bool 
param appconfig_name string 
param appconfig_resourcegroup string 
param appconfig_subscriptionId string
param enableDiagnostic bool  

param acs_sender_name string
param keyvault_name string 
param keyvault_resourcegroup string   

// tags
param tags object = {}

//****************************************************************
// Variables
//****************************************************************

var acsapp_app_name = !empty(AppName) ? '${AppName}' : ''
var acsapp_appkey_name = !empty(AppName) ? '${AppName}_' : ''
var InstanceString = padLeft(Instance,3,'0')
var acsapp_name = 'acs-${toLower(BaseName)}${toLower(acsapp_app_name)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'
var acsappemail_name = 'acsemail-${toLower(BaseName)}${toLower(acsapp_app_name)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

resource commService 'Microsoft.Communication/communicationServices@2023-04-01-preview' = {
    name: acsapp_name
    location: 'global'
    identity:{
        type: 'SystemAssigned'
    }
    properties:{
        dataLocation: 'Australia'
        linkedDomains: [
	        emailServiceDomain.id
        ]
    }
}

resource emailService 'Microsoft.Communication/emailServices@2023-04-01-preview' = {
    name: acsappemail_name
    location: 'global'
    properties:{
        dataLocation: 'Australia'
    }
}

resource emailServiceDomain 'Microsoft.Communication/emailServices/domains@2023-04-01-preview' = {
    name: 'AzureManagedDomain'
    parent: emailService
    location: 'global'
    properties:{
        domainManagement: 'AzureManaged'
        userEngagementTracking: 'Disabled'
    }
}

resource emailServiceDomainSender 'Microsoft.Communication/emailServices/domains/senderUsernames@2023-04-01-preview' = {
    name: '${acs_sender_name}_${EnvironmentName}'
    parent: emailServiceDomain
    properties:{
        displayName: '${acs_sender_name}_${EnvironmentName}'
        username: '${acs_sender_name}_${EnvironmentName}'
    }
}

module moduleKeyVaultSecretCommunicationServiceConnectionString './moduleKeyVaultSecret.bicep' = {
  name: 'keyvaultSecretCommunicationServiceConnectionString'
  scope: resourceGroup(keyvault_resourcegroup)
  params: {
    keyvault_name: keyvault_name
    tags: tags
    secretName: 'CommunicationServiceConnectionString'
    secretValue: commService.listKeys().primaryConnectionString
  }
}

module moduleAppConfigKeyValueCommunicationServiceConnectionString './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'CommunicationServiceConnectionString'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'CommunicationServiceConnectionString'
    variables_value: '{"uri":"${moduleKeyVaultSecretCommunicationServiceConnectionString.outputs.secretUri}"}'
    variables_contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

module moduleAppConfigKeyValueCommunicationServiceEmailSenderAddres './moduleAppConfigKeyValue.bicep' = if(enableAppConfig) {
  name: 'CommunicationServiceEmailSenderAddres'
  scope: resourceGroup(appconfig_subscriptionId,appconfig_resourcegroup)
  params: {
    variables_appconfig_name: appconfig_name
    variables_environment: EnvironmentName
    variables_key: 'CommunicationServiceEmailSenderAddres'
    variables_value: '${emailServiceDomainSender.name}@${emailServiceDomain.properties.fromSenderDomain}'
  }
}
