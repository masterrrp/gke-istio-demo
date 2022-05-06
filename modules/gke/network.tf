module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = ">= 4.0.1, < 5.0.0"

  project_id   = module.enabled_google_apis.project_id
  network_name = "${var.environment}-${var.network_name}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${var.environment}-${var.subnet_name}"
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = true
      description           = "This subnet is managed by Terraform"
    }
  ]
  secondary_ranges = {
    ("${var.environment}-${var.subnet_name}") = [
      {
        range_name    = "${var.environment}-${var.ip_range_pods_name}"
        ip_cidr_range = var.ip_range_pods
      },
      {
        range_name    = "${var.environment}-${var.ip_range_services_name}"
        ip_cidr_range = var.ip_range_services
      },
    ]
  }
  routes = [
  ]
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id
  name    = "${var.environment}-gke-cloud-router"
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name = "${var.environment}-gke-nat-gateway"
  }]
}

locals {
  custom_rules = {
    "${var.environment}-allow-egrees-http-https" = {
      description          = "Allow all egress via HTTP and HTTPS"
      direction            = "EGRESS"
      action               = "allow"
      ranges               = ["0.0.0.0/0"] # source or destination ranges (depends on `direction`)
      use_service_accounts = false         # if `true` targets/sources expect list of instances SA, if false - list of tags
      targets              = null          # target_service_accounts or target_tags depends on `use_service_accounts` value
      sources              = null          # source_service_accounts or source_tags depends on `use_service_accounts` value
      rules = [
        {
          protocol = "tcp"
          ports    = ["80"]
        },
        {
          protocol = "tcp"
          ports    = ["443"]
        },
      ]

      extra_attributes = {}
    }
  }
}

module "firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = module.vpc.subnets_ips

  internal_allow = [
    {
      protocol = "icmp"
    },
    {
      protocol = "tcp"
    },
    {
      protocol = "udp"
      # all ports will be opened if `ports` key isn't specified
    },
  ]
  custom_rules = local.custom_rules
}