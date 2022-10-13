targetScope = 'subscription'
param resourcePrefix string
param location string

var resourceGroupName = '${resourcePrefix}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
}

module aks './aks-cluster.bicep' = {
  name: '${resourcePrefix}-cluster'
  scope: rg
  params: {
    location: location
    clusterName: resourcePrefix
  }
}
