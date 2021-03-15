targetScope = 'subscription'

param rgName string = 'apim-rg'
param location string = 'francecentral'

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: location
}

module apim './apim-quickstart.bicep' = {
  name: 'apim'
  scope: resourceGroup(rg.name)
  params: {
    publisherEmail: 't-leocartel@microsoft.com'
    publisherName: 'leo'
  }
}

