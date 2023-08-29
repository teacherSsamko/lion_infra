output "db_public_ip" {
  value = module.db_server.public_ip
}

output "db_instance_id" {
  value = module.db_server.instance_id
}
