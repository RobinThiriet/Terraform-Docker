output "platform_url" {
  description = "Public URL exposed by the reverse proxy."
  value       = module.local_platform.platform_url
}

output "container_names" {
  description = "Container names managed by Terraform."
  value       = module.local_platform.container_names
}

output "network_name" {
  description = "Shared Docker network name."
  value       = module.local_platform.network_name
}

output "volume_names" {
  description = "Persistent Docker volume names."
  value       = module.local_platform.volume_names
}

