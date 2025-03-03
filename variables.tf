/// ===================================================
//               AWS CONFIGURATION
/// ===================================================

variable "aws_region" {
  description = "The AWS region where resources will be deployed"
  default     = "eu-west-3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance"
  default     = "t2.micro"
  type        = string
}

/// ===================================================
//               DOCKER CONFIGURATION
/// ===================================================

variable "docker_image" {
  description = "The Docker image to pull and run"
  default     = "registry.extra.irsn.fr/webteleray/teleray-benchmark:dev"
  type        = string
}

variable "command" {
  description = "The command to execute inside the Docker container for Artillery tests"
  default     = "./scripts/benchmark.sh app-normal.js high"
  type        = string
}

/// ===================================================
//               REPOSITORY AND AUTHENTICATION
/// ===================================================

variable "development_repo_url" {
  description = "The URL of the development repository"
  type        = string
  sensitive   = true
}

variable "rclone_config_repo_url" {
  description = "The URL of the rclone config repository"
  type        = string
  sensitive   = true
}

variable "sops_age_key" {
  type        = string
  sensitive   = true
}

/// ===================================================
//               LOAD TESTING CONFIGURATION
/// ===================================================

variable "target" {
  description = "The target URL to test with Artillery"
  default     = "https://app.teleray.staging.ul2i.fr"
  type        = string
}

variable "environment" {
  default     = "production"
  type        = string
}

variable "admin_jwt_access_token" {
  description = "JWT access token for admin authentication"
  type        = string
  sensitive   = true
}

variable "low_duration" {
  description = "Duration (in seconds) for the low load testing phase"
  default     = 120
  type        = number
}

variable "low_max_vusers" {
  description = "Maximum number of virtual users for the low load testing phase"
  default     = 20
  type        = number
}

variable "low_arrival_rate" {
  description = "Rate of virtual user arrivals per second for the low load testing phase"
  default     = 1
  type        = number
}

variable "medium_duration" {
  description = "Duration (in seconds) for the medium load testing phase"
  default     = 120
  type        = number
}

variable "medium_max_vusers" {
  description = "Maximum number of virtual users for the medium load testing phase"
  default     = 200
  type        = number
}

variable "medium_arrival_rate" {
  description = "Rate of virtual user arrivals per second for the medium load testing phase"
  default     = 2
  type        = number
}

variable "high_duration" {
  description = "Duration (in seconds) for the high load testing phase"
  default     = 120
  type        = number
}

variable "high_max_vusers" {
  description = "Maximum number of virtual users for the high load testing phase"
  default     = 2000
  type        = number
}

variable "high_arrival_rate" {
  description = "Rate of virtual user arrivals per second for the high load testing phase"
  default     = 17
  type        = number
}