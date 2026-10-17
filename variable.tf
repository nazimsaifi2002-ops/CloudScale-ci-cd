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
