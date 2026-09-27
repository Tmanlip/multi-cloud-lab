resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "application" {
  name                 = "snet-mcf-app-dev-sea"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.application_subnet_cidr
  ]
}

resource "azurerm_subnet" "private" {
  name                 = "snet-mcf-private-dev-sea"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [
    var.private_subnet_cidr
  ]
}

resource "azurerm_network_security_group" "application" {
  name                = "nsg-mcf-app-dev-sea"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = var.tags
}

resource "azurerm_network_security_group" "private" {
  name                = "nsg-mcf-private-dev-sea"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}