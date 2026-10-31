variable "region" {
  description = "aws region for all"
  type        = string
  default     = "ap-south-1"
}
variable "vpc_cidr" {
  description = "the vpc address range"
  type        = string
  default     = "10.0.0.0/16"
}
variable "project_name" {
  description = "a prefix for resources name"
  type        = string
  default     = "cloudscale-tf"
}
variable "alert_email" {
  description = "email receiving alert"
  type        = string
}
variable "image_tag" {
  description = "unique image tag pushed by the pipeline "
  type        = string
  default     = "v1"
}
variable "grace_period" {
  description = "seconds the Auto Scaling Group waits before health-checking a new server "
  type        = number
  default     = 300
}
