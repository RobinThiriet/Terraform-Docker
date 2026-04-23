output "platform_url" {
  description = "Public URL exposed by the reverse proxy."
  value       = "http://localhost:${var.proxy_http_port}"
}

output "network_name" {
  description = "Shared Docker network name."
  value       = docker_network.platform.name
}

output "volume_names" {
  description = "Persistent Docker volume names."
  value = {
    redis_data = docker_volume.redis_data.name
    proxy_logs = docker_volume.proxy_logs.name
  }
}

output "container_names" {
  description = "Container names managed by the module."
  value = {
    frontend      = docker_container.frontend.name
    backend       = docker_container.backend.name
    reverse_proxy = docker_container.reverse_proxy.name
    redis         = docker_container.cache.name
  }
}

