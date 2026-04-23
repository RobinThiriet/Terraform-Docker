variable "project_name" {
  description = "Project identifier used as the naming prefix."
  type        = string
}

variable "environment" {
  description = "Target environment name."
  type        = string
}

variable "proxy_http_port" {
  description = "Host port exposed by the reverse proxy."
  type        = number
}

variable "frontend_debug_port" {
  description = "Optional host port for direct access to the frontend container."
  type        = number
  default     = null
}

variable "backend_debug_port" {
  description = "Optional host port for direct access to the backend container."
  type        = number
  default     = null
}

variable "redis_port" {
  description = "Optional host port for Redis."
  type        = number
  default     = null
}

variable "backend_message" {
  description = "Message returned by the backend API."
  type        = string
}

variable "frontend_title" {
  description = "Frontend page title."
  type        = string
}

variable "frontend_context" {
  description = "Build context for the frontend image."
  type        = string
}

variable "backend_context" {
  description = "Build context for the backend image."
  type        = string
}

variable "reverse_proxy_context" {
  description = "Build context for the reverse proxy image."
  type        = string
}

