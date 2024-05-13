param BaseName string = 'CloudIntegrationTraining'
param BaseShortName string = 'cit'
param EnvironmentName string = 'devops'
param EnvironmentShortName string = 'devops'
param AppLocation string = resourceGroup().location
@allowed([
  'auea'
  'ause'
])
param AzureRegion string = 'ause'
param Instance int = 1

// tags
param BusinessOwner string = '$(BusinessOwner)'
param CostCentre string = '$(CostCentre)'
param Workload string = '$(Workload)'

param virtualNetworkName string 
param virtualNetworkResourceGroup string 
param networksecuritygroupName string 
param privatelinkSubnetName string = '$(privatelinkSubnetName)'

//****************************************************************
// Variables
//****************************************************************

var InstanceString = padLeft(Instance,3,'0')
var vmss_name = 'vmss-${toLower(BaseName)}-${toLower(EnvironmentName)}-${toLower(AzureRegion)}-${InstanceString}'

//****************************************************************
// Existing Azure Resources
//****************************************************************

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: privatelinkSubnetName
  parent: virtualNetwork
}

resource networksecuritygroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' existing = {
  name: networksecuritygroupName
  scope: resourceGroup(virtualNetworkResourceGroup)
}

resource devopsScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: vmss_name
  location: AppLocation
  sku:{
    name: 'Standard_D2s_v5'
    tier: 'Standard'
    capacity: 0
  }
  properties: {
    singlePlacementGroup: false
    orchestrationMode: 'Uniform'
    upgradePolicy:{
      mode: 'Manual'
    }
    scaleInPolicy: { 
      rules: [
        'Default'
      ]
      forceDeletion: false
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmssagent'
        adminUsername: ''
        adminPassword: ''
        windowsConfiguration: {
          provisionVMAgent: true
          enableAutomaticUpdates: true
          enableVMAgentPlatformUpdates: false
        }
        secrets:[]
        allowExtensionOperations: true
        requireGuestProvisionSignal: true
      }
      storageProfile: {
        osDisk: {
          osType: 'Windows'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          diskSizeGB: 127
        }
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2022-datacenter-azure-edition'
          version: 'latest'
        }
        diskControllerType: 'SCSI'
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${vmss_name}-nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              disableTcpStateTracking: false
              networkSecurityGroup: {
                id: networksecuritygroup.id
              }
              dnsSettings: {
                dnsServers: []
              }
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: '${vmss_name}-nic-defaultIpConfiguration'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnet.id
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
    overprovision: false
    doNotRunExtensionsOnOverprovisionedVMs: false
    platformFaultDomainCount: 1
  }
}
