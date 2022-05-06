variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "safer-cluster"
}

variable "region" {
  type        = string
  description = "The region the cluster is in"
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "The project id of the cluster is in"
}

variable "chart" {
  type        = string
  description = "The path or url of the helm chart"
}