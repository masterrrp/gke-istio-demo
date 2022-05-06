#   cluster_name     = module.safer_cluster.cluster_name
#   region = module.safer_cluster.location
#   project_id       = module.safer_cluster.project_id

output "cluster_name" {
  description = "Cluster name"
  value       = var.cluster_name
}

output "region" {
  description = "Cluster region"
  value       = var.region
}

output "project_id" {
  description = "Cluster name"
  value       = var.project_id
}