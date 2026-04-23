module "local_platform" {
  source = "./modules/local_platform"

  project_name        = var.project_name
  environment         = var.environment
  proxy_http_port     = var.proxy_http_port
  frontend_debug_port = var.frontend_debug_port
  backend_debug_port  = var.backend_debug_port
  redis_port          = var.redis_port
  backend_message     = var.backend_message
  frontend_title      = var.frontend_title

  frontend_context      = "${path.root}/docker/frontend"
  backend_context       = "${path.root}/docker/backend"
  reverse_proxy_context = "${path.root}/docker/reverse-proxy"
}

