locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_account_id = local.account_vars.locals.aws_account_id
  aws_region     = local.region_vars.locals.aws_region
  env_name       = local.environment_vars.locals.environment
}

terraform {
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

  before_hook "tflint" {
    commands = ["apply", "plan", "validate"]
    execute  = ["tflint", "--config", "${dirname(find_in_parent_folders("root.hcl"))}/.tflint.hcl"]
  }

  after_hook "init_lock_providers" {
    commands     = ["init"]
    execute      = ["terraform", "providers", "lock", "-platform=darwin_amd64", "-platform=darwin_arm64", "-platform=linux_amd64", "-platform=linux_arm64"]
    run_on_error = false
  }

  after_hook "init_copy_back_lockfile" {
    commands     = ["init"]
    execute      = ["cp", ".terraform.lock.hcl", "${get_terragrunt_dir()}"]
    run_on_error = false
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  allowed_account_ids = ["${local.aws_account_id}"]
}
EOF
}

remote_state {
  backend = "s3"

  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket  = "si-playground-ops"
    key     = "tiago/terragrunt-test/${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
    # dynamodb_table = "terraform-locks-${local.aws_account_id}"
  }
}

inputs = merge(
  {
    tags = {
      Owner       = "Tiago Domingues"
      Contact     = "Tiago Domingues"
      Project     = "Terragrunt Test"
      Environment = local.env_name
    }
  }
)
