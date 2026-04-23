terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

locals {
  prefix = "${var.project_name}-${var.environment}"

  frontend_port_bindings = var.frontend_debug_port == null ? [] : [var.frontend_debug_port]
  backend_port_bindings  = var.backend_debug_port == null ? [] : [var.backend_debug_port]
  redis_port_bindings    = var.redis_port == null ? [] : [var.redis_port]
}

resource "docker_network" "platform" {
  name = "${local.prefix}-network"
}

resource "docker_volume" "redis_data" {
  name = "${local.prefix}-redis-data"
}

resource "docker_volume" "proxy_logs" {
  name = "${local.prefix}-proxy-logs"
}

resource "docker_image" "frontend" {
  name = "${local.prefix}-frontend:latest"

  build {
    context    = var.frontend_context
    dockerfile = "Dockerfile"
    build_args = {
      FRONTEND_TITLE = var.frontend_title
    }
  }
}

resource "docker_image" "backend" {
  name = "${local.prefix}-backend:latest"

  build {
    context    = var.backend_context
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "reverse_proxy" {
  name = "${local.prefix}-reverse-proxy:latest"

  build {
    context    = var.reverse_proxy_context
    dockerfile = "Dockerfile"
  }
}

resource "docker_image" "redis" {
  name = "redis:7-alpine"
}

resource "docker_container" "cache" {
  name  = "${local.prefix}-redis"
  image = docker_image.redis.image_id

  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.platform.name
    aliases = ["redis", "cache"]
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  dynamic "ports" {
    for_each = local.redis_port_bindings
    content {
      internal = 6379
      external = ports.value
    }
  }

  command = ["redis-server", "--appendonly", "yes"]

  healthcheck {
    test         = ["CMD", "redis-cli", "ping"]
    interval     = "10s"
    timeout      = "3s"
    retries      = 5
    start_period = "5s"
  }
}

resource "docker_container" "frontend" {
  name  = "${local.prefix}-frontend"
  image = docker_image.frontend.image_id

  restart = "unless-stopped"

  env = [
    "FRONTEND_TITLE=${var.frontend_title}",
  ]

  networks_advanced {
    name    = docker_network.platform.name
    aliases = ["frontend"]
  }

  dynamic "ports" {
    for_each = local.frontend_port_bindings
    content {
      internal = 80
      external = ports.value
    }
  }

  healthcheck {
    test         = ["CMD", "wget", "--spider", "-q", "http://127.0.0.1/"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}

resource "docker_container" "backend" {
  name  = "${local.prefix}-backend"
  image = docker_image.backend.image_id

  restart = "unless-stopped"

  env = [
    "APP_ENV=${var.environment}",
    "APP_NAME=${var.project_name}",
    "APP_MESSAGE=${var.backend_message}",
    "REDIS_HOST=redis",
    "REDIS_PORT=6379",
  ]

  networks_advanced {
    name    = docker_network.platform.name
    aliases = ["backend", "api"]
  }

  dynamic "ports" {
    for_each = local.backend_port_bindings
    content {
      internal = 8080
      external = ports.value
    }
  }

  depends_on = [docker_container.cache]

  healthcheck {
    test         = ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz', timeout=2)"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 5
    start_period = "15s"
  }
}

resource "docker_container" "reverse_proxy" {
  name  = "${local.prefix}-reverse-proxy"
  image = docker_image.reverse_proxy.image_id

  restart = "unless-stopped"

  env = [
    "FRONTEND_UPSTREAM=frontend:80",
    "BACKEND_UPSTREAM=backend:8080",
  ]

  networks_advanced {
    name    = docker_network.platform.name
    aliases = ["reverse-proxy", "gateway"]
  }

  ports {
    internal = 80
    external = var.proxy_http_port
  }

  volumes {
    volume_name    = docker_volume.proxy_logs.name
    container_path = "/var/log/nginx"
  }

  depends_on = [
    docker_container.frontend,
    docker_container.backend,
  ]

  healthcheck {
    test         = ["CMD", "wget", "--spider", "-q", "http://127.0.0.1/healthz"]
    interval     = "15s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }
}
