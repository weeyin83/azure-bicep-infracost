targetScope = 'resourceGroup'

param workloadName string = 'finops'
param environmentName string = 'demo'
param location string = resourceGroup().location
@secure()
param vmAdminUsername string
@secure()
param vmAdminPassword string
param vmSize string = 'Standard_D2s_v5'
param vmCount int = 1
param premiumDataDiskSizeGiB int = 128
param bastionSku string = 'Standard'
param logAnalyticsRetentionInDays int = 30
param tags object = {
  application: 'infracost-bicep-demo'
  environment: environmentName
  workload: workloadName
  owner: 'cloud-platform'
  costCenter: 'platform-engineering'
}

var vnetName = 'vnet-${workloadName}-${environmentName}'
var vnetAddressPrefix = '10.10.0.0/16'
var workloadSubnetName = 'WorkloadSubnet'
var workloadSubnetPrefix = '10.10.1.0/24'
var bastionSubnetName = 'AzureBastionSubnet'
var bastionSubnetPrefix = '10.10.255.0/27'
var nsgName = 'nsg-${workloadName}-${environmentName}'
var bastionName = 'bas-${workloadName}-${environmentName}'
var bastionPublicIpName = 'pip-${bastionName}'
var managedIdentityName = 'id-${workloadName}-${environmentName}'
var keyVaultName = take(toLower('kv${workloadName}${environmentName}${uniqueString(resourceGroup().id, workloadName, environmentName)}'), 24)
var kvAdminUserSecretName = 'vm-admin-username'
var kvAdminPasswordSecretName = 'vm-admin-password'
var workspaceName = take('law-${workloadName}-${environmentName}-${uniqueString(resourceGroup().id, workloadName, environmentName)}', 63)
var vmName = '${workloadName}-${environmentName}-vm'
var vmNsgRuleName = 'AllowRdpFromBastion'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    accessPolicies: []
  }
}

resource adminUserSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: kvAdminUserSecretName
  properties: {
    value: vmAdminUsername
  }
}

resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: kvAdminPasswordSecretName
  properties: {
    value: vmAdminPassword
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: logAnalyticsRetentionInDays
    sku: {
      name: 'PerGB2018'
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: vmNsgRuleName
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: bastionSubnetPrefix
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: workloadSubnetName
        properties: {
          addressPrefix: workloadSubnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: bastionPublicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  tags: tags
}

resource bastionHost 'Microsoft.Network/bastionHosts@2023-09-01' = {
  name: bastionName
  location: location
  sku: {
    name: bastionSku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'bastionIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetwork.id}/subnets/${bastionSubnetName}'
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
  tags: tags
}

resource vmNetworkInterface 'Microsoft.Network/networkInterfaces@2023-09-01' = [for i in range(0, vmCount): {
  name: 'nic-${vmName}-${i + 1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-${i + 1}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetwork.id}/subnets/${workloadSubnetName}'
          }
          primary: true
        }
      }
    ]
    enableIPForwarding: false
  }
  tags: tags
}]

resource windowsVm 'Microsoft.Compute/virtualMachines@2023-09-01' = [for i in range(0, vmCount): {
  name: '${vmName}-${i + 1}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'vm-${i + 1}'
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 128
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          name: 'data-disk-${i + 1}'
          lun: 0
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: premiumDataDiskSizeGiB
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNetworkInterface[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]

resource vmMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [for i in range(0, vmCount): {
  name: '${windowsVm[i].name}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.1'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      workspaceId: logAnalyticsWorkspace.properties.customerId
    }
    protectedSettings: {
      workspaceKey: listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
    }
  }
}]

resource vmDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, vmCount): {
  name: 'diag-${windowsVm[i].name}'
  scope: windowsVm[i]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}]

output resourceGroupName string = resourceGroup().name
output vnetResourceId string = virtualNetwork.id
output keyVaultName string = keyVault.name
output keyVaultResourceId string = keyVault.id
output bastionResourceId string = bastionHost.id
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output managedIdentityResourceId string = managedIdentity.id
output windowsVmNames array = [for i in range(0, vmCount): windowsVm[i].name]
