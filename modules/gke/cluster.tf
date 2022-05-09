/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "regional-private"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_compute_subnetwork" "subnetwork" {
  name       = module.vpc.subnets_names[0]
  project    = var.project_id
  region     = var.region
  depends_on = [module.vpc]
}

module "gke" {
  depends_on                 = [module.vpc]
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster/"
  project_id                 = var.project_id
  name                       = "${var.environment}-${local.cluster_type}"
  kubernetes_version         = "1.21.10-gke.2000"
  regional                   = true
  region                     = var.region
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = "${var.environment}-${var.ip_range_pods_name}"
  ip_range_services          = "${var.environment}-${var.ip_range_services_name}"
  create_service_account     = true
  enable_private_endpoint    = false
  master_ipv4_cidr_block     = "172.16.0.0/28"
  grant_registry_access      = true
  add_cluster_firewall_rules = true
  issue_client_certificate   = true

  enable_private_nodes     = true
  remove_default_node_pool = true
  enable_shielded_nodes    = true

  node_pools = [
    {
      name            = "pool-01"
      min_count       = 1
      max_count       = 8
      local_ssd_count = 0
      disk_size_gb    = 100
      disk_type       = "pd-standard"
      image_type      = "COS"
      auto_repair     = true
      auto_upgrade    = true
      preemptible     = false
    },
  ]

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    },
    {
      cidr_block   = "${var.operator_ip}/32"
      display_name = "Public IP address of operator"
    },
  ]
}
