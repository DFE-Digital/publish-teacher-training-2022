terraform {
  required_version = "= 0.12.29"
  backend azurerm {
    container_name = "paas-tfstate"
  }
}
