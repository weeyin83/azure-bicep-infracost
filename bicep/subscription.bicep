targetScope = 'subscription'

@description('Azure region for the managed landing zone deployment. Default is UK South.')
param location string = 'uksouth'

@description('Short workload identifier used in naming.')
param workloadName string = 'finops'

@description('Environment-based suffix for the deployment.')
param environmentName string = 'demo'

@description('Windows administrator username. Stored in Key Vault.')
@secure()
param vmAdminUsername string

@description('Windows administrator password. Stored in Key Vault.')
@secure()
param vmAdminPassword string

@description('VM SKU target for the Windows workload.')
param vmSize string = 'Standard_D2s_v5'

@description('Number of Windows VMs to deploy.')
param vmCount int = 1

@description('Premium SSD data disk size in GiB.')
param premiumDataDiskSizeGiB int = 128

@description('Bastion SKU to deploy.')
param bastionSku string = 'Standard'

@description('Log Analytics retention period in days.')
param logAnalyticsRetentionInDays int = 30

@description('Optional tags for all deployed resources.')
param tags object = {
  application: 'infracost-bicep-demo'
  environment: environmentName
  workload: workloadName
  owner: 'cloud-platform'
  costCenter: 'platform-engineering'
}

var resourceGroupName = 'rg-${workloadName}-${environmentName}-${location}'

resource landingZoneResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module workload 'main.bicep' = {
  name: 'workloadLandingZone'
  scope: landingZoneResourceGroup
  params: {
    workloadName: workloadName
    environmentName: environmentName
    location: location
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmSize: vmSize
    vmCount: vmCount
    premiumDataDiskSizeGiB: premiumDataDiskSizeGiB
    bastionSku: bastionSku
    logAnalyticsRetentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

output resourceGroupName string = landingZoneResourceGroup.name
output workloadVmNames array = workload.outputs.windowsVmNames
