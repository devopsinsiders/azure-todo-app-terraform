output "rg_ids" {
  value = module.rgs.rg_ids
}

output "vnet_subnet_ids" {
  value = module.networking.vnet_subnet_ids
}

output "vm_private_ips" {
  value = module.vms.vm_private_ips
}

output "vm_public_ips" {
  value = module.vms.vm_public_ips
}

output "vm_nic_ids" {
  value = module.vms.vm_nic_ids
}


