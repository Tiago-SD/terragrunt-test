terraform {
  source = "${local.terraform_module_source}?version=${local.terraform_module_version}"
}

locals {
  terraform_module_source  = "tfr:///terraform-aws-modules/ec2-instance/aws"
  terraform_module_version = "5.7.1"
}

inputs = {
  name       = "single-instance"
  monitoring = true
}
