variable "project_name" {
  description = "Project identifier used as the naming prefix."
  type        = string
  default     = "local-platform"
}

variable "environment" {
  description = "Target environment name."
  type        = string
  default     = "dev"
}

variable "proxy_http_port" {
  description = "Host port exposed by the reverse proxy."
  type        = number
  default     = 8080
}

variable "frontend_debug_port" {
  description = "Optional host port for direct access to the frontend container. Set to null to disable."
  type        = number
  default     = null
}

variable "backend_debug_port" {
  description = "Optional host port for direct access to the backend container. Set to null to disable."
  type        = number
  default     = null
}

variable "redis_port" {
  description = "Optional host port for Redis. Set to null to disable."
  type        = number
  default     = null
}

variable "backend_message" {
  description = "Message returned by the backend API."
  type        = string
  default     = "Hello from the Terraform-managed backend"
}

variable "frontend_title" {
  description = "Frontend page title."
  type        = string
  default     = "Local Platform"
}

