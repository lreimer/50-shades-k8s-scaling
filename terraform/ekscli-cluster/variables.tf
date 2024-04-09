variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
}

variable "cluster_vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "cluster_region" {
  description = "Region for the EKS cluster"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_version" {
  description = "Version of Kubernetes to use for the EKS cluster"
  type        = string
  default     = "1.19"
}

variable "cluster_tags" {
  description = "Tags for the EKS cluster"
  type        = map(string)
  default     = {}
}

variable "cluster_private_subnets" {
  description = "Mapping of AZs to private subnet IDs"
  type        = map(string)
  default     = {}
}

variable "cluster_public_subnets" {
  description = "Mapping of AZs to public subnet IDs"
  type        = map(string)
  default     = {}
}

variable "cluster_endpoints_private_access" {
  description = "Enable private access for the EKS cluster"
  type        = bool
  default     = true
}

variable "cluster_endpoints_public_access" {
  description = "Enable public access for the the EKS cluster"
  type        = bool
  default     = false
}

variable "cluster_template_file" {
  description = "A custom config template file to use instead of default template"
  type        = string
  default     = ""
}