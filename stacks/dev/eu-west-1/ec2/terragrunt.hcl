include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "common" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_common/ec2/ec2.hcl"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment      = local.environment_vars.locals.environment
  instance_type    = local.environment_vars.locals.instance_type
  key_pair_name    = local.environment_vars.locals.key_pair_name
  ec2_sg           = local.environment_vars.locals.ec2_sg
  private_subnet   = local.environment_vars.locals.private_subnet
}

inputs = {
  instance_type          = local.instance_type
  key_name               = local.key_pair_name
  subnet_id              = local.private_subnet

  tags = {
    Terraform   = "true"
    environment = local.environment
  }
}
