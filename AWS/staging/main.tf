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

module "be_server" {
  source = "../modules/server"

  env              = local.env
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.subnet_id
  name             = "be"
  init_script_path = "be_init_script.tftpl"
  init_script_vars = {
    password               = var.password
    db                     = "lionforum"
    db_user                = "lion"
    db_password            = var.db_password
    db_port                = local.db_port
    db_host                = module.db_server.public_ip
    django_settings_module = "lion_app.settings.staging"
    django_secret_key      = var.secret_key
  }
  port_range = local.be_port
}

module "be_lb" {
  source = "../modules/loadBalancer"

  name        = "be"
  env         = local.env
  subnet_id   = module.network.subnet_id
  vpc_id      = module.network.vpc_id
  instance_id = module.be_server.instance_id
}
