terraform {
  source = "${local.terraform_module_source}?version=${local.terraform_module_version}"
}

locals {
  terraform_module_source  = "tfr:///terraform-aws-modules/sg/aws"
  terraform_module_version = "5.3.0"
}

inputs = {
  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    }
  ]
}