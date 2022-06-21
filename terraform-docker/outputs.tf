# Output of the Container Name

output "container_name" {
  value       = docker_container.nodered_container[*].name
  description = "The name of the first container"
}

# Output the IP Address and Ports of the Container

output "ip-address" {
  value       = [for i in docker_container.nodered_container[*]: join(":", [i.ip_address],i.ports[*]["external"])]
  description = "The IP address and the external port of the first container"
}