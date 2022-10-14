param resourceGroupName string
param location string

module aks './modules/aks-cluster.bicep' = {
  name: '${resourceGroupName}-cluster'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
  }
}
