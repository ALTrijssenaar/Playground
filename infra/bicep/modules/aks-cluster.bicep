// Generic
param resourcePrefix string = '${resourceGroup().name}-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

// Module specific
param nodeCount int = 3
param vmSize string = 'standard_d2s_v3'

resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: replace('${resourcePrefix}-acr', '-', '')
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${resourcePrefix}-aks'
  location: location
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: '${resourcePrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/8'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.240.0.0/16'
        }
      }
    ]
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2022-08-03-preview' = {
  name: '${resourcePrefix}-aks'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${resourcePrefix}-aks'
    enableRBAC: true

    agentPoolProfiles: [
      {
        name: 'agentpool1'
        mode: 'System'

        vmSize: vmSize
        type: 'VirtualMachineScaleSets'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]

        enableAutoScaling: true
        count: nodeCount
        minCount: nodeCount
        maxCount: 6

        vnetSubnetID: virtualNetwork.properties.subnets[0].id
      }

    ]
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'Standard'
    }
  }
}

// "Create AKS cluster"
// az aks create `
//     --attach-acr $azureContainerRegistry `

//     --generate-ssh-keys `
//     --enable-addons monitoring,virtual-node `
//     --aci-subnet-name aci `
//     --vnet-subnet-id $subnetId

// "Get cluster credentials"
// az aks get-credentials -n $clusterName -g $resourceGroup
