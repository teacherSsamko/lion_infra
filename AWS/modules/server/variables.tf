variable "env" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "port_range" {
  type = string
}

variable "init_script_path" {
  type = string
}

variable "init_script_vars" {
  type = map(any)
}
