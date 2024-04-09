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
  default     = "tf-plain-cluster"
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
