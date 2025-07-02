terraform {
  source = "${local.terraform_module_source}?version=${local.terraform_module_version}"
}

dependency "sg" {
  config_path  = "${get_terragrunt_dir()}/../sg"
  mock_outputs = yamldecode(file("${get_repo_root()}/_mocks/sg.yaml"))


locals {
  terraform_module_source  = "tfr:///terraform-aws-modules/ec2-instance/aws"
  terraform_module_version = "5.7.1"
}

inputs = {
  name       = "single-instance"
  monitoring = true
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
}
