param variables_appconfig_name string
param variables_environment string
param variables_key string
param variables_value string
param variables_contentType string = ''

resource appconfig 'Microsoft.AppConfiguration/configurationStores@2023-08-01-preview' existing = {
  name: variables_appconfig_name
}

resource appconfig_name_keyvalue 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-08-01-preview' = {
  name: '${variables_key}$${variables_environment}'
  parent: appconfig
  properties: {
    value: variables_value
    contentType: variables_contentType
  }
}
