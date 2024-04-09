variable "project_id" {
  description = "GCP project id"
  type        = string
  default     = "cloud-native-experience-lab"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west1"
}

variable "gke_cluster_name" {
  default     = "tf-flux2-cluster"
  description = "GKE cluster name"
  type        = string
}

variable "gke_min_nodes" {
  default     = 3
  description = "Minimum number of GKE nodes"
  type        = number
}

variable "gke_max_nodes" {
  default     = 3
  description = "Maximum number of GKE nodes"
  type        = number
}

variable "gke_machine_type" {
  default     = "e2-medium"
  description = "Machine type of GKE nodes"
  type        = string
}

variable "preemptible" {
  default     = false
  description = "Preemptible GKE nodes"
  type        = bool
}

variable "github_token" {
  description = "token for github"
  type        = string
}

variable "github_owner" {
  description = "github owner"
  default     = "qaware"
  type        = string
}

variable "github_deploy_key_title" {
  type        = string
  default     = "tf-flux2-cluster"
  description = "Name of github deploy key"
}

variable "repository_name" {
  description = "repository name"
  default     = "cloud-native-explab"
  type        = string
}

variable "branch" {
  description = "branch"
  type        = string
  default     = "main"
}

variable "target_path" {
  type        = string
  default     = "clusters/gcp/tf-flux2-cluster"
  description = "Relative path to the Git repository root where the sync manifests are committed."
}

variable "flux_namespace" {
  type        = string
  default     = "flux-system"
  description = "the flux namespace"
}
