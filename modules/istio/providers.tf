variable "cluster_endpoint" {
}

variable "cluster_ca_certificate" {
}

data "google_client_config" "default" {
}

# Defer reading the cluster data until the GKE cluster exists.
data "google_container_cluster" "default" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id
}

provider "kubernetes" {
  # host  = "https://${module.safer_cluster.kubernetes_endpoint}"
  #   host  = "https://${data.google_container_cluster.default.endpoint}"
  host  = "https://${var.cluster_endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    var.cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    # host  = "https://${module.safer_cluster.kubernetes_endpoint}"
    # host  = "https://${data.google_container_cluster.default.endpoint}"
    host  = "https://${var.cluster_endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      var.cluster_ca_certificate,
    )
  }
}
