terraform {
  required_version = ">= 0.14"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.24.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.28.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}