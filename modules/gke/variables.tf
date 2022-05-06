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

variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "dev-gke-istio"
}

variable "environment" {
  description = "Enviroment name to use in naming resources, e.g. dev, stage, prod"
  default     = "dev"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-west1"
}

variable "operator_ip" {
  type        = string
  description = "The operator public ip address"
  default     = "127.0.0.1"
}

variable "network_name" {
  type        = string
  description = "The name of the network being created to host the cluster in"
  default     = "gke-network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet being created to host the cluster in"
  default     = "gke-subnet"
}

variable "subnet_ip" {
  type        = string
  description = "The cidr range of the subnet"
  default     = "10.10.10.0/24"
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_pods" {
  description = "The secondary ip range to use for pods"
  default     = "192.168.0.0/18"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-svc"
}

variable "ip_range_services" {
  description = "The secondary ip range to use for services"
  default     = "192.168.64.0/18"
}