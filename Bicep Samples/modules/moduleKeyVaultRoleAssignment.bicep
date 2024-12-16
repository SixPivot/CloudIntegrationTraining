param keyvault_name string 
param principalid string 
param principaltype string 
param roledefinitionid string  

resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyvault_name
}

resource keyvaultRoleAssignmentKeyVaultReaderGroupId 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyvault
  name: guid(keyvault.id, principalid, roledefinitionid)
  properties: {
    roleDefinitionId: roledefinitionid
    principalId: principalid
    principalType: principaltype
  }
}
