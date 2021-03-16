targetScope = 'subscription'

param rgName string = 'apim-rg'
param location string = 'francecentral'
param aks_cluster_name string = 'myk8scluster'

//// Activate-Deactivate Component ///
param activate_apim bool = true
param activate_aks bool = true

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

module apim './apim-quickstart.bicep' = if (activate_apim) {
  name: 'apim'
  scope: resourceGroup(rgName)
  params: {
    publisherEmail: 't-leocartel@microsoft.com'
    publisherName: 'leo'
  }
}

module aks_cluster 'aks-quickstart.bicep' = if (activate_aks) {
  name: 'aks_cluster'
  scope: resourceGroup(rgName)
  params: {
    aksClusterName: aks_cluster_name
    agentCount: 1 //1 agen for dev
    dnsPrefix: '${aks_cluster_name}-dns'
  }
}

output cluster_name string = aks_cluster_name