# Outputs file
output "public_ip" {
  description = "LB public IP"
  value       = [azurerm_public_ip.this.*.ip_address]
}


output "pool_member_vms" {
  description = "VM pool members"
  value       = [azurerm_virtual_machine.this.*.name]
}


output "pool_member_vifs" {
  description = "Vif pool members"
  value       = [azurerm_network_interface_backend_address_pool_association.this.*.ip_configuration_name]
}
