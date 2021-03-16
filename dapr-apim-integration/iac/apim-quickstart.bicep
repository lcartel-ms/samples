@minLength(1)
@description('The email address of the owner of the service')
param publisherEmail string

@minLength(1)
@description('The name of the owner of the service')
param publisherName string

@allowed([
  'Developer'
  'Standard'
  'Premium'
])
@description('The pricing tier of this API Management service')
param sku string = 'Developer'

@allowed([
  1
  2
])
@description('The instance size of this API Management service.')
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the api')
param apimName string = 'apiservice${uniqueString(resourceGroup().id)}'

resource apiManagementServiceName 'Microsoft.ApiManagement/service@2019-12-01' = {
  name: apimName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}
