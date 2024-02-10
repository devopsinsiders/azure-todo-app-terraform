module "rgs" {
  source = "../modules/ResourceGroup"
  rgs    = var.rgs
}

module "networking" {
  depends_on    = [module.rgs]
  source        = "../modules/Networking"
  vnets_subnets = var.vnets_subnets
}

module "vms" {
  depends_on      = [module.rgs, module.networking]
  source          = "../modules/LinuxVirtualMachine"
  vms             = var.vms
  vnet_subnet_ids = module.networking.vnet_subnet_ids
}

# module "loadbalancers" {
#   depends_on    = [module.rgs, module.networking, module.vms]
#   source        = "../modules/LoadBalancer"
#   loadbalancers = var.loadbalancers
#   backend_pools = var.backend_pools
#   nic_ids       = module.vms.vm_nic_ids
# }

module "database" {
  depends_on  = [module.rgs]
  source      = "../modules/Database"
  servers_dbs = var.servers_dbs
}
