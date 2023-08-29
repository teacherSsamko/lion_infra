terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

locals {
  env     = "staging"
  db_port = "5432"
  be_port = "8000"
}

module "network" {
  source = "../modules/network"

  env = local.env
}

module "db_server" {
  source = "../modules/server"

  env              = local.env
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.subnet_id
  name             = "db"
  init_script_path = "db_init_script.tftpl"
  init_script_vars = {
    password    = var.password
    db          = "lionforum"
    db_user     = "lion"
    db_password = var.db_password
    db_port     = local.db_port
  }
  port_range = local.db_port
}
