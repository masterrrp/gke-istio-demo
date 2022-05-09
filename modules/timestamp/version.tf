terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.19.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11.0"
    }
  }
}