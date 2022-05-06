# Istio Helm Module

This module makes it easy to set up a Istio "default profile" deployment using Helm.

It supports creating:

    - k8s namespace
    - istio base
    - istiod
    - istio ingress gateway


## Compatibility

This module is meant for use with Terraform 0.13+ and tested using Terraform 1.0+.

## Usage
```hcl
data "google_client_config" "default" {
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "default" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.default.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
    )
  }
}

module "istio" {
  source       = "../modules/istio"
  cluster_name = var.cluster_name
  region       = var.region
  project_id   = var.project_id
}
```

Then perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
