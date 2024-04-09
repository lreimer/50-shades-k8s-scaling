terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }

  required_version = ">= 0.14"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Networking
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name = "default"
}

data "google_container_engine_versions" "versions" {
  location = var.region
}

locals {
  stable_default_version = data.google_container_engine_versions.versions.release_channel_default_version["STABLE"]
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name               = var.gke_cluster_name
  project            = var.project_id
  location           = var.region
  min_master_version = local.stable_default_version

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = data.google_compute_network.default.self_link
  subnetwork = data.google_compute_subnetwork.default.self_link
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = google_container_cluster.primary.name
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name
  version  = local.stable_default_version

  node_count = var.gke_min_nodes
  autoscaling {
    min_node_count = var.gke_min_nodes
    max_node_count = var.gke_max_nodes
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    preemptible  = var.preemptible
    machine_type = var.gke_machine_type
    tags         = ["gke-node", "${var.gke_cluster_name}"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
